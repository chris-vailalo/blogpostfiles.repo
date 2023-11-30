################################################################################
# CodeCommit
################################################################################

resource "aws_codecommit_repository" "it" {
  repository_name = "repository"
  description     = "repository"
}


################################################################################
# CodePipeline
################################################################################

resource "aws_codepipeline" "it" {
  name     = "pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.it.id
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.it.id
      type = "KMS"
    }
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeCommit"
      version          = "1"
      run_order        = 1
      output_artifacts = ["source_artifact"]
      configuration = {
        RepositoryName       = aws_codecommit_repository.it.repository_name
        BranchName           = "master"
        PollForSourceChanges = true
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "TerraformValidate"
    action {
      name             = "Validate"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 2
      input_artifacts  = ["source_artifact"]
      output_artifacts = ["validate_artifact"]
      configuration = {
        ProjectName = aws_codebuild_project.validate.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ACTION"
            value = "VALIDATE"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "TerraformPlan"
    action {
      name             = "Plan"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 3
      input_artifacts  = ["validate_artifact"]
      output_artifacts = ["plan_artifact"]
      configuration = {
        ProjectName = aws_codebuild_project.plan.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ACTION"
            value = "PLAN"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }

  stage {
    name = "ApprovalApply"
    action {
      name      = "Apply"
      category  = "Approval"
      owner     = "AWS"
      provider  = "Manual"
      version   = "1"
      run_order = 4
    }
  }

  stage {
    name = "TerraformApply"
    action {
      name             = "Apply"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      run_order        = 5
      input_artifacts  = ["plan_artifact"]
      output_artifacts = ["apply_artifact"]
      configuration = {
        ProjectName = aws_codebuild_project.apply.name
        EnvironmentVariables = jsonencode([
          {
            name  = "ACTION"
            value = "APPLY"
            type  = "PLAINTEXT"
          }
        ])
      }
    }
  }
}


resource "aws_iam_role" "codepipeline" {
  name = "codepipeline"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        }
      },
    ]
  })
}


data "aws_iam_policy_document" "codepipeline" {
  statement {
    sid = "s3access"
    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
      "s3:ListBucket",
    ]

    resources = [aws_s3_bucket.it.arn, "${aws_s3_bucket.it.arn}/*"]
  }

  statement {
    sid = "codecommitaccess"
    actions = [
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:UploadArchive",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:CancelUploadArchive"
    ]

    resources = [aws_codecommit_repository.it.arn]
  }

  statement {
    sid = "codebuildaccess"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild"
    ]
    resources = [
      aws_codebuild_project.it.arn, 
      aws_codebuild_project.validate.arn,
      aws_codebuild_project.plan.arn,
      aws_codebuild_project.apply.arn
      ]
  }

  statement {
    sid = "kmsaccess"
    actions = [
      "kms:DescribeKey",
      "kms:GenerateDataKey*",
      "kms:Encrypt",
      "kms:ReEncrypt*",
      "kms:Decrypt"
    ]
    resources = [aws_kms_key.it.arn]
  }
}


resource "aws_iam_policy" "codepipeline" {
  name   = "codepipeline2"
  policy = data.aws_iam_policy_document.codepipeline.json
}


resource "aws_iam_role_policy_attachment" "codepipeline" {
  role       = aws_iam_role.codepipeline.name
  policy_arn = aws_iam_policy.codepipeline.arn
}


################################################################################
# S3
################################################################################

resource "aws_s3_bucket" "it" {
  bucket_prefix = "aritfactbucket"
}


resource "aws_s3_bucket_policy" "it" {
  bucket = aws_s3_bucket.it.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Service = "codepipeline.amazonaws.com"
      },
      Action = [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObjectAcl",
        "s3:PutObject",
        "s3:ListBucket"
      ],
      Resource = ["${aws_s3_bucket.it.arn}", "${aws_s3_bucket.it.arn}/*"],
      Condition = {
        ArnEquals = {
          "AWS:SourceArn" = ["${aws_codepipeline.it.arn}", "${aws_codebuild_project.it.arn}"]
        }
      }
    }]
  })
}


resource "aws_s3_bucket_server_side_encryption_configuration" "it" {
  bucket = aws_s3_bucket.it.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.it.arn
      sse_algorithm     = "aws:kms"
    }
  }
}


################################################################################
# KMS
################################################################################

data "aws_caller_identity" "it" {}


resource "aws_kms_key" "it" {
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true
}


resource "aws_kms_key_policy" "it" {
  key_id = aws_kms_key.it.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "kms:*",
      Resource = "*",
      Principal = {
        AWS = "arn:aws:iam::${data.aws_caller_identity.it.account_id}:root"
      }
    }]
  })
}


################################################################################
# CodeBuild
################################################################################

resource "aws_codebuild_project" "it" {
  name                   = "codebuild_project"
  service_role           = aws_iam_role.codebuild.arn
  concurrent_build_limit = 1

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "${aws_ecr_repository.it.repository_url}:custom-pipeline-image"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.it.name
      status     = "ENABLED"
    }
  }
}

#validate
resource "aws_codebuild_project" "validate" {
  name                   = "codebuild_project_validate"
  service_role           = aws_iam_role.codebuild.arn
  concurrent_build_limit = 1

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "${aws_ecr_repository.it.repository_url}:custom-pipeline-image"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.it.name
      status     = "ENABLED"
    }
  }
}

#plan
resource "aws_codebuild_project" "plan" {
  name                   = "codebuild_project_plan"
  service_role           = aws_iam_role.codebuild.arn
  concurrent_build_limit = 1

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "${aws_ecr_repository.it.repository_url}:custom-pipeline-image"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.it.name
      status     = "ENABLED"
    }
  }
}

#apply
resource "aws_codebuild_project" "apply" {
  name                   = "codebuild_project_apply"
  service_role           = aws_iam_role.codebuild.arn
  concurrent_build_limit = 1

  environment {
    type                        = "LINUX_CONTAINER"
    image                       = "${aws_ecr_repository.it.repository_url}:custom-pipeline-image"
    compute_type                = "BUILD_GENERAL1_SMALL"
    image_pull_credentials_type = "SERVICE_ROLE"
    privileged_mode             = false
  }

  artifacts {
    type = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec.yaml")
  }

  logs_config {
    cloudwatch_logs {
      group_name = aws_cloudwatch_log_group.it.name
      status     = "ENABLED"
    }
  }
}

resource "aws_cloudwatch_log_group" "it" {
  name              = "/aws/codebuild/logs"
  retention_in_days = 30
}


resource "aws_iam_role" "codebuild" {
  name = "codebuild"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "codebuild.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "codebuild" {
  role       = aws_iam_role.codebuild.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}


################################################################################
# Elastic Container Registry
################################################################################

resource "aws_ecr_repository" "it" {
  name                 = "ecr_repository"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}