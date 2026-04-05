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

variable "node_gateways" {
  description = "Per-node gateway IPs (CPs first, then workers)"
  type        = list(string)
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

variable "node_vlans" {
  description = "Per-node VLAN IDs (CPs first, then workers)"
  type        = list(number)
}

variable "enable_bgp_vip" {
  description = "Use kube-vip static pod in BGP mode instead of Talos ARP VIP"
  type        = bool
  default     = false
}


variable "etcd_force_new_cluster_node" {
  description = "Index of the CP node to force-new-cluster on (set to -1 to disable)"
  type        = number
  default     = -1
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

variable "pod_cidr" {
  description = "Pod network CIDR — must be unique per cluster when multiple clusters share the same router"
  type        = string
  default     = "10.244.0.0/16"
}

variable "bootstrap_enabled" {
  description = "Whether to run Talos bootstrap resource (enable only during initial cluster creation/recovery)"
  type        = bool
  default     = false
}
