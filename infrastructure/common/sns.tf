# Define SNS topic for scaling event notifications
resource "aws_sns_topic" "scaling_notifications" {
  name = "ScalingEventNotifications"
}


# Subscribe email to SNS topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.scaling_notifications.arn
  protocol  = "email"
  endpoint  = var.sns_email[0]
}
