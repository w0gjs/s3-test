locals {
  common_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Project     = var.project_name
    CreatedAt   = timestamp()
  }

  bucket_prefix = "${var.project_name}-${var.environment}"

  log_expiration_days = {
    audit     = 90
    compliance = 365
    backup    = 2555  # 7 years for compliance
    athena    = 30
  }
}
