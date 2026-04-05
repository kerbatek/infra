output "kubeconfig" {
  description = "Kubeconfig for the testing cluster"
  value       = module.cluster.kubeconfig
  sensitive   = true
}

output "talosconfig" {
  description = "Talosconfig for managing the testing cluster"
  value       = module.cluster.talosconfig
  sensitive   = true
}
