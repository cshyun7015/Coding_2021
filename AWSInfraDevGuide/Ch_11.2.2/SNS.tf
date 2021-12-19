resource "aws_sns_topic" "SnsTopic" {
  name         = "IB07441-Codepipeline-Notification"
}

resource "aws_sns_topic_subscription" "SnsTopicSubscription" {
  topic_arn = aws_sns_topic.SnsTopic.arn
  protocol  = "email"
  endpoint  = "cshyun7015@gmail.com"
}

output "SNS_Topic_Arn" {
  value = aws_sns_topic.SnsTopic.arn
}