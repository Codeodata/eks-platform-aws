# ADR 004: Nginx Ingress Controller sobre AWS ALB Ingress Controller

## Estado
Aceptado

## Contexto
Necesitábamos un punto de entrada HTTP/HTTPS para los servicios del cluster con soporte para routing avanzado.

## Decisión
Elegimos **Nginx Ingress Controller** sobre AWS Load Balancer Controller (ALB).

## Consecuencias

### Por qué Nginx Ingress
- **Rate limiting nativo**: `nginx.ingress.kubernetes.io/limit-rps` sin WAF adicional
- **Rewrite rules**: transformación de paths sin Lambda@Edge
- **Canary deployments**: tráfico porcentual entre versiones vía annotations
- **Portabilidad**: misma configuración funciona en cualquier cloud o on-prem
- **Costo**: un solo NLB para todo el cluster vs un ALB por Ingress resource

### Costo comparativo
| Solución | Costo base/mes |
|---|---|
| Nginx + 1 NLB | ~$16/mes |
| ALB Ingress (1 ALB por servicio expuesto, 5 servicios) | ~$80-100/mes |

### Trade-offs aceptados
- Sin integración nativa con AWS WAF y ACM (requiere configuración manual)
- Gestión manual de TLS renewal con cert-manager
- ALB tiene mejor integración con Cognito para autenticación

### Cuándo elegiríamos ALB Ingress
- Necesidad de integración nativa con AWS WAF
- Autenticación via Cognito en el ingress
- Equipos que prefieren reducir componentes a mantener en el cluster
