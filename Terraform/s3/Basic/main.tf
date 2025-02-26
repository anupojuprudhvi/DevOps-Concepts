# Create an S3 Bucket
resource "aws_s3_bucket" "example" {
  bucket = var.bucket_name

  tags = merge(var.default_tags, { Name = var.bucket_name })
}

# Enable Versioning (Optional)
resource "aws_s3_bucket_versioning" "example" {
  bucket = aws_s3_bucket.example.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable Server-Side Encryption (Optional)
resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
  bucket = aws_s3_bucket.example.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}