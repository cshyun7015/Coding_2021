resource "aws_codebuild_project" "Coldbuild_Project" {
  name          = "IB07441-Codebuild-project"
  description   = "codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.IamRole_CodeBuildTrustRole.arn

  artifacts {
    type = "CODEPIPELINE"
    name = "output"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/docker:1.12.1"
    type  = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      name  = "REPOSITORY_NAME"
      value = aws_ecr_repository.EcrRepository.name
    }
    environment_variable {
      name  = "REPOSITORY_URI"
      value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${aws_ecr_repository.EcrRepository.name}"
    }
    environment_variable {
      name  = "TASK_EXECUTION_ARN"
      value = aws_iam_role.IamRole_EcsTaskTrustRole.arn
    }
    environment_variable {
      name  = "TASK_FAMILY"
      value = "IB07441-Family"
    }

  }

  source {
    type            = "CODEPIPELINE"
    buildspec       = "buildspec.yml"
  }

  tags = {
    Name        = "IB07441-Codebuild-project"
    Environment = "Test"
  }
}