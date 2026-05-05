variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "deploy_observability" {
  description = "Whether to deploy observability stack (Prometheus, Grafana)"
  type        = bool
  default     = false
}

variable "grafana_admin_password" {
  description = "Admin password for Grafana"
  type        = string
  default     = "admin"
  sensitive   = true
}