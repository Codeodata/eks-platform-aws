# ADR 003: Prometheus + Grafana sobre CloudWatch para observabilidad

## Estado
Aceptado

## Contexto
Necesitábamos observabilidad completa del cluster: métricas de nodos, pods, deployments y aplicaciones custom.

## Decisión
Elegimos **Prometheus + Grafana** sobre Amazon CloudWatch Container Insights.

## Consecuencias

### Por qué Prometheus + Grafana
- **PromQL**: lenguaje de queries mucho más expresivo que CloudWatch Metrics Math
- **Kubernetes-native**: kube-state-metrics expone métricas del control plane nativas
- **Costo predecible**: costo fijo de recursos del cluster vs CloudWatch a $0.30/métrica/mes
- **Alerting flexible**: Alertmanager con routing a Slack, PagerDuty, Telegram
- **Dashboards portables**: JSON exportable, community dashboards en grafana.com

### Costo comparativo (cluster con 10 nodos, 50 pods)
| Solución | Costo estimado/mes |
|---|---|
| CloudWatch Container Insights | ~$80-120/mes |
| Prometheus + Grafana (en cluster) | ~$15-20/mes (recursos EC2) |

### Trade-offs aceptados
- Requiere gestionar el storage (PersistentVolume para Prometheus)
- Retención limitada por disco vs CloudWatch (15 meses de retención managed)
- Necesidad de hacer backup de datos de métricas si se requiere larga retención

### Cuándo elegiríamos CloudWatch
- Equipos sin experiencia en Prometheus/PromQL
- Necesidad de retención larga (>1 año) sin gestión de storage
- Integración nativa con AWS X-Ray para trazas distribuidas
