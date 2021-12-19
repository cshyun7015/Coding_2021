#Step 1: Register a task definition
resource "aws_ecs_task_definition" "Ecs_Task_Definition" {
  family = "Ecs-Service"
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
        "cpu": 10,
        "memory": 300,
        "image": "httpd:2.4",
        "name": "ib07441-app"
    }
  ])
}

#Step 2: Create a cluster
resource "aws_ecs_cluster" "EcsCluster" {
  name = "ib07441-ecs-cluster"
}

#Step 3: Create a Service
resource "aws_ecs_service" "Ecs_Service" {
  name            = "ib07441_ecs_service"
  cluster         = aws_ecs_cluster.EcsCluster.id
  task_definition = aws_ecs_task_definition.Ecs_Task_Definition.arn
  desired_count   = 1
  #iam_role        = aws_iam_role.IamRole_ECSTrustRole.arn
}

resource "aws_key_pair" "KeyPair" {
  key_name   = "IB07441_EC2_SSH_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaw4lByVXTd5s+u3vs5zjWDzhPaidTyu+b6H77nI7+qplG6V3sTAVSTgV6U7wB//cZx9SgDq05OAk7U7MZZ1SJ91oUsYuibYaVc4I7BnHSY4RgE2NQjEmHuyZSBugCgG/v0pcEvarOKqxH6wp/ATHxDFd5sn8dwxUjTz5JiR74bOuDgzgBTQr8opraZL46wMyMIT5AD5vpbn3U1qNOOBJOlHvruRIRHG1Nu6DVY0GoSf2fjHZHEriNYt+utjulLfjm2uRZWNjsuMVMYeMpVeuVtVIjgrMD+UGyrfxFaIlUtvn2yndvUf6CA7MPGRKkGA9sENX5vc5M/QW/Vh/HF7EUAgdR7HdYnCClyQ2Py4ftTIhXdw799C5Z+4Gbks2bn67ORPIMTT67dBy6BT++IIHVrgup+NFf8NseNft3S3ABxD/NW4NDP+dF5fCUY7QVAPoOMVmi/ogT9zL1VDsI5BM5Yx6BxxM5opACBN8honTaCTvlPCxjN6nYqNHh1sIrenk= zogzog@SKCC20N01233"
}

variable default_key_name {
  default = "IB07441_EC2_SSH_Key"
}

data "aws_ami" "Ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
   name   = "name"
   values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }
}

data "aws_ec2_instance_type" "Ec2InstanceType" {
  instance_type = "t2.micro"
}

resource "aws_launch_configuration" "LaunchConfiguration" {
  name                        = "IB07441-LaunchConfiguration"
  image_id                    = data.aws_ami.Ami.id
  instance_type               = data.aws_ec2_instance_type.Ec2InstanceType.id
  iam_instance_profile = aws_iam_instance_profile.IamInstanceProfile_EC2.id
  key_name                    = var.default_key_name
  security_groups             = [
    aws_security_group.SecurityGroup_DEV_Public.id
  ]
  associate_public_ip_address = true

  user_data                   = "#!/bin/bash\necho ECS_CLUSTER=${aws_ecs_cluster.EcsCluster.name} >> /etc/ecs/ecs.config"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "AutoscalingGroup" {
  name                      = "IB07441-AutoscalingGroup"
  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1

  launch_configuration      = aws_launch_configuration.LaunchConfiguration.name
  vpc_zone_identifier       = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]

  enabled_metrics           = [
     "GroupDesiredCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupTotalInstances"
     ]

  metrics_granularity       = "1Minute"

  tag {
    key                 = "Name"
    value               = "IB07441-ASG-ECS"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "PolicyDown" {
  name                   = "IB07441-PolicyDown"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 10
  autoscaling_group_name = aws_autoscaling_group.AutoscalingGroup.name
}

resource "aws_autoscaling_policy" "PolicyUp" {
  name                   = "IB07441-PolicyUp"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 10
  autoscaling_group_name = aws_autoscaling_group.AutoscalingGroup.name
}

resource "aws_cloudwatch_metric_alarm" "CpuDownAlarm" {
  alarm_name                = "IB07441-CpuDownAlarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "30"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [
    aws_autoscaling_policy.PolicyDown.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "CpuUpAlarm" {
  alarm_name                = "IB07441-CpuUpAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [
    aws_autoscaling_policy.PolicyUp.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "MemoryDownAlarm" {
  alarm_name                = "IB07441-MemoryDownAlarm"
  comparison_operator       = "LessThanThreshold"
  evaluation_periods        = "1"
  metric_name               = "MemoryUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "30"
  alarm_description         = "This metric monitors ec2 memory utilization"
  alarm_actions             = [
    aws_autoscaling_policy.PolicyDown.arn
  ]
}

resource "aws_cloudwatch_metric_alarm" "MemoryUpAlarm" {
  alarm_name                = "IB07441-MemoryUpAlarm"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "75"
  alarm_description         = "This metric monitors ec2 memory utilization"
  alarm_actions             = [
    aws_autoscaling_policy.PolicyUp.arn
  ]
}

output "ecs_ami_id" {
  value = data.aws_ami.Ami.id
}