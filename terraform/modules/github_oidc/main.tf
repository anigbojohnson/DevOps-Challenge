data "aws_caller_identity" "current" {}

# GitHub OIDC identity provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name = "github-actions-oidc"
  }
}

# Trust policy: only the specified repository's main branch
data "aws_iam_policy_document" "github_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
        test = "StringEquals"

        variable = "token.actions.githubusercontent.com:sub"

        values = [
            "repo:${var.github_owner}@${var.github_owner_id}/${var.github_repository}@${var.github_repository_id}:ref:refs/heads/${var.github_branch}"
        ]
    }
  }
}

resource "aws_iam_role" "github_actions" {
  name               = "GitHubActions-TodoApp-Deploy"
  assume_role_policy = data.aws_iam_policy_document.github_assume_role.json

  tags = {
    Name = "GitHubActions-TodoApp-Deploy"
  }
}

# Permissions for pushing images and deploying to ECS
data "aws_iam_policy_document" "deployment" {
  # ECR authentication
  statement {
    sid    = "ECRAuthentication"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  # Push Docker images to the Todo application repository
  statement {
    sid    = "ECRImagePush"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:BatchGetImage"
    ]

    resources = [
      var.ecr_repository_arn
    ]
  }

  # ECS deployment
  statement {
    sid    = "ECSDeployment"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeClusters",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService"
    ]

    resources = [
      var.ecs_cluster_arn,
      var.ecs_service_arn,
      "*"
    ]
  }

  # Allow ECS task definitions to use only these two IAM roles
  statement {
    sid    = "PassECSTaskRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      var.ecs_execution_role_arn,
      var.ecs_task_role_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "github_deployment" {
  name   = "TodoApp-ECR-ECS-Deployment"
  role   = aws_iam_role.github_actions.id
  policy = data.aws_iam_policy_document.deployment.json
}