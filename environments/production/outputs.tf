output "kubeconfig" {
  description = "Kubeconfig for the production cluster"
  value       = module.cluster.kubeconfig
  sensitive   = true
}

output "talosconfig" {
  description = "Talosconfig for managing the production cluster"
  value       = module.cluster.talosconfig
  sensitive   = true
}
