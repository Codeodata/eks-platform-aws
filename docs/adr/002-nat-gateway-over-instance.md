# ADR 002: NAT Gateway managed sobre NAT Instance

## Estado
Aceptado

## Contexto
Las instancias en subnets privadas necesitan acceso a internet para pull de imágenes, actualizaciones y llamadas a APIs externas.

## Decisión
Elegimos **NAT Gateway** (managed) sobre NAT Instance (self-managed).

## Consecuencias

### Por qué NAT Gateway
- **Alta disponibilidad**: managed por AWS, sin single point of failure
- **Auto-scaling**: escala bandwidth automáticamente hasta 45 Gbps
- **Sin mantenimiento**: no hay OS patching, no hay monitoring de instancia
- **Multi-AZ**: un NAT Gateway por AZ elimina cross-AZ traffic costs

### Trade-offs aceptados
- Costo: ~$32/mes por AZ vs ~$4/mes para t3.nano NAT Instance
- Sin capacidad de usar como bastion host (feature de NAT Instance)

### Cuándo elegiríamos NAT Instance
- Ambientes dev/sandbox con presupuesto < $10/mes
- Necesidad de port forwarding o bastion integrado
- Workloads con muy bajo volumen de tráfico saliente
