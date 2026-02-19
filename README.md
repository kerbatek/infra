# infra

Terraform for a Talos Linux Kubernetes cluster on Proxmox.

```
Proxmox VE (128GB)
├── talos-cp-1       control plane   2 vCPU · 4GB · 30GB
├── talos-worker-1   worker          4 vCPU · 8GB · 50GB
└── talos-worker-2   worker          4 vCPU · 8GB · 50GB
```

## Usage

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars  # fill in your values
terraform init
terraform apply

terraform output -raw kubeconfig > ~/.kube/config
terraform output -raw talosconfig > ~/.talos/config
kubectl get nodes
```

## Structure

```
terraform/
├── providers.tf     # bpg/proxmox + siderolabs/talos
├── variables.tf
├── image.tf         # Talos image from factory.talos.dev
├── vms.tf           # Proxmox VMs
├── talos.tf         # machine config + bootstrap
└── outputs.tf       # kubeconfig, talosconfig
```

## Related

- [url-shortener](https://github.com/kerbatek/url-shortener) — app deployed on this cluster
- [gitops](https://github.com/kerbatek/gitops) — ArgoCD apps and Helm charts
