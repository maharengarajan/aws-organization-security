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