# S3 Bucket for compliance records
resource "aws_s3_bucket" "compliance" {
  bucket = "${local.bucket_prefix}-compliance"

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-compliance" }
  )
}

# Enable versioning for compliance bucket
resource "aws_s3_bucket_versioning" "compliance" {
  bucket = aws_s3_bucket.compliance.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"
  }
}

# Server-side encryption for compliance bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "compliance" {
  bucket = aws_s3_bucket.compliance.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
    bucket_key_enabled = true
  }
}

# Block public access for compliance bucket
resource "aws_s3_bucket_public_access_block" "compliance" {
  bucket = aws_s3_bucket.compliance.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for compliance bucket
resource "aws_s3_bucket_lifecycle_configuration" "compliance" {
  bucket = aws_s3_bucket.compliance.id

  rule {
    id     = "archive-old-compliance-records"
    status = "Enabled"

    transition {
      days          = 90
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 180
      storage_class = "GLACIER"
    }

    expiration {
      days = local.log_expiration_days.compliance
    }
  }
}

# Bucket logging for compliance
resource "aws_s3_bucket_logging" "compliance" {
  bucket = aws_s3_bucket.compliance.id

  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "compliance-bucket-logs/"
}
