variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "us-east-1"
}

variable "account_a_email" {
    description = "Email for Account A"
    type        = string
}

variable "account_b_email" {
    description = "Email for Account B"
    type        = string
}

variable "notification_email" {
    description = "Email for security notifications"
    type        = string
}