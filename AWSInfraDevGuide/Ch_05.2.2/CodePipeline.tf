resource "aws_codepipeline" "CodePipeline" {
  name     = "IB07441-CodePipeline"
  role_arn = aws_iam_role.IamRole_PipelineTrustRole.arn

  artifact_store {
    location = aws_s3_bucket.S3Bucket.bucket
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
        Branch      = "CodeDeploy"
        OAuthToken  = "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"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["source_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.Codedeploy_App.name
        DeploymentGroupName = aws_codedeploy_deployment_group.Codedeploy_Deployment_Group.deployment_group_name
      }
    }
  }
}