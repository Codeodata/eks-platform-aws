# EKS Platform AWS — Infraestructura Kubernetes en AWS

Infraestructura como código (IaC) para desplegar un cluster Kubernetes en AWS EKS, con VPC, networking, observabilidad y Nginx Ingress Controller. Todo gestionado con Terraform.

## Stack

- **Orquestación:** AWS EKS (Kubernetes 1.32)
- **Networking:** VPC, subnets públicas/privadas, NAT Gateway
- **Ingress:** Nginx Ingress Controller
- **Observabilidad:** Prometheus + Grafana (opcional)
- **IaC:** Terraform modular

## Estructura

```
eks-platform-aws/
├── main.tf              # Módulos principales
├── provider.tf          # AWS provider config
├── variables.tf         # Variables de entrada
├── versions.tf          # Versiones de providers
├── observability.tf     # Stack de monitoreo (opcional)
├── modules/
│   ├── vpc/             # VPC, subnets, routing
│   ├── eks/             # Cluster EKS y node groups
│   ├── monitoring/      # Prometheus + Grafana
│   └── nginx/           # Nginx Ingress Controller
└── terraform.tfvars.example
```

## Variables principales

```hcl
aws_region           = "us-east-1"
deploy_observability = false      # true para activar Prometheus/Grafana
grafana_admin_password = "..."    # Solo si deploy_observability = true
```

## Uso

```bash
# Inicializar
terraform init

# Planificar
terraform plan -var-file=terraform.tfvars

# Aplicar
terraform apply -var-file=terraform.tfvars
```

## Configurar kubectl

```bash
aws eks update-kubeconfig --name <cluster-name> --region us-east-1
kubectl get nodes
```

## Módulos

| Módulo | Descripción |
|--------|-------------|
| `vpc` | VPC con subnets públicas y privadas, IGW, NAT Gateway |
| `eks` | Cluster EKS con managed node groups |
| `nginx` | Nginx Ingress Controller via Helm |
| `monitoring` | Prometheus + Grafana con dashboards precargados |

## Notas de seguridad

- El archivo `terraform.tfvars` no se versiona (contiene valores de producción)
- El `terraform.tfstate` tampoco — usar S3 backend para equipos
- Las credenciales de AWS deben configurarse via `aws configure` o roles IAM
