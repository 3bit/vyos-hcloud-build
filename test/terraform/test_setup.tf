terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    random = {
      source = "hashicorp/random"
    }
    tls = {
      source = "hashicorp/tls"
    }
  }
  required_version = ">= 0.13"
}

variable "HCLOUD_TOKEN" {}
variable "BUILD_ID" {}

provider "hcloud" {
  token = var.HCLOUD_TOKEN
}

resource "random_uuid" "default" {}

resource "tls_private_key" "default" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "hcloud_ssh_key" "default" {
  name       = "${var.BUILD_ID}-terraform"
  public_key = tls_private_key.default.public_key_openssh
}

data "hcloud_image" "default" {
  with_selector = var.BUILD_ID
  most_recent   = true
}

resource "hcloud_server" "default" {
  name        = "${var.BUILD_ID}-terraform"
  server_type = "cx11"
  image       = data.hcloud_image.default.id
  location    = "nbg1"
  ssh_keys    = [hcloud_ssh_key.default.name]
  user_data   = <<EOF
    #cloud-config
    system_info:
      default_user:
        name: vyos
  EOF
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.default.private_key_pem
  filename        = "${path.root}/../private_key_pem"
  file_permission = "0600"
}

resource "local_file" "server_ip" {
  content  = hcloud_server.default.ipv4_address
  filename = "${path.root}/../server_ip"
}