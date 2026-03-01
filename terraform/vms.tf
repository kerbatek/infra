// Control plane VMs
resource "proxmox_virtual_environment_vm" "control_plane" {
  count = length(var.control_plane_ips)

  name      = "${var.cluster_name}-cp-${count.index + 1}"
  node_name = var.proxmox_node_name
  vm_id     = 8000 + count.index

  bios    = "seabios"

  agent {
    enabled = true
  }

  cpu {
    cores = var.cp_cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.cp_memory
    floating  = var.cp_memory
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = var.cp_disk_size
    discard      = "on"
    iothread     = "true"
  }

  efi_disk {
    datastore_id = "local-zfs"
    type         = "4m"
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 215
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${var.control_plane_ips[count.index]}/24"
        gateway = var.gateway
      }
    }
    dns {
      servers = var.nameservers
    }
  }

  operating_system {
    type = "l26"  // Linux 2.6+ kernel
  }

  lifecycle {
    ignore_changes = [disk[0].file_id]
  }
}
// Worker VMs
resource "proxmox_virtual_environment_vm" "worker" {
  count = length(var.worker_ips)

  name      = "${var.cluster_name}-worker-${count.index + 1}"
  node_name = var.proxmox_node_name
  vm_id     = 8010 + count.index

  bios    = "seabios"

  agent {
    enabled = true
  }

  cpu {
    cores = var.worker_cpu
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = var.worker_memory
    floating  = var.worker_memory
  }

  disk {
    datastore_id = "local-zfs"
    file_id      = proxmox_virtual_environment_download_file.talos_image.id
    interface    = "virtio0"
    size         = var.worker_disk_size
    discard      = "on"
    iothread     = "true"
  }

  efi_disk {
    datastore_id = "local-zfs"
    type         = "4m"
  }

  network_device {
    bridge  = "vmbr0"
    vlan_id = 215
  }

  initialization {
    datastore_id = "local-zfs"
    ip_config {
      ipv4 {
        address = "${var.worker_ips[count.index]}/24"
        gateway = var.gateway
      }
    }
    dns {
      servers = var.nameservers
    }
  }

  operating_system {
    type = "l26"
  }

  lifecycle {
    ignore_changes = [disk[0].file_id]
  }
}