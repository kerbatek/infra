output "kubeconfig" {
  description = "Kubeconfig for the Talos cluster"
  value       = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive   = true
}

output "talosconfig" {
  description = "Talosconfig for managing the cluster"
  value       = data.talos_client_configuration.this.talos_config
  sensitive   = true
}