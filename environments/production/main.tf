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

  cluster_name     = "url-shortener"
  cluster_endpoint = "https://10.0.217.5:6443"

  node_gateways     = ["10.0.217.0", "10.0.217.2", "10.0.217.6", "10.0.217.8", "10.0.217.10", "10.0.217.12"]
  node_vlans        = [2171, 2172, 2173, 2174, 2175, 2176]
  control_plane_ips = ["10.0.217.1", "10.0.217.3", "10.0.217.7"]
  worker_ips        = ["10.0.217.9", "10.0.217.11", "10.0.217.13"]
  vip               = "10.0.217.5"
  enable_bgp_vip    = true

  vm_id_offset = 8000

  cp_cpu       = 4
  cp_memory    = 6144
  cp_disk_size = 30

  worker_cpu       = 4
  worker_memory    = 8192
  worker_disk_size = 50

  enable_longhorn   = true
  enable_cilium     = true
  pod_cidr          = "10.245.0.0/16"
  bootstrap_enabled = false
}
