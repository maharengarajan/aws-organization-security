# SNS Topic for Security Monitoring Alerts
resource "aws_sns_topic" "security_monitoring_alerts" {
  name = "security-monitoring-alerts"
}

resource "aws_sns_topic_subscription" "email_notification" {
  topic_arn = aws_sns_topic.security_monitoring_alerts.arn
  protocol  = "email"
  endpoint  = var.notification_email  
}

# S3 bucket for cloudtrail logs
resource "aws_s3_bucket" "cloudtrail_logs" {
  bucket = "cloudtrail-logs-${random_string.bucket_suffix.result}"
  force_destroy = true
}

resource "random_string" "bucket_suffix" {
  length  = 8
  upper   = false
  special = false
}

resource "aws_s3_bucket_policy" "cloudtrail_logs_policy" {
  bucket = aws_s3_bucket.cloudtrail_logs.id

    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Sid = "AWSCloudTrailAclCheck"
            Effect = "Allow"
            Principal = {
            Service = "cloudtrail.amazonaws.com"
            }
            Action = "s3:GetBucketAcl"
            Resource = aws_s3_bucket.cloudtrail_logs.arn
        },
        {
            Sid = "AWSCloudTrailWrite"
            Effect = "Allow"
            Principal = {
            Service = "cloudtrail.amazonaws.com"
            }
            Action = "s3:PutObject"
            Resource = "${aws_s3_bucket.cloudtrail_logs.arn}/*"
            Condition = {
            StringEquals = {
                "s3:x-amz-acl" = "bucket-owner-full-control"
            }
            }
        }
        ]
    })
  
}

# CloudTrail for monitoring IAM activities
resource "aws_cloudtrail" "organization_trail" {
  name = "organization-trail"
  s3_bucket_name = aws_s3_bucket.cloudtrail_logs.bucket
  
  event_selector {
    read_write_type = "All"
    include_management_events = true
    exclude_management_event_sources = []

    data_resource {
      type = "AWS::S3::Object"
      values = ["arn:aws:s3:::"]
    }
  }
  depends_on = [ aws_s3_bucket_policy.cloudtrail_logs_policy ]
}
