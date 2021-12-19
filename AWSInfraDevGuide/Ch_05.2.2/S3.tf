resource "aws_s3_bucket" "S3Bucket" {
  bucket = "ib07441-effectivedevopswithaws2e"
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "IB07441_S3_Bucket"
    Environment = "Dev"
  }
}