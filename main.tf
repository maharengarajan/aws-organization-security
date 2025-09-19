terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# create AWS organization
resource "aws_organizations_organization" "org" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config-multiaccountsetup.amazonaws.com",
    "config.amazonaws.com",
    "guardduty.amazonaws.com",
    "securityhub.amazonaws.com",
    "macie.amazonaws.com"
  ]
  feature_set                   = "ALL"
  enabled_policy_types = ["SERVICE_CONTROL_POLICY"]
}

# create account A
resource "aws_organizations_account" "account_a" {
  name      = "AccountA"
  email     = var.account_a_email
  role_name = "OrganizationAccountAccessRole"
  depends_on = [
    aws_organizations_organization.org
  ]
}

# create account B
resource "aws_organizations_account" "account_b" {
  name      = "AccountB"
  email     = var.account_b_email
  role_name = "OrganizationAccountAccessRole"
  depends_on = [
    aws_organizations_organization.org
  ]
}