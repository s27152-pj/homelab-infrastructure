terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.73.0"
    }
  }
}
provider "proxmox" {
  endpoint  = "https://192.168.0.38:8006/"
  api_token = var.proxmox_api_token
  insecure  = true
}
resource "proxmox_virtual_environment_container" "test_lxc" {
  description = "Container managed by Terraform (IaC)"
  node_name   = "pve"
  vm_id       = 105
  started     = true
  unprivileged = true
  cpu {
    cores = 1
  }
  memory {
    dedicated = 512
    swap      = 512
  }
  disk {
    datastore_id = "local-lvm"
    size         = 4
  }
  network_interface {
    name   = "eth0"
    bridge = "vmbr0"
  }
  operating_system {
    template_file_id = "local:vztmpl/debian-13-standard_13.6-1_amd64.tar.zst"
    type             = "debian"
  }
  initialization {
    hostname = "terraform-lxc"
    ip_config {
      ipv4 {
        address = "192.168.0.99/24"
        gateway = "192.168.0.1"
      }
    }
    user_account {
      keys = [
        trimspace(file("~/.ssh/id_ed25519.pub"))
      ]
    }
  }
}
