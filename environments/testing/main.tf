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
  insecure  = true

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

  node_gateways     = ["10.0.216.0", "10.0.216.2", "10.0.216.6", "10.0.216.8", "10.0.216.10", "10.0.216.12"]
  node_vlans        = [2161, 2162, 2163, 2164, 2165, 2166]
  control_plane_ips = ["10.0.216.1", "10.0.216.3", "10.0.216.7"]
  worker_ips        = ["10.0.216.9", "10.0.216.11", "10.0.216.13"]
  vip               = "10.0.216.5"
  enable_bgp_vip    = true

  vm_id_offset = 9000

  cp_cpu       = 3
  cp_memory    = 6144
  cp_disk_size = 20

  worker_cpu       = 2
  worker_memory    = 4096
  worker_disk_size = 30

  enable_longhorn   = true
  enable_cilium     = true
  bootstrap_enabled = false
}
