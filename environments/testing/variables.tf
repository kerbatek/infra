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
