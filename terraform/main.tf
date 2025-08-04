terraform {
    required_providers {
        docker = {
            source  = "kreuzwerker/docker"
            version = "~> 3.0.2"
        }
    }
}

provider "docker" {}

resource "docker_network" "microservices" {
    name = "microservices"
}

resource "docker_image" "postgres" {
    name = "postgres:16.0"
}

resource "docker_container" "postgres" {
    name  = "postgres"
    image = docker_image.postgres.latest
    networks_advanced {
        name = docker_network.microservices.name
    }
    env = [
        "POSTGRES_USER=postgres",
        "POSTGRES_PASSWORD=postgres",
        "POSTGRES_DB=mydb"
    ]
    ports {
        internal = 5432
        external = 5432
    }
    volumes {
        host_path      = "${path.module}/postgres_data"
        container_path = "/var/lib/postgresql/data"
    }
  
}