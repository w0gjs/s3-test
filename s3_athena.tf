# S3 Bucket for Athena query results
resource "aws_s3_bucket" "athena" {
  bucket = "${local.bucket_prefix}-athena-results"

  tags = merge(
    local.common_tags,
    { Name = "${var.project_name}-athena-results" }
  )
}

# Server-side encryption for Athena bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "athena" {
  bucket = aws_s3_bucket.athena.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = aws_kms_key.s3_key.arn
    }
    bucket_key_enabled = true
  }
}

# Block public access for Athena bucket
resource "aws_s3_bucket_public_access_block" "athena" {
  bucket = aws_s3_bucket.athena.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Lifecycle policy for Athena results (cleanup old query results)
resource "aws_s3_bucket_lifecycle_configuration" "athena" {
  bucket = aws_s3_bucket.athena.id

  rule {
    id     = "delete-old-athena-results"
    status = "Enabled"

    expiration {
      days = local.log_expiration_days.athena  # 30 days
    }
  }

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Bucket logging for Athena
resource "aws_s3_bucket_logging" "athena" {
  bucket = aws_s3_bucket.athena.id

  target_bucket = aws_s3_bucket.audit_logs.id
  target_prefix = "athena-bucket-logs/"
}

# Versioning disabled for Athena (temporary results)
resource "aws_s3_bucket_versioning" "athena" {
  bucket = aws_s3_bucket.athena.id

  versioning_configuration {
    status = "Suspended"
  }
}

# Bucket policy for Athena
resource "aws_s3_bucket_policy" "athena" {
  bucket = aws_s3_bucket.athena.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowAthenaAccess"
        Effect = "Allow"
        Principal = {
          Service = "athena.amazonaws.com"
        }
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.athena.arn}/*"
      }
    ]
  })
}
