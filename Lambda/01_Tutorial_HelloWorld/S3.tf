resource "aws_s3_bucket" "S3Bucket" {
  bucket = "ib07441-tutorial-lambda"
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

resource "aws_s3_bucket_object" "S3_Bucket_Object" {
 bucket = aws_s3_bucket.S3Bucket.id
 key    = "hello-world-python.zip"
 source = "./hello-world-python.zip"

 etag = filemd5("./hello-world-python.zip")
}