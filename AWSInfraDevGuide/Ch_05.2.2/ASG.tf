resource "aws_autoscaling_group" "AutoscalingGroup_Blue" {
  name                      = "IB07441-AutoscalingGroup-Blue"

  launch_template {
    id      = aws_launch_template.Launch_Template_Green.id
    version = "$Latest"
  }

  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1

  target_group_arns         = [aws_lb_target_group.Lb_TargetGroup.arn]

  vpc_zone_identifier       = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]

  tag {
    key                 = "Name"
    value               = "IB07441-ASG-Blue"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "Autoscaling_Policy_Blue" {
  name                   = "IB07441-Autoscaling-Policy-Blue"
  adjustment_type        = "ExactCapacity"
  scaling_adjustment     = 1
  autoscaling_group_name = aws_autoscaling_group.AutoscalingGroup_Blue.name
}

resource "aws_autoscaling_group" "AutoscalingGroup_Green" {
  name                      = "IB07441-AutoscalingGroup-Green"

  launch_template {
    id      = aws_launch_template.Launch_Template_Green.id
    version = "$Latest"
  }

  desired_capacity          = 1
  max_size                  = 1
  min_size                  = 1

  target_group_arns         = [aws_lb_target_group.Lb_TargetGroup.arn]

  vpc_zone_identifier       = [aws_subnet.Subnet_DEV_Public01.id, aws_subnet.Subnet_DEV_Public02.id]

  tag {
    key                 = "Name"
    value               = "IB07441-ASG-Green"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "Autoscaling_Policy_Green" {
  name                   = "IB07441-Autoscaling-Policy-Green"
  adjustment_type        = "ExactCapacity"
  scaling_adjustment     = 1
  autoscaling_group_name = aws_autoscaling_group.AutoscalingGroup_Green.name
}