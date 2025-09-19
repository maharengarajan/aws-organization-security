# Provider for Account B
provider "aws" {
    region = var.aws_region
    alias = "account_b"
    assume_role {
        role_arn = "arn:aws:iam::${aws_organizations_account.account_b.id}:role/OrganizationAccountAccessRole"
    }
}

# S3 Bucket in Account B
resource "aws_s3_bucket" "billing_reports_bucket" {
    provider = aws.account_b
    bucket = "billing-reports-${random_string.bucket_suffix.result}"
    force_destroy = true
}

# Simple bucket policy to allow Account A EC2 instance access
resource "aws_s3_bucket_policy" "billing_reports_bucket_policy" {
    provider = aws.account_b
    bucket = aws_s3_bucket.billing_reports_bucket.bucket
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect = "Allow"
                Principal = {
                    AWS = "arn:aws:iam::${aws_organizations_account.account_a.id}:role/ec2-s3-access_role"
                }
                Action = [
                    "s3:GetObject",
                    "s3:PutObject"
                ]
                Resource =[ "${aws_s3_bucket.billing_reports_bucket.arn}/*",
                aws_s3_bucket.billing_reports_bucket.arn]
            }
        ]
    })
}

# sample billing report file
resource "aws_s3_object" "billing_report" {
    provider = aws.account_b
    bucket = aws_s3_bucket.billing_reports_bucket.id
    key = "sample-billing-report.txt"
    content = "This is a sample billing report. Account A: $5000, Account B: $3000, Total: $8000"
}
       