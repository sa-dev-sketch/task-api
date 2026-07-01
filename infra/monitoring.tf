# ロググループの保持期間設定（デフォルトは無制限だがコストを抑えるため）
resource "aws_cloudwatch_log_group" "task_api" {
  name              = "/aws/lambda/task-api"
  retention_in_days = 30
}

# Lambdaのエラー率アラーム
resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "task-api-lambda-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold" # 閾値以上になったら
  evaluation_periods  = 1 
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "Lambda function error detected"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  # task-apiのみが対象
  dimensions = {
    FunctionName = aws_lambda_function.task_api.function_name
  }
}

# SNSトピック（アラート通知用）
resource "aws_sns_topic" "alerts" {
  name = "task-api-alerts"
}

# SSMパラメータストアからメアドを取得
data "aws_ssm_parameter" "alert_email" {
  name            = "/task-api/alert-email"
  with_decryption = true
}

# SNSトピックにメアドをサブスクライブ
resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = data.aws_ssm_parameter.alert_email.value
}