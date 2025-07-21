resource "aws_s3_bucket" "versioned" {
  bucket = "jvernet-terraform-example"
  tags = {
    Name        = "terraform-example-bucket"
    Environment = "dev"
  }
}

resource "aws_s3_bucket_acl" "versioned_acl" {
  bucket = aws_s3_bucket.versioned.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "versioned" {
  bucket = aws_s3_bucket.versioned.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "versioned_sse" {
  bucket = aws_s3_bucket.versioned.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
