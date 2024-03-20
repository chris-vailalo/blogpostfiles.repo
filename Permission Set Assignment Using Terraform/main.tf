data "aws_ssoadmin_instances" "this" {}

# Create the permission sets
resource "aws_ssoadmin_permission_set" "this" {
  for_each = local.permission_sets

  name         = each.value.name
  description  = each.value.description
  instance_arn = var.sso_arn
}

# Create the groups
resource "aws_identitystore_group" "this" {
  for_each = var.groups

  display_name      = each.key
  description       = each.value
  identity_store_id = var.identity_source_id
}

# Assign the permission sets and groups to the AWS accounts
resource "aws_ssoadmin_account_assignment" "this" {
  for_each = { for item in local.account_group_permission_sets : "${item.account}-${item.group}-${item.permission_set}" => item }

  instance_arn       = var.sso_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set].arn

  principal_id   = aws_identitystore_group.this[each.value.group].group_id
  principal_type = "GROUP"

  target_id   = each.value.account
  target_type = "AWS_ACCOUNT"
}