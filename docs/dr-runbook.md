# DR Runbook — EKS Platform AWS

## Objetivos de Recuperación

| Métrica | Target | Justificación |
|---|---|---|
| **RTO** (Recovery Time Objective) | 45 minutos | Tiempo de recreación completa con Terraform |
| **RPO** (Recovery Point Objective) | 1 hora | Frecuencia de backup de PersistentVolumes |

---

## Escenarios de Falla y Procedimiento

### Escenario 1: Falla de un Node Group

**Impacto:** Pods reprogramados automáticamente por el scheduler de Kubernetes.
**RTO:** 0 minutos (automático).

```bash
# Verificar que los pods se reprogramaron correctamente
kubectl get pods --all-namespaces -o wide

# Si quedan pods en Pending, verificar recursos disponibles
kubectl describe pod <pod-name> -n <namespace>
```

**Detección:** Alerta de Prometheus `KubeNodeNotReady`.

---

### Escenario 2: Falla del Control Plane EKS

**Impacto:** API de Kubernetes no disponible. Workloads existentes siguen corriendo.
**RTO:** 15-30 minutos (AWS recrea el control plane automáticamente en Multi-AZ).

```bash
# Verificar estado del cluster
aws eks describe-cluster --name <cluster-name> --query 'cluster.status'

# Si persiste, recrear con Terraform
terraform apply -target=module.eks
```

---

### Escenario 3: Pérdida completa del cluster

**RTO:** ~45 minutos.
**RPO:** Última snapshot de EBS / último backup de Velero.

**Procedimiento:**
```bash
# 1. Verificar que el Terraform state en S3 está intacto
aws s3 ls s3://<tfstate-bucket>/

# 2. Recrear infraestructura completa
terraform init
terraform apply

# 3. Restaurar workloads desde Velero (si está configurado)
velero restore create --from-backup <backup-name>

# 4. Verificar que todos los servicios están healthy
kubectl get pods --all-namespaces
kubectl get ingress --all-namespaces
```

---

### Escenario 4: Corrupción del Terraform State

**RTO:** 30-60 minutos.

```bash
# 1. Acceder al backup automático en S3 (versioning habilitado)
aws s3api list-object-versions \
  --bucket <tfstate-bucket> \
  --prefix terraform.tfstate

# 2. Restaurar versión anterior
aws s3api get-object \
  --bucket <tfstate-bucket> \
  --key terraform.tfstate \
  --version-id <version-id> \
  terraform.tfstate.backup
```

---

## Estrategia de Backup

| Componente | Método | Frecuencia | Retención |
|---|---|---|---|
| Terraform State | S3 + versioning | Continuo | 30 días |
| PersistentVolumes | EBS Snapshots via Data Lifecycle Manager | Cada hora | 7 días |
| Kubernetes manifests | Git (este repo) | Cada commit | Indefinido |
| Secrets | AWS Secrets Manager | Managed | Indefinido |

---

## Checklist post-recuperación

- [ ] Todos los nodos en estado `Ready`
- [ ] Todos los pods en `Running` o `Completed`
- [ ] Ingress respondiendo (`curl -I https://<ingress-url>`)
- [ ] Métricas visibles en Grafana
- [ ] Alertmanager recibiendo métricas de Prometheus
- [ ] Logs llegando a CloudWatch (si configurado)
- [ ] Certificados TLS válidos

---

## Contactos de escalación

| Nivel | Condición | Canal |
|---|---|---|
| L1 | RTO > 15 min | Slack #ops-alerts |
| L2 | RTO > 30 min | PagerDuty on-call |
| L3 | Pérdida de datos | Escalación a AWS Support |
