terraform {
  required_version = ">= 1.5.0"

  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.78"
    }
    talos = {
      source  = "siderolabs/talos"
      version = "~> 0.7"
    }
  }
}

provider "proxmox" {
  endpoint  = var.proxmox_endpoint
  api_token = var.proxmox_api_token
  insecure  = false

  ssh {
    agent    = true
    username = "root"
  }
}

provider "talos" {}

module "cluster" {
  source = "../../modules/talos-cluster"

  proxmox_node_name = var.proxmox_node_name

  cluster_name     = "testing"
  cluster_endpoint = "https://10.0.216.5:6443"

  gateway           = "10.0.216.1"
  control_plane_ips = ["10.0.216.10", "10.0.216.11", "10.0.216.12"]
  worker_ips        = ["10.0.216.50", "10.0.216.51", "10.0.216.52"]
  vip               = "10.0.216.5"

  vm_id_offset = 9000
  vlan_id      = 216

  cp_cpu       = 2
  cp_memory    = 2048
  cp_disk_size = 20

  worker_cpu       = 2
  worker_memory    = 4096
  worker_disk_size = 30

  enable_longhorn = true
  enable_cilium   = true
}
