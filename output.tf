# Output account ID for reference
output "organization_id" {
  value = aws_organizations_organization.org.id  
}

output "account_a_id" {
  value = aws_organizations_account.account_a.id
}

output "account_b_id" {
  value = aws_organizations_account.account_b.id
}

output "cloudtrail_logs_bucket" {
  value = aws_s3_bucket.cloudtrail_logs.bucket
}

output "sns_topic_name" {
  value = aws_sns_topic.security_monitoring_alerts.name
  
}