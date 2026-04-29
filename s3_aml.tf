# S3 Bucket for AML (Anti-Money Laundering) records
resource "aws_s3_bucket" "aml" {
  bucket = "${local.bucket_prefix}-aml"

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-aml" }
  )
}

# Enable versioning for AML bucket
resource "aws_s3_bucket_versioning" "aml" {
  bucket = aws_s3_bucket.aml.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption for AML bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "aml" {
  bucket = aws_s3_bucket.aml.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
    bucket_key_enabled = true
  }
}

# Block public access for AML bucket
resource "aws_s3_bucket_public_access_block" "aml" {
  bucket = aws_s3_bucket.aml.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for AML bucket (7-year retention for financial compliance)
resource "aws_s3_bucket_lifecycle_configuration" "aml" {
  bucket = aws_s3_bucket.aml.id

  rule {
    id     = "archive-aml-records"
    status = "Enabled"

    transition {
      days          = 365
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 730
      storage_class = "GLACIER"
    }

    expiration {
      days = local.log_expiration_days.backup  # 7 years
    }
  }
}

# Bucket logging for AML
resource "aws_s3_bucket_logging" "aml" {
  bucket = aws_s3_bucket.aml.id

  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "aml-bucket-logs/"
}

# Bucket policy for AML bucket - restrict access
resource "aws_s3_bucket_policy" "aml" {
  bucket = aws_s3_bucket.aml.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceKMSEncryption"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.aml.arn}/*"
        Condition = {
          StringNotEquals = {
            "s3:x-amz-server-side-encryption" = "aws:kms"
          }
        }
      }
    ]
  })
}
