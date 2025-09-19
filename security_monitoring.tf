# SNS Topic for Security Monitoring Alerts
resource "aws_sns_topic" "security_monitoring_alerts" {
  name = "security-monitoring-alerts"
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.security_monitoring_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email  
}

