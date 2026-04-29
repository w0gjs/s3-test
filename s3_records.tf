# S3 Bucket for records storage
resource "aws_s3_bucket" "records" {
  bucket = "${local.bucket_prefix}-records"

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-records" }
  )
}

# Enable versioning for records bucket
resource "aws_s3_bucket_versioning" "records" {
  bucket = aws_s3_bucket.records.id

  versioning_configuration {
    status     = "Enabled"
  }
}

# Server-side encryption for records bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "records" {
  bucket = aws_s3_bucket.records.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
    bucket_key_enabled = true
  }
}

# Block public access for records bucket
resource "aws_s3_bucket_public_access_block" "records" {
  bucket = aws_s3_bucket.records.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable object lock (WORM - Write Once Read Many)
resource "aws_s3_bucket_object_lock_configuration" "records" {
  bucket = aws_s3_bucket.records.id

  rule {
    default_retention {
      mode = "GOVERNANCE"
      days = 30
    }
  }
}

# Bucket logging for records
resource "aws_s3_bucket_logging" "records" {
  bucket = aws_s3_bucket.records.id

  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "records-bucket-logs/"
}
