data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_ecr_repository" "EcrRepository" {
  name                 = "ib07441-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # provisioner "local-exec" {
  #   command = "eval '$(aws ecr get-login --region ap-northeast-2 --no-include-email)'"
  # }
  # provisioner "local-exec" {
  #   command = "docker tag helloworld:latest ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.EcrRepository.name}:latest"
  # }
  # provisioner "local-exec" {
  #   command = "docker push ${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.EcrRepository.name}:latest"
  # }
}

output "ecrrepository" {
  value = aws_ecr_repository.EcrRepository.arn
}