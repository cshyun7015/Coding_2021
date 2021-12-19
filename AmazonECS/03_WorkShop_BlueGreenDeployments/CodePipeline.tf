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
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        RepositoryName  = aws_codecommit_repository.Codecommit_Repository.repository_name
        BranchName      = "master"
        PollForSourceChanges = false
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts = ["source_output"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.Coldbuild_Project.name
      }
    }
  }

  stage {
    name = "Deploy_Staging"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeployToECS"
      input_artifacts = ["build_output"]
      version         = "1"

      configuration = {
        ApplicationName = aws_codedeploy_app.CodedeployApp.name
        DeploymentGroupName = aws_codedeploy_deployment_group.CodedeployDeploymentGroup-Staging.deployment_group_name
        TaskDefinitionTemplateArtifact = "build_output"
        AppSpecTemplateArtifact = "build_output"
      }
    }
  }
}