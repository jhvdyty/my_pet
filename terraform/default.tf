terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
      version = "0.148.0"
    }
  }
}


locals {
    folder_id = "b1g3ta9ecntdpujpoonn"
    cloud_id  = "ajem9017tmh7cf487v7h"
}

provider "yandex" {
    cloud_id  = local.cloud_id
    folder_id = local.folder_id
    service_account_key_file = abspath("./authorized_key.json")
}