data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_repository" "EcrRepository" {
  name                 = "ib07441-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output "ecrrepository" {
  value = aws_ecr_repository.EcrRepository.arn
}