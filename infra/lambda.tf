# ローカルにあるLambdaのソースコードを指定
data "archive_file" "lambda_zip" {
    type        = "zip"
    source_dir  = "${path.module}/../src"
    output_path = "${path.module}/../lambda.zip"
}

# Lambdaに付与する実行ロールの設定
resource "aws_iam_role" "lambda_role" {
    name = "task-api-lambda-role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
                {
                    Action = "sts:AssumeRole"
                    Effect = "Allow"
                    Principal = {
                        Service = "lambda.amazonaws.com"
                    }
                },
            ]
        })
    tags = {
        Name = "lambda-role"
    }
}

# CloudWatchログ出力のための基本ポリシー
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Lambdaロールに付与するポリシー（DynamoDBへのアクセス許可）の設定
resource "aws_iam_role_policy" "lambda_dynamodb" {
  name = "task-api-lambda-dynamodb-policy"
  role = aws_iam_role.lambda_role.id
  policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
            {
                Effect   = "Allow"
                Action = [
                    "dynamodb:GetItem",
                    "dynamodb:PutItem",
                    "dynamodb:UpdateItem",
                    "dynamodb:DeleteItem",
                    "dynamodb:Query",
                    "dynamodb:Scan"
                ]
                Resource = [
                    aws_dynamodb_table.tasks.arn,
                    # GSI用
                    "${aws_dynamodb_table.tasks.arn}/index/*"  
                ]
                    
            },
        ]
    })
}

# AWSに作るlambda function
resource "aws_lambda_function" "task_api" {
    function_name    = "task-api"
    filename         = data.archive_file.lambda_zip.output_path
    role             = aws_iam_role.lambda_role.arn
    source_code_hash = data.archive_file.lambda_zip.output_base64sha256
    handler          = "handlers.task_handler.handler"
    runtime          = "python3.12"

    environment {
        variables = {
            TABLE_NAME = aws_dynamodb_table.tasks.name
        }
    }
    tags = {
        Name = "task-api"
    }
}
