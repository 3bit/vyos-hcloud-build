variable "HCLOUD_TOKEN" {
  type      = string
  sensitive = true
}

variable "BUILD_ID" {
  type = string
}

variable "ISO" {
  type = string
}

source "hcloud" "vyos" {
  token         = var.HCLOUD_TOKEN
  server_type   = "cx11"
  location      = "nbg1"
  ssh_username  = "vyos"
  image         = "debian-10"
  server_name   = "${var.BUILD_ID}-packer"
  snapshot_name = var.BUILD_ID
  snapshot_labels = {
    "${var.BUILD_ID}" = ""
  }

  user_data = <<EOF
    #cloud-config
    system_info:
      default_user:
        name: vyos
  EOF
}

build {
  name = "vyos"

  source "sources.hcloud.vyos" {}

  provisioner "file" {
    source      = "${var.ISO}"
    destination = "/tmp/boot.iso"
  }

  provisioner "shell" {
    expect_disconnect = true
    script            = "${path.root}/boot_iso"
  }

  provisioner "shell" {
    script = "${path.root}/install_vyos"
  }
}
