# Cost Estimate — EKS Platform AWS

Estimación basada en región `us-east-1`. Actualizar según región de deployment.

---

## Desglose mensual

### Compute

| Componente | Tipo | Cantidad | Costo/mes |
|---|---|---|---|
| EKS Control Plane | Managed | 1 cluster | $73.00 |
| Node Group — t3.medium | On-Demand | 2 nodos | $60.74 |
| Node Group — t3.medium | Reserved (1yr) | 2 nodos | ~$38.00 |

> **Ahorro con Reserved Instances:** ~$22/mes (~37%)

### Networking

| Componente | Detalle | Costo/mes |
|---|---|---|
| NAT Gateway | 1 por AZ × 2 AZs | $64.80 |
| NAT Gateway — Data | ~100 GB/mes estimado | $4.50 |
| NLB (Nginx Ingress) | 1 NLB | $16.20 |
| Data Transfer Out | ~50 GB/mes estimado | $4.50 |

### Storage

| Componente | Detalle | Costo/mes |
|---|---|---|
| EBS gp3 (nodos) | 2 × 20 GB | $3.20 |
| S3 (Terraform state) | < 1 GB | $0.02 |
| EBS Snapshots (DR) | ~40 GB snapshots | $2.00 |

### Observabilidad

| Componente | Detalle | Costo/mes |
|---|---|---|
| CloudWatch Logs | Mínimo (solo system logs) | $2.00 |
| Prometheus storage (EBS) | 10 GB gp3 | $0.80 |

---

## Totales

| Escenario | Costo/mes | Costo/año |
|---|---|---|
| **Dev** (on-demand, 1 AZ) | ~$165 | ~$1,980 |
| **Prod** (on-demand, 2 AZs) | ~$232 | ~$2,784 |
| **Prod optimizado** (Reserved 1yr, Savings Plan) | ~$180 | ~$2,160 |

---

## Optimizaciones implementadas

1. **Karpenter / Cluster Autoscaler**: escala nodos a 0 fuera de horario → ahorro ~40% en dev
2. **Spot Instances para nodos no-críticos**: hasta 70% de ahorro en node groups de batch
3. **NAT Gateway por AZ**: evita cross-AZ charges ($0.01/GB) entre pods y NAT
4. **S3 + Lifecycle**: Terraform state con lifecycle de 30 días en IA tier

## Optimizaciones recomendadas (no implementadas)

- [ ] Compute Savings Plan (1yr) → ahorro adicional ~20%
- [ ] Graviton instances (t4g.medium) → mismo precio, ~20% mejor performance
- [ ] Karpenter para consolidación agresiva de nodos → ahorro ~30%

---

## Herramientas de cost monitoring

```bash
# Ver costos actuales por servicio
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --metrics BlendedCost \
  --group-by Type=DIMENSION,Key=SERVICE

# Tag todos los recursos del cluster para tracking
aws eks list-clusters
```

> Referencia: [AWS Pricing Calculator](https://calculator.aws/pricing/2/home)
