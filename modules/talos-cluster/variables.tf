variable "proxmox_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve"
}

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
}

variable "cluster_endpoint" {
  description = "Kubernetes API endpoint (use control plane IP or VIP)"
  type        = string
}

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

variable "vm_id_offset" {
  description = "Base VM ID for this cluster (CP = offset+index, workers = offset+10+index)"
  type        = number
}

variable "vlan_id" {
  description = "VLAN ID for cluster network traffic"
  type        = number
}

variable "datastore_id" {
  description = "Proxmox datastore for VM disks and images"
  type        = string
  default     = "local-zfs"
}

variable "enable_longhorn" {
  description = "Whether to mount /var/lib/longhorn on worker nodes"
  type        = bool
  default     = true
}

variable "enable_cilium" {
  description = "Disable built-in Flannel CNI and kube-proxy for Cilium"
  type        = bool
  default     = false
}
