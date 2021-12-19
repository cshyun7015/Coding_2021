resource "aws_autoscaling_group" "AutoscalingGroup" {
  name                      = "IB07441-AutoscalingGroup"

  launch_template {
    id      = aws_launch_template.Launch_Template.id
    version = "$Latest"
  }

  desired_capacity          = 1
  max_size                  = 2
  min_size                  = 1

  target_group_arns         = [aws_lb_target_group.Lb_TargetGroup.arn]

  vpc_zone_identifier       = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]

  enabled_metrics           = [
     "GroupDesiredCapacity", "GroupMinSize", "GroupMaxSize", "GroupInServiceInstances", "GroupTotalInstances"
     ]

  metrics_granularity       = "1Minute"

  tag {
    key                 = "Name"
    value               = "IB07441-ASG-Test"
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
  threshold                 = "80"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  alarm_actions             = [
    aws_autoscaling_policy.PolicyUp.arn
  ]
}