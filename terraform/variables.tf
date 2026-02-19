// Proxmox connection variables
variable "proxmox_endpoint" {
  description = "Proxmox API endpoint URL"
  type        = string
}

variable "proxmox_api_token" {
  description = "Proxmox API token (user!tokenid=secret)"
  type        = string
  sensitive   = true
}

variable "proxmox_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve"
}

// Talos and Kubernetes variables
variable "talos_version" {
  description = "Talos Linux version"
  type        = string
  default     = "1.12.2"
}

variable "kubernetes_version" {
  description = "Kubernetes version to deploy"
  type        = string
  default     = "1.32.0"
}

variable "cluster_name" {
  description = "Talos cluster name"
  type        = string
  default     = "url-shortener-cluster"
}

variable "cluster_endpoint" {
  description = "Kubernetes API endpoint (use control plane IP or VIP)"
  type        = string
}

// Network configuration variables
variable "gateway" {
  description = "Default gateway IP"
  type        = string
}

variable "nameservers" {
  description = "DNS nameservers"
  type        = list(string)
  default     = ["1.1.1.1", "8.8.8.8"]
}

variable "control_plane_ips" {
  description = "Static IPs for control plane nodes"
  type        = list(string)
}

variable "worker_ips" {
  description = "Static IPs for worker nodes"
  type        = list(string)
}

variable "vip" {
  description = "Virtual IP for HA control plane"
  type        = string
  default     = ""
}

// Node resource configuration variables
variable "cp_cpu" {
  type    = number
  default = 2
}
variable "cp_memory" {
  description = "Control plane RAM in MB"
  type        = number
  default     = 4096
}
variable "cp_disk_size" {
  description = "Control plane disk in GB"
  type        = number
  default     = 30
}

variable "worker_cpu" {
  type    = number
  default = 4
}
variable "worker_memory" {
  description = "Worker RAM in MB"
  type        = number
  default     = 8192
}
variable "worker_disk_size" {
  description = "Worker disk in GB"
  type        = number
  default     = 50
}