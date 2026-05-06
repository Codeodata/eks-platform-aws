# ADR 001: EKS sobre ECS para orquestación de contenedores

## Estado
Aceptado

## Contexto
Necesitábamos una plataforma de orquestación de contenedores en producción con capacidad multi-tenant, observabilidad avanzada y portabilidad entre clouds.

## Decisión
Elegimos **Amazon EKS** sobre Amazon ECS.

## Consecuencias

### Por qué EKS
- **Portabilidad**: workloads pueden migrar a GKE/AKS sin reescribir manifests
- **Ecosistema**: Helm, Argo CD, Keda, Karpenter — no disponibles nativamente en ECS
- **Kubernetes-native observability**: Prometheus + Grafana con métricas de kube-state-metrics
- **RBAC granular**: control de acceso por namespace/serviceaccount
- **Standard de industria**: habilidad buscada en Cloud/Platform Engineers

### Trade-offs aceptados
- Mayor complejidad operacional vs ECS Fargate
- Control plane cost: $0.10/hora (~$73/mes) vs ECS ($0)
- Curva de aprendizaje más alta para el equipo

### Cuándo elegiríamos ECS en su lugar
- Equipos sin experiencia en Kubernetes
- Workloads simples sin necesidad de ecosistema K8s
- Presupuesto muy ajustado (ahorro de ~$73/mes en control plane)
