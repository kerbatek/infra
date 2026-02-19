// Generate machine secrets (TLS certs, etc.) that will be used to bootstrap the cluster
resource "talos_machine_secrets" "this" {}

// Generate machine configuration for control plane nodes
data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster_name
  machine_type     = "controlplane"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  kubernetes_version = var.kubernetes_version
}

// Generate machine configuration for worker nodes
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster_name
  machine_type     = "worker"
  cluster_endpoint = var.cluster_endpoint
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  kubernetes_version = var.kubernetes_version
}

// Apply the control plane machine configuration to each control plane node
resource "talos_machine_configuration_apply" "controlplane" {
  count = length(var.control_plane_ips)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = var.control_plane_ips[count.index]
  endpoint                    = var.control_plane_ips[count.index]

  config_patches = concat(
    [
      yamlencode({
        machine = {
          install = {
            disk  = "/dev/vda"
            image = "factory.talos.dev/installer/${talos_image_factory_schematic.this.id}:v${var.talos_version}"
          }
        }
      }),
    ],
    var.vip != "" ? [
      yamlencode({
        machine = {
          network = {
            interfaces = [
              {
                interface = "eth0"
                vip = {
                  ip = var.vip
                }
              }
            ]
          }
        }
      })
    ] : []
  )

  depends_on = [proxmox_virtual_environment_vm.control_plane]
}

// Apply the worker machine configuration to each worker node
resource "talos_machine_configuration_apply" "worker" {
  count = length(var.worker_ips)

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = var.worker_ips[count.index]
  endpoint                    = var.worker_ips[count.index]

  config_patches = [
    yamlencode({
      machine = {
        install = {
          disk  = "/dev/vda"
          image = "factory.talos.dev/installer/${talos_image_factory_schematic.this.id}:v${var.talos_version}"
        }
      }
    }),
  ]

  depends_on = [proxmox_virtual_environment_vm.worker]
}

// Bootstrap the first control plane node to kick off cluster creation
resource "talos_machine_bootstrap" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.control_plane_ips[0]
  endpoint             = var.control_plane_ips[0]

  depends_on = [talos_machine_configuration_apply.controlplane]
}

// Wait for the cluster to be healthy before proceeding with any other operations
data "talos_cluster_health" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  control_plane_nodes  = var.control_plane_ips
  worker_nodes         = var.worker_ips
  endpoints            = var.control_plane_ips

  depends_on = [
    talos_machine_bootstrap.this,
    talos_machine_configuration_apply.worker
  ]
}

// Get the kubeconfig for the cluster so we can interact with it later (e.g. with kubectl or Talos CLI)
resource "talos_cluster_kubeconfig" "this" {
  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = var.control_plane_ips[0]
  endpoint             = var.control_plane_ips[0]

  depends_on = [data.talos_cluster_health.this]
}

// Get the talosconfig
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = concat(var.control_plane_ips, var.worker_ips)
  endpoints            = var.control_plane_ips
}