# OIDCプロバイダ(GitHub)設定
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
}

# GitHub Actionsに付与する実行ロールの設定
resource "aws_iam_role" "github_actions_role" {
    name = "task-api-github-actions-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Action = "sts:AssumeRoleWithWebIdentity"
                Effect = "Allow"
                Principal = {
                    Federated = aws_iam_openid_connect_provider.github.arn
                }
                Condition = {
                    StringEquals = {
                        "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
                    }
                    StringLike = {
                        "token.actions.githubusercontent.com:sub" = "repo:sa-dev-sketch/task-api:*"
                    }
                }
            },
        ]
    })
    tags = {
        Name = "github_actions_role"
    }
}

# GitHubActionsロールに付与するポリシー（AWSへのアクセス許可）の設定
resource "aws_iam_role_policy_attachment" "github_actions_aws" {
  role       = aws_iam_role.github_actions_role.name
  # Admin権限を指定
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
