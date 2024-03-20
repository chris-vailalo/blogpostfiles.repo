locals {
  permission_sets = {
    "perm-set-1" = {
      name        = "perm-set-1"
      description = "permission set 1"
    },
    "perm-set-2" = {
      name        = "pperm-set-2"
      description = "permission set 2"
    },
    "perm-set-3" = {
      name        = "perm-set-3"
      description = "permission set 3"
    }
    "perm-set-4" = {
      name        = "perm-set-4"
      description = "permission set 4"
    }
  }

  account_group_permission_sets = flatten([
    for account, group_mappings in var.map : [
      for group, permission_sets in group_mappings : [
        for permission_set in permission_sets : {
          account        = account
          group          = group
          permission_set = permission_set
        }
      ]
    ]]
  )

  current_directory_name = basename(abspath(path.module))
}   