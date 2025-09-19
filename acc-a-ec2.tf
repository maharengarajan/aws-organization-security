# Provider for Account A
provider "aws" {
  region = var.aws_region
  alias = "account_a"
  assume_role {
    role_arn = "arn:aws:iam::${aws_organizations_account.account_a.id}:role/OrganizationAccountAccessRole"
  }
}

# IAM Role for EC2 to access, Account B S3 Bucket
resource "aws_iam_role" "ec2_s3_access_role" {
  provider = aws.account_a
  name = "ec2-s3-access_role"  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy for S3 Access
resource "aws_iam_role_policy" "s3_access_policy" {
    provider = aws.account_a
    name = "s3-access-policy"
    role = aws_iam_role.ec2_s3_access_role.name
    policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
        {
            Action = [
            "s3:ListBucket",
            "s3:GetObject",
            ]
            Effect = "Allow"
            Resource = [
            "arn:aws:s3:::billing-reports-${random_string.bucket_suffix.result}",  
            "arn:aws:s3:::billing-reports-${random_string.bucket_suffix.result}/*"     
            ]
        }
        ]
    })
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  provider = aws.account_a
  name = "ec2-instance-profile"
  role = aws_iam_role.ec2_s3_access_role.name
}

# Simple EC2 Instance for testing
resource "aws_instance" "test_instance" {
  provider = aws.account_a
  instance_type = "t2.micro"
  ami = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI 
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y aws-cli
              echo "Testing S3 Access from EC2 Instance" > /home/ec2-user/test.log
              aws s3 ls s3://billing-reports-${random_string.bucket_suffix.result}/ >> /home/ec2-user/test.log 2>&1
  EOF

    tags = {
    Name = "test-instance"
  }
}