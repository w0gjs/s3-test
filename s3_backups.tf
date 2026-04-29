# S3 Bucket for backups
resource "aws_s3_bucket" "backups" {
  bucket = "${local.bucket_prefix}-backups"

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-backups" }
  )
}

# Enable versioning for backups bucket
resource "aws_s3_bucket_versioning" "backups" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption for backups bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
    bucket_key_enabled = true
  }
}

# Block public access for backups bucket
resource "aws_s3_bucket_public_access_block" "backups" {
  bucket = aws_s3_bucket.backups.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for backups bucket
resource "aws_s3_bucket_lifecycle_configuration" "backups" {
  bucket = aws_s3_bucket.backups.id

  rule {
    id     = "archive-old-backups"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    transition {
      days          = 180
      storage_class = "DEEP_ARCHIVE"
    }

    expiration {
      days = local.log_expiration_days.backup  # 7 years
    }
  }
}

# Bucket logging for backups
resource "aws_s3_bucket_logging" "backups" {
  bucket = aws_s3_bucket.backups.id

  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "backups-bucket-logs/"
}

# Enable MFA delete for backups
resource "aws_s3_bucket_versioning" "backups_mfa" {
  bucket = aws_s3_bucket.backups.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"  # Enable if MFA is configured
  }
}
