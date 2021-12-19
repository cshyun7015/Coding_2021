resource "aws_cloudwatch_log_group" "Cloudwatch_Log_Group" {
  name = "/aws/lambda/IB07441-Pipeline-Notification"

  tags = {
    Environment = "production"
    Application = "IB07441-Pipeline-Notification"
  }
}