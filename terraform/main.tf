
locals {
  app_name = "flask-app"
  
  db_password = "postgres" 
}

# API
resource "google_project_service" "compute" {
  service = "compute.googleapis.com"
}

resource "google_project_service" "sql" {
  service = "sqladmin.googleapis.com"
}

resource "google_project_service" "storage" {
  service = "storage.googleapis.com"
}

# сеть
resource "google_compute_network" "main" {
  name                    = "${local.app_name}-network"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.compute]
}

resource "google_compute_subnetwork" "main" {
  name          = "${local.app_name}-subnet"
  ip_cidr_range = "10.1.0.0/24"
  region        = local.region
  network       = google_compute_network.main.id
}

# firewall
resource "google_compute_firewall" "flask_app" {
  name    = "${local.app_name}-firewall"
  network = google_compute_network.main.name

  allow {
    protocol = "tcp"
    ports    = ["22", "80", "443", "30000", "30090", "30300"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["flask-app"]
}

# VM
resource "google_compute_instance" "k8s_node" {
  name         = "${local.app_name}-vm"
  machine_type = "e2-small" # 2 vCPU, 2GB RAM 
  zone         = local.zone
  
  tags = ["flask-app"]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20 
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.main.id
    access_config {
      // ephemeral public IP
    }
  }

  metadata = {
    user-data = file("cloud-init.yaml")
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Дополнительная настройка если нужно
    echo "VM started successfully" > /tmp/startup.log
  EOF

  depends_on = [google_project_service.compute]
}

# cloud sql
resource "google_sql_database_instance" "postgres" {
  name             = "${local.app_name}-postgres"
  database_version = "POSTGRES_16"
  region          = local.region
  
  settings {
    tier = "db-f1-micro"
    
    disk_size = 20
    disk_type = "PD_SSD"
    
    backup_configuration {
      enabled    = true
      start_time = "03:00"
    }
    
    ip_configuration {
      ipv4_enabled    = true
      authorized_networks {
        name  = "flask-vm"
        value = "${google_compute_instance.k8s_node.network_interface[0].access_config[0].nat_ip}/32"
      }
      authorized_networks {
        name  = "all"
        value = "0.0.0.0/0"
      }
    }
  }

  depends_on = [google_project_service.sql]
}

resource "google_sql_database" "app_db" {
  name     = "mydb"
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "app_user" {
  name     = "postgres"
  instance = google_sql_database_instance.postgres.name
  password = local.db_password
}

# cloud storage
resource "google_storage_bucket" "static_site" {
  name          = "${local.project_id}-static-site"
  location      = "US"
  force_destroy = true

  website {
    main_page_suffix = "index.html"
  }

  uniform_bucket_level_access = true
}

# bucket public
resource "google_storage_bucket_iam_member" "public_access" {
  bucket = google_storage_bucket.static_site.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}

# index.html
resource "google_storage_bucket_object" "index" {
  name   = "index.html"
  bucket = google_storage_bucket.static_site.name
  source = "index.html"
}

# output
output "vm_external_ip" {
  value = google_compute_instance.k8s_node.network_interface[0].access_config[0].nat_ip
}

output "postgres_host" {
  value = google_sql_database_instance.postgres.public_ip_address
}

output "postgres_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "database_url" {
  value     = "postgresql://postgres:${local.db_password}@${google_sql_database_instance.postgres.public_ip_address}:5432/mydb"
  sensitive = true
}

output "static_site_url" {
  value = "https://storage.googleapis.com/${google_storage_bucket.static_site.name}/index.html"
}

# инфа
output "useful_commands" {
  value = <<-EOF
  
  подключение к VM
  ssh ubuntu@${google_compute_instance.k8s_node.network_interface[0].access_config[0].nat_ip}
  
  URL приложения
  http://${google_compute_instance.k8s_node.network_interface[0].access_config[0].nat_ip}:30000
  
  prometheus
  http://${google_compute_instance.k8s_node.network_interface[0].access_config[0].nat_ip}:30090
  
  grafana
  http://${google_compute_instance.k8s_node.network_interface[0].access_config[0].nat_ip}:30300
  
  EOF
}