#Step 1: Create a Task Definition
resource "aws_ecs_task_definition" "Ecs_Task_Definition" {
  family = "Ecs-Service"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = jsonencode([
    {
        "entryPoint": [
            "sh",
            "-c"
        ],
        "portMappings": [
            {
                "hostPort": 80,
                "protocol": "tcp",
                "containerPort": 80
            }
        ],
        "command": [
            "/bin/sh -c \"echo '<html> <head> <title>Amazon ECS Sample App</title> <style>body {margin-top: 40px; background-color: #333;} </style> </head><body> <div style=color:white;text-align:center> <h1>Amazon ECS Sample App</h1> <h2>Congratulations!</h2> <p>Your application is now running on a container in Amazon ECS.</p> </div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
        ],
        "image": "httpd:2.4",
        "name": "ib07441-app"
    }
  ])
  cpu = 256
  memory = 512
}

#Step 2: Configure the Service
resource "aws_ecs_service" "Ecs_Service" {
  name            = "ib07441_ecs_service"
  cluster         = aws_ecs_cluster.EcsCluster.id
  task_definition = aws_ecs_task_definition.Ecs_Task_Definition.arn
  desired_count   = 1
  launch_type = "FARGATE"
  #iam_role        = aws_iam_role.IamRole_ECSTrustRole.arn

  network_configuration {
    subnets = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]
    security_groups = [aws_security_group.SecurityGroup_DEV_Public.id]
    assign_public_ip = true
  }
}

#Step 3: Configure the Cluster
resource "aws_ecs_cluster" "EcsCluster" {
  name = "ib07441-ecs-cluster"
}