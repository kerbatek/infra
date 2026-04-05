# infra

Terraform for Talos Linux Kubernetes clusters on Proxmox, using a shared module for consistent cluster definitions.

## Clusters

```
production (3 control planes, 3 workers, API VIP 10.0.217.5/32)
├── url-shortener-cp-1      control plane   4 vCPU · 6GB · 30GB   VM 8000   VLAN 2171   10.0.217.1/31   gw 10.0.217.0   ASN 65201
├── url-shortener-cp-2      control plane   4 vCPU · 6GB · 30GB   VM 8001   VLAN 2172   10.0.217.3/31   gw 10.0.217.2   ASN 65202
├── url-shortener-cp-3      control plane   4 vCPU · 6GB · 30GB   VM 8002   VLAN 2173   10.0.217.7/31   gw 10.0.217.6   ASN 65203
├── url-shortener-worker-1  worker          4 vCPU · 8GB · 50GB   VM 8010   VLAN 2174   10.0.217.9/31   gw 10.0.217.8   ASN 65204
├── url-shortener-worker-2  worker          4 vCPU · 8GB · 50GB   VM 8011   VLAN 2175   10.0.217.11/31  gw 10.0.217.10  ASN 65205
└── url-shortener-worker-3  worker          4 vCPU · 8GB · 50GB   VM 8012   VLAN 2176   10.0.217.13/31  gw 10.0.217.12  ASN 65206

testing (3 control planes, 3 workers, API VIP 10.0.216.5/32)
├── testing-cp-1            control plane   3 vCPU · 6GB · 20GB   VM 9000   VLAN 2161   10.0.216.1/31   gw 10.0.216.0   ASN 65101
├── testing-cp-2            control plane   3 vCPU · 6GB · 20GB   VM 9001   VLAN 2162   10.0.216.3/31   gw 10.0.216.2   ASN 65102
├── testing-cp-3            control plane   3 vCPU · 6GB · 20GB   VM 9002   VLAN 2163   10.0.216.7/31   gw 10.0.216.6   ASN 65103
├── testing-worker-1        worker          2 vCPU · 4GB · 30GB   VM 9010   VLAN 2164   10.0.216.9/31   gw 10.0.216.8   ASN 65104
├── testing-worker-2        worker          2 vCPU · 4GB · 30GB   VM 9011   VLAN 2165   10.0.216.11/31  gw 10.0.216.10  ASN 65105
└── testing-worker-3        worker          2 vCPU · 4GB · 30GB   VM 9012   VLAN 2166   10.0.216.13/31  gw 10.0.216.12  ASN 65106
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
# Testing — step 1: provision cluster (requires routed /31 links pre-configured on Proxmox and MikroTik)
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

## Network Prerequisites

Before running `terraform apply` for either environment:

- Proxmox host bridge (`vmbr0`) and the upstream switch/router must carry the per-node VLANs for that environment
- The MikroTik must provide one SVI gateway per node and one eBGP session per node
- The environment API VIP is a Cilium-managed `/32`, not a router SVI and not a Talos interface VIP

Current environment allocations:

- Production VLANs `2171-2176`, MikroTik ASN `64513`, node ASNs `65201-65206`, API VIP `10.0.217.5/32`
- Testing VLANs `2161-2166`, MikroTik ASN `64513`, node ASNs `65101-65106`, API VIP `10.0.216.5/32`

## Notes

**Shared Talos image:** Both environments download the same Talos image to `local:iso/` on
the Proxmox node. The module uses `overwrite = false` (never re-download) and
`overwrite_unmanaged = true` (adopt the file if it already exists from another environment).
No manual steps needed when provisioning a second cluster on the same Proxmox node.

**ArgoCD Kustomize overlays:** The testing cluster uses `--load-restrictor LoadRestrictionsNone`
to allow Kustomize to reference base resources from parent directories. This is configured in
`k8s/overlays/testing/apps/patches/argocd.yaml` and also patched into `argocd-cm` manually
during bootstrap before the first sync.

**Cilium and API access model:** Both environments use routed `/31` node links, Cilium BGP,
and kubePrism for node-local API access. Terraform configures the node IPs, VLAN tags, and the
external cluster endpoint, while GitOps manages the corresponding Cilium BGP resources and the
Cilium-managed API VIP service.

## Related

- [gitops](https://github.com/kerbatek/gitops) — ArgoCD apps and Helm charts
- [portfolio](https://github.com/kerbatek/portfolio) — app deployed on the production cluster
