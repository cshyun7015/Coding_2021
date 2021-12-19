resource "aws_dynamodb_table" "Dynamodb-Table" {
  name           = "IB07441-Rides"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "RideId"

  attribute {
    name = "RideId"
    type = "S"
  }

  tags = {
    Name        = "IB07441-Rides"
    Environment = "Test"
  }
}