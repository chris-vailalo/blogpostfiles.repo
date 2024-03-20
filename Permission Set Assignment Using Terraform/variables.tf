variable "sso_arn" {
  sensitive = true
  type = string
}

variable "identity_source_id" {
  sensitive = true
  type = string
}

variable "groups" {
  type = map(string)
  default = {
    "Test"       = "Test Group"
    "Network"    = "Network Group"
    "Database"   = "Database Group"
    "Analysts"   = "Analysts Group"
    "Developers" = "Developers Group"
  }
}

variable "map" {
  default = {

    # aws-account-dev
    "123456789012" = {
      "Test" = [
        "perm-set-1",
        "perm-set-2",
      ],
      "Network" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-3",
        "perm-set-4"
      ],
      "Database" = [
        "perm-set-1",
        "perm-set-2"
      ],
      "Analysts" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-4"
      ],
      "Developers" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-3",
        "perm-set-4"
      ]
    },

    # aws-account-test
    "123456789013" = {
      "Test" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-3",
        "perm-set-4"
      ],
      "Network" = [
        "perm-set-1",
        "perm-set-2",
      ],
      "Database" = [
        "perm-set-1",
        "perm-set-2",
      ],
      "Analysts" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-4"
      ],
      "Developers" = [
        "perm-set-1",
        "perm-set-2"
      ]
    },

    # aws-account-uat
    "123456789014" = {
      "Test" = [
        "perm-set-1",
        "perm-set-2",
      ],
      "Network" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-3",
        "perm-set-4"
      ],
      "Database" = [
        "perm-set-1",
        "perm-set-2"
      ],
      "Analysts" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-4"
      ],
      "Developers" = [
        "perm-set-1",
        "perm-set-2",
        "perm-set-3",
        "perm-set-4"
      ]
    }
  }
}