resource "aws_codedeploy_app" "CodedeployApp" {
  name             = "IB07441-Exercise"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "CodedeployDeploymentGroup" {
  app_name              = aws_codedeploy_app.CodedeployApp.name

  deployment_group_name = "IB07441-CodedeployDeploymentGroup-in_place"

  service_role_arn      = aws_iam_role.IamRole_CodeDeployTrustRole.arn
  
  autoscaling_groups = [aws_autoscaling_group.AutoscalingGroup.name]

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  load_balancer_info {
    elb_info {
      name = aws_lb.Lb.name
    }
  }
}
