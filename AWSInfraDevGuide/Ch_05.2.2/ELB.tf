resource "aws_lb" "Lb" {
  name               = "ib07441-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SecurityGroup_LoadBalancer.id]
  subnets            = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]

  enable_deletion_protection = false

  tags = {
    Environment = "IB07441-Test"
  }
}

resource "aws_lb_listener" "Lb_Listener" {
  load_balancer_arn = aws_lb.Lb.arn
  port              = "3000"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Lb_TargetGroup.arn
  }
}

resource "aws_lb_target_group" "Lb_TargetGroup" {
  name     = "ib07441-lb-tg"
  port     = 3000
  protocol = "HTTP"
  vpc_id   = aws_vpc.VPC.id

  health_check {
    interval            = 20
    protocol            = "HTTP"
    port                = 3000
    path                = "/"
    timeout             = 15
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = 200
  }

  tags = {
    Name = "IB07441-ALB-TargetGroup"
  }
}

output "LbDns" {
  value = aws_lb.Lb.dns_name
}