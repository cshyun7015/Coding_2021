resource "aws_lb" "Lb" {
  name               = "ib07441-lb"
  internal           = false
  load_balancer_type = "application"
  #security_groups    = [aws_security_group.SecurityGroup_DEV_Public.id]
  subnets            = [aws_subnet.Subnet_Public_01.id, aws_subnet.Subnet_Public_02.id, aws_subnet.Subnet_Public_03.id]

  enable_deletion_protection = false

  tags = {
    Environment = "Staging"
  }
}

resource "aws_lb_target_group" "Lb_Target_Group" {
  name     = "ib07441-lb-target-group"
  port     = 30000
  protocol = "HTTP"
  #target_type = "instance"
  vpc_id   = aws_vpc.VPC.id

  # health_check {
  #   interval            = 20
  #   protocol            = "HTTP"
  #   port                = 30000
  #   path                = "/"
  #   timeout             = 15
  #   healthy_threshold   = 5
  #   unhealthy_threshold = 3
  #   matcher             = 200
  # }

  tags = {
    Name = "IB07441-ALB-Target-Group"
  }
}

resource "aws_lb_target_group_attachment" "Lb_Target_Group_Attachment" {
  target_group_arn = aws_lb_target_group.Lb_Target_Group.arn
  target_id        = aws_cloud9_environment_ec2.Cloud9_Environment_Ec2.id
}

resource "aws_lb_listener" "Lb_Listener" {
  load_balancer_arn = aws_lb.Lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Lb_Target_Group.arn
  }
}

output "elb_staging_dnsname" {
  value = aws_lb.Lb.dns_name
}