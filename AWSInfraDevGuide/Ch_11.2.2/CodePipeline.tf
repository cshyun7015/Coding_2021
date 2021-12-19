resource "aws_codepipeline" "CodePipeline" {
  name     = "IB07441-CodePipeline"
  role_arn = aws_iam_role.IamRole_PipelineTrustRole.arn

  artifact_store {
    location = aws_s3_bucket.S3Bucket_Artifact.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        Owner       = "cshyun7015"
        Repo        = "AWSInfraDevGuide"
        Branch      = "ElasticBeanstalk"
        OAuthToken  = "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"
      }
    }
  }

  stage {
    name = "Approval"

    action {
      name            = "Approval"
      category        = "Approval"
      owner           = "AWS"
      provider        = "Manual"
      version         = "1"

      configuration = {
        CustomData = "Comments on the manual approval"
        NotificationArn = aws_sns_topic.SnsTopic.arn
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ElasticBeanstalk"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_elastic_beanstalk_application.Elastic_Beanstalk_Application.name
        EnvironmentName = aws_elastic_beanstalk_environment.Elastic_Beanstalk_Environment.name
      }
    }
  }

  stage {
    name = "Notify"

    action {
      name            = "Notify-Deploy-Success"
      category        = "Invoke"
      owner           = "AWS"
      provider        = "Lambda"
      version         = "1"

      configuration = {
        FunctionName = aws_lambda_function.Lambda_Function.function_name
        UserParameters = "코드 파이프라인 알림"
      }
    }
  }

}