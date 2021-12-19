data "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
}
data "aws_caller_identity" "current" {}

#Step 1: Create a Task Definition
resource "aws_ecs_task_definition" "Ecs_Task_Definition" {
  family = "IB07441-Family"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn = aws_iam_role.IamRole_EcsTaskTrustRole.arn
  cpu       = 256
  memory    = 1024
  container_definitions = jsonencode([
# {
#     "family": "ib07441",
#         "networkMode": "awsvpc",
#         "containerDefinitions": [
            {
                "name": "ib07441-app",
                "image": "httpd:2.4",
                "portMappings": [
                    {
                        "containerPort": 80,
                        "hostPort": 80,
                        "protocol": "tcp"
                    }
                ],
                "essential": true,
                "entryPoint": [
                    "sh",
                    "-c"
                ],
                "command": [
                    "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
                ]
            }
        # ],
        # "requiresCompatibilities": [
        #     "FARGATE"
        # ],
        # # "cpu": 256,
        # # "memory": 512,
        # "executionRoleArn": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/ecsTaskExecutionRole"
# }
  ])
}

#Step 2: Configure the Service
resource "aws_ecs_service" "Ecs_Service" {
  name            = "ib07441_ecs_service"
  cluster         = aws_ecs_cluster.Ecs_Cluster.id
  task_definition = aws_ecs_task_definition.Ecs_Task_Definition.arn
  desired_count   = 1
  launch_type = "FARGATE"
  scheduling_strategy = "REPLICA"
  platform_version = "LATEST"

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.Lb_TargetGroup_Staging_Blue.arn
    container_name = "ib07441-app"
    container_port = 80
  }
  # load_balancer {
  #   target_group_arn = aws_lb_target_group.Lb_TargetGroup_Staging_Green.arn
  #   container_name = "IB07441-Family"
  #   container_port = 8080
  # }

  network_configuration {
    #subnets = [aws_subnet.Subnet_DEV_Private01.id, aws_subnet.Subnet_DEV_Private02.id, aws_subnet.Subnet_DEV_Private03.id]
    subnets = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id, aws_subnet.Subnet_DEV_Public03.id]
    security_groups = [aws_security_group.SecurityGroup_DEV_Private.id]
    assign_public_ip = true
  }
}

#Step 3: Configure the Cluster
resource "aws_ecs_cluster" "Ecs_Cluster" {
  name = "ib07441-ecs-cluster"
}