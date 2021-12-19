resource "aws_codedeploy_app" "CodedeployApp" {
  name             = "IB07441-DevOps-TCL"
  compute_platform = "ECS"
}

resource "aws_codedeploy_deployment_group" "CodedeployDeploymentGroup-Staging" {
  app_name              = aws_codedeploy_app.CodedeployApp.name
  deployment_group_name = "IB07441-CodedeployDeploymentGroup-Staging"
  service_role_arn      = aws_iam_role.IamRole_CodeDeployECSTrustRole.arn
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  
  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }

    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 2
    }
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  ecs_service {
    cluster_name = aws_ecs_cluster.Ecs_Cluster.name
    service_name = aws_ecs_service.Ecs_Service.name
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.Lb_Listener_Staging_Blue.arn]
      }
      test_traffic_route {
        listener_arns = [aws_lb_listener.Lb_Listener_Staging_Green.arn]
      }

      target_group {
        name = aws_lb_target_group.Lb_TargetGroup_Staging_Blue.name
      }
      target_group {
        name = aws_lb_target_group.Lb_TargetGroup_Staging_Green.name
      }
    }
  }
}