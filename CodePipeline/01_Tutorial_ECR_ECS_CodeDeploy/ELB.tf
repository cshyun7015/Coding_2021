resource "aws_lb" "Lb_Staging" {
  name               = "ib07441-lb-staging"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.SecurityGroup_DEV_Public.id]
  #subnets            = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id, aws_subnet.Subnet_DEV_Public03.id]
  subnets            = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]

  enable_deletion_protection = false

  tags = {
    Environment = "Staging"
  }
}

resource "aws_lb_target_group" "Lb_TargetGroup_Staging_Blue" {
  name     = "ib07441-lb-tg-staging-blue"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.VPC.id

  health_check {
    interval            = 20
    protocol            = "HTTP"
    port                = 80
    path                = "/"
    timeout             = 15
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = 200
  }

  tags = {
    Name = "IB07441-ALB-TargetGroup-Staging-Blue"
  }
}

resource "aws_lb_target_group" "Lb_TargetGroup_Staging_Green" {
  name     = "ib07441-lb-tg-staging-green"
  port     = 80
  protocol = "HTTP"
  target_type = "ip"
  vpc_id   = aws_vpc.VPC.id

  health_check {
    interval            = 20
    protocol            = "HTTP"
    port                = 80
    path                = "/"
    timeout             = 15
    healthy_threshold   = 5
    unhealthy_threshold = 3
    matcher             = 200
  }

  tags = {
    Name = "IB07441-ALB-TargetGroup-Staging-Green"
  }
}

resource "aws_lb_listener" "Lb_Listener_Staging_Blue" {
  load_balancer_arn = aws_lb.Lb_Staging.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Lb_TargetGroup_Staging_Blue.arn
  }
}

resource "aws_lb_listener" "Lb_Listener_Staging_Green" {
  load_balancer_arn = aws_lb.Lb_Staging.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Lb_TargetGroup_Staging_Green.arn
  }
}

resource "aws_lb_listener" "Lb_Listener_Staging_SSL" {
  load_balancer_arn = aws_lb.Lb_Staging.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.Acm_Certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.Lb_TargetGroup_Staging_Blue.arn
  }
}

output "elb_staging_dnsname" {
  value = aws_lb.Lb_Staging.dns_name
}