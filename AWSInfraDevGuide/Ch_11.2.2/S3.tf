resource "aws_s3_bucket" "S3Bucket_EB" {
  bucket = "ib07441-s3bucket-eb"
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "IB07441-S3Bucket-ElasticBeanstalk"
  }
}

resource "aws_s3_bucket_object" "S3_Bucket_Object" {
  bucket = aws_s3_bucket.S3Bucket_EB.id
  key    = "beanstalk/beanstalk.zip"
  source = "./source_code/beanstalk.zip"

  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5("./source_code/beanstalk.zip")
}

resource "aws_s3_bucket" "S3Bucket_Artifact" {
  bucket = "ib07441-awsinfradevguide"
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "IB07441_S3_Bucket_AWSInfraDevGuide"
    Environment = "Dev"
  }
}