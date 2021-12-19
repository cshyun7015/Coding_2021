resource "aws_codedeploy_app" "Codedeploy_App" {
  name             = "IB07441-Exercise"
  compute_platform = "Server"
}

resource "aws_codedeploy_deployment_group" "Codedeploy_Deployment_Group" {
  app_name              = aws_codedeploy_app.Codedeploy_App.name

  deployment_group_name = "IB07441-CodedeployDeploymentGroup-in_place"

  service_role_arn      = aws_iam_role.IamRole_CodeDeployTrustRole.arn
  
  autoscaling_groups = [aws_autoscaling_group.AutoscalingGroup_Green.name]

  deployment_config_name = "CodeDeployDefault.OneAtATime"

  load_balancer_info {
    target_group_info {
      name = aws_lb_target_group.Lb_TargetGroup.name
    }
  }
}
