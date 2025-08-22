
locals {
    app_name = "flask-app"
    db_password = "postgres"
}

// сеть 
resource "yandex_vpc_network" "main" {
  name = "${local.app_name}-network"  
}

resource "yandex_vpc_subnet" "main" {
  name           = "${local.app_name}-subnet"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.main.id
  v4_cidr_blocks = ["10.1.0.0/24"]
}

//виртуалка 

resource "yandex_compute_instance" "k8s-node" {
  name        = "${local.app_name}-vm"
  zone        = "ru-central1-a"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8kdq6d0p8sij7h5qe3"
      size = 20
      type = "network-ssd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.main.id
    nat       = true
  }

  metadata = {
    user-data = file("cloud-init.yaml")
  }
}

//postres
resource "yandex_mdb_postgresql_cluster" "main" {
  name = "${local.app_name}-postgres"
  environment = "PRODUCTION"
  network_id = yandex_vpc_network.main.id

  config {
    version = "16"
    resources {
      resource_preset_id = "s2.micro"
      disk_size = 20
      disk_type_id = "network-ssd"
    }
  }

  host {
    zone = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.main.id
  }
}

resource "yandex_mdb_postgresql_database" "app_db" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = "name_db"
  owner = yandex_mdb_postgresql_user.app_user.name
}

resource "yandex_mdb_postgresql_user" "app_user" {
  cluster_id = yandex_mdb_postgresql_cluster.main.id
  name       = "postgres"
  password   = local.db_password
}


// Create SA
resource "yandex_iam_service_account" "sa" {
  folder_id = local.folder_id
  name      = "tf-test-sa"
}

// Grant permissions
resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = local.folder_id
  role      = "storage.admin"
  member    = "serviceAccount:${yandex_iam_service_account.sa.id}"
}

// Create Static Access Keys
resource "yandex_iam_service_account_static_access_key" "sa-static-key" {
  service_account_id = yandex_iam_service_account.sa.id
  description        = "static access key for object storage"
}

// Use keys to create bucket
resource "yandex_storage_bucket" "test" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = "tf-info-site-bucket"
  acl    = "public-read"

  website {
    index_document = "index.html"
  }
}


resource "yandex_storage_object" "index" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.test.id
  acl    = "public-read"
  key    = "index.html"
  source = "index.html"
}


output "vm_external_ip" {
  value = yandex_compute_instance.k8s-node.network_interface.0.nat_ip_address
}

output "postgres_host" {
  value = yandex_mdb_postgresql_cluster.main.host.0.fqdn
}

output "site_url" {
  value = yandex_storage_bucket.test.website_endpoint
}

output "database_url" {
  value = "postgresql://postgres:${local.db_password}@${yandex_mdb_postgresql_cluster.main.host.0.fqdn}:6432/mydb"
  sensitive = true
}