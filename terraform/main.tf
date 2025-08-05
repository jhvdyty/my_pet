
locals {
    backet_name = "tf-info-site-bucket"
    index = "index.html"
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
  bucket = local.backet_name
  acl    = "public-read"

  website {
    index_document = local.index
  }
}


resource "yandex_storage_object" "index" {
  access_key = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  secret_key = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  bucket = yandex_storage_bucket.test.id
  acl    = "public-read"
  key    = local.index
  source = "${local.index}"
}


output site_name {
  value = yandex_storage_bucket.test.website_endpoint
}



//terraform {
//    required_providers {
//        docker = {
//            source  = "kreuzwerker/docker"
//            version = "~> 3.0.2"
//        }
//    }
//}
//
//provider "docker" {}
//
//resource "docker_network" "microservices" {
//    name = "microservices"
//}
//
//resource "docker_image" "postgres" {
//    name = "postgres:16.0"
//}
//
//resource "docker_container" "postgres" {
//    name  = "postgres"
//    image = docker_image.postgres.name
//    
//    networks_advanced {
//        name = docker_network.microservices.name
//    }
//    
//    env = [
//        "POSTGRES_USER=postgres",
//        "POSTGRES_PASSWORD=postgres",
//        "POSTGRES_DB=mydb"
//    ]
//    
//    ports {
//        internal = 5432
//        external = 5432
//    }
//    
//    volumes {
//        container_path = "/var/lib/postgresql/data"
//        host_path = abspath("${path.module}/postgres_data")
//    }
//}