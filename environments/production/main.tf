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

  cluster_name     = "url-shortener"
  cluster_endpoint = "https://10.0.215.5:6443"

  gateway           = "10.0.215.1"
  control_plane_ips = ["10.0.215.10", "10.0.215.11", "10.0.215.12"]
  worker_ips        = ["10.0.215.50", "10.0.215.51", "10.0.215.52", "10.0.215.53", "10.0.215.54"]
  vip               = "10.0.215.5"

  vm_id_offset = 8000
  vlan_id      = 215

  cp_cpu       = 2
  cp_memory    = 4096
  cp_disk_size = 30

  worker_cpu       = 4
  worker_memory    = 8192
  worker_disk_size = 50

  enable_longhorn = true
}
