# infra

Terraform for Talos Linux Kubernetes clusters on Proxmox, using a shared module for consistent cluster definitions.

## Clusters

```
production (VLAN 215 · 10.0.215.0/24)
├── url-shortener-cp-1      control plane   2 vCPU · 4GB · 30GB   VM 8000
├── url-shortener-cp-2      control plane   2 vCPU · 4GB · 30GB   VM 8001
├── url-shortener-cp-3      control plane   2 vCPU · 4GB · 30GB   VM 8002
├── url-shortener-worker-1  worker          4 vCPU · 8GB · 50GB   VM 8010
├── url-shortener-worker-2  worker          4 vCPU · 8GB · 50GB   VM 8011
├── url-shortener-worker-3  worker          4 vCPU · 8GB · 50GB   VM 8012
├── url-shortener-worker-4  worker          4 vCPU · 8GB · 50GB   VM 8013
└── url-shortener-worker-5  worker          4 vCPU · 8GB · 50GB   VM 8014

testing (VLAN 216 · 10.0.216.0/24)
├── testing-cp-1            control plane   2 vCPU · 2GB · 20GB   VM 9000
├── testing-cp-2            control plane   2 vCPU · 2GB · 20GB   VM 9001
├── testing-cp-3            control plane   2 vCPU · 2GB · 20GB   VM 9002
├── testing-worker-1        worker          2 vCPU · 4GB · 30GB   VM 9010
├── testing-worker-2        worker          2 vCPU · 4GB · 30GB   VM 9011
└── testing-worker-3        worker          2 vCPU · 4GB · 30GB   VM 9012
```

## Structure

```
infra/
├── modules/
│   └── talos-cluster/       # Reusable cluster module
│       ├── variables.tf
│       ├── versions.tf
│       ├── image.tf          # Talos image from factory.talos.dev
│       ├── vms.tf            # Proxmox VMs
│       ├── talos.tf          # Machine config + bootstrap
│       └── outputs.tf        # kubeconfig, talosconfig
└── environments/
    ├── production/           # url-shortener cluster (independent state)
    └── testing/              # testing cluster (independent state)
```

## Usage

Each environment has its own Terraform state and is managed independently.

```bash
# Production
cd environments/production
cp terraform.tfvars.example terraform.tfvars  # fill in Proxmox credentials
terraform init
terraform apply

terraform output -raw kubeconfig > ~/.kube/config
terraform output -raw talosconfig > ~/.talos/config
kubectl get nodes
```

```bash
# Testing — step 1: provision cluster (requires VLAN 216 pre-configured on Proxmox)
cd environments/testing
cp terraform.tfvars.example terraform.tfvars  # fill in Proxmox credentials
terraform init
terraform apply

terraform output -raw kubeconfig > ~/.kube/config-testing
terraform output -raw talosconfig > ~/.talos/config-testing
kubectl --kubeconfig ~/.kube/config-testing get nodes
```

```bash
# Testing — step 2: import sealed-secrets key so ArgoCD can decrypt secrets
# Export the key from production first (one-time, store securely outside git):
kubectl get secret -n kube-system -l sealedsecrets.bitnami.com/sealed-secrets-key \
  -o yaml > sealed-secrets-key.yaml

# Import into testing cluster before ArgoCD deploys:
kubectl --kubeconfig ~/.kube/config-testing apply -f sealed-secrets-key.yaml
```

```bash
# Testing — step 3: bootstrap ArgoCD, then point it at the gitops testing branch
helm repo add argo https://argoproj.github.io/argo-helm
helm --kubeconfig ~/.kube/config-testing install argocd argo/argo-cd \
  --namespace argocd --create-namespace --version 9.4.2

kubectl --kubeconfig ~/.kube/config-testing apply \
  -f ../gitops/k8s/overlays/testing/app-of-apps-testing.yaml
# ArgoCD (testing) uses manual sync — trigger syncs deliberately, not automatically
```

## Prerequisites for Testing Cluster

Before running `terraform apply` on testing:
- VLAN 216 configured on Proxmox host bridge (`vmbr0`) and upstream switch/router
- Gateway `10.0.216.1` routable
- `testing` branch in gitops repo exists with MetalLB `peerAddress` updated to `10.0.216.1`

## Notes

**Shared Talos image:** Both environments download the same Talos image to `local:iso/` on
the Proxmox node. The module uses `overwrite = false` (never re-download) and
`overwrite_unmanaged = true` (adopt the file if it already exists from another environment).
No manual steps needed when provisioning a second cluster on the same Proxmox node.

**ArgoCD Kustomize overlays:** The testing cluster uses `--load-restrictor LoadRestrictionsNone`
to allow Kustomize to reference base resources from parent directories. This is configured in
`k8s/overlays/testing/apps/patches/argocd.yaml` and also patched into `argocd-cm` manually
during bootstrap before the first sync.

## Related

- [url-shortener](https://github.com/kerbatek/url-shortener) — app deployed on the production cluster
- [gitops](https://github.com/kerbatek/gitops) — ArgoCD apps and Helm charts
