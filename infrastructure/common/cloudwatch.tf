#Autoscaling policy to increase the amount of instances
resource "aws_autoscaling_policy" "web_policy_up" {
  name = "web_policy_up"
  scaling_adjustment = 1
  adjustment_type = "ChangeInCapacity"
  cooldown = 50
  autoscaling_group_name = aws_autoscaling_group.NodeJS_ASG.name
}

#Cloudwatch CPU metric alarm triggers autoscaling policy
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_up" {
  alarm_name = "web_cpu_alarm_up"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "30"
  statistic = "Average"
  threshold = "30"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.NodeJS_ASG.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
  alarm_actions = [aws_autoscaling_policy.web_policy_up.arn]
}

#Autoscaling policy to decrease the amount of instances
resource "aws_autoscaling_policy" "web_policy_down" {
  name = "web_policy_down"
  scaling_adjustment = -1
  adjustment_type = "ChangeInCapacity"
  cooldown = 100
  autoscaling_group_name = aws_autoscaling_group.NodeJS_ASG.name
}

#Cloudwatch CPU metric alarm triggers autoscaling policy
resource "aws_cloudwatch_metric_alarm" "web_cpu_alarm_down" {
  alarm_name = "web_cpu_alarm_down"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods = "2"
  metric_name = "CPUUtilization"
  namespace = "AWS/EC2"
  period = "120"
  statistic = "Average"
  threshold = "8"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.NodeJS_ASG.name
  }

  alarm_description = "This metric monitor EC2 instance CPU utilization"
alarm_actions = [aws_autoscaling_policy.web_policy_down.arn]
}

# This metric monitors autoscaling events, letting you know when amount of EC2 instances changes
resource "aws_cloudwatch_metric_alarm" "autoscaling_event_alarm" {
  alarm_name          = "autoscaling_event_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "GroupDesiredCapacity"
  namespace           = "AWS/AutoScaling"
  period              = "60"
  statistic           = "Average"
  threshold           = "1"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.NodeJS_ASG.name
  }

  alarm_description = "This metric monitors autoscaling events, letting you know when amount of EC2 instances changes"
  alarm_actions     = [aws_sns_topic.scaling_notifications.arn]
}
