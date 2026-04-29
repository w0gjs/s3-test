output "main_bucket_id" {
  description = "Main S3 bucket ID"
  value       = aws_s3_bucket.main.id
}

output "main_bucket_arn" {
  description = "Main S3 bucket ARN"
  value       = aws_s3_bucket.main.arn
}

output "audit_logs_bucket_id" {
  description = "Audit logs S3 bucket ID"
  value       = aws_s3_bucket.audit_logs.id
}

output "audit_logs_bucket_arn" {
  description = "Audit logs S3 bucket ARN"
  value       = aws_s3_bucket.audit_logs.arn
}

output "compliance_bucket_id" {
  description = "Compliance S3 bucket ID"
  value       = aws_s3_bucket.compliance.id
}

output "compliance_bucket_arn" {
  description = "Compliance S3 bucket ARN"
  value       = aws_s3_bucket.compliance.arn
}

output "records_bucket_id" {
  description = "Records S3 bucket ID"
  value       = aws_s3_bucket.records.id
}

output "records_bucket_arn" {
  description = "Records S3 bucket ARN"
  value       = aws_s3_bucket.records.arn
}

output "aml_bucket_id" {
  description = "AML S3 bucket ID"
  value       = aws_s3_bucket.aml.id
}

output "aml_bucket_arn" {
  description = "AML S3 bucket ARN"
  value       = aws_s3_bucket.aml.arn
}

output "backups_bucket_id" {
  description = "Backups S3 bucket ID"
  value       = aws_s3_bucket.backups.id
}

output "backups_bucket_arn" {
  description = "Backups S3 bucket ARN"
  value       = aws_s3_bucket.backups.arn
}

output "athena_bucket_id" {
  description = "Athena results S3 bucket ID"
  value       = aws_s3_bucket.athena.id
}

output "athena_bucket_arn" {
  description = "Athena results S3 bucket ARN"
  value       = aws_s3_bucket.athena.arn
}

output "kms_key_id" {
  description = "KMS key ID for S3 encryption"
  value       = aws_kms_key.s3_key.id
}

output "kms_key_arn" {
  description = "KMS key ARN"
  value       = aws_kms_key.s3_key.arn
}

output "kms_key_alias" {
  description = "KMS key alias"
  value       = aws_kms_alias.s3_key_alias.name
}

output "all_buckets" {
  description = "All S3 buckets"
  value = {
    main       = aws_s3_bucket.main.id
    audit_logs = aws_s3_bucket.audit_logs.id
    compliance = aws_s3_bucket.compliance.id
    records    = aws_s3_bucket.records.id
    aml        = aws_s3_bucket.aml.id
    backups    = aws_s3_bucket.backups.id
    athena     = aws_s3_bucket.athena.id
  }
}
