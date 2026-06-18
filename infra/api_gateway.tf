resource "aws_apigatewayv2_api" "task_api" {
    name          = "task-api"
    protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "task_api" {
    api_id                 = aws_apigatewayv2_api.task_api.id
    integration_uri        = aws_lambda_function.task_api.invoke_arn
    integration_type       = "AWS_PROXY"
    payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "default" {
    api_id    = aws_apigatewayv2_api.task_api.id
    route_key = "$default"
    target    = "integrations/${aws_apigatewayv2_integration.task_api.id}"
}

# API GatewayからLambdaを呼び出すための権限付与
resource "aws_lambda_permission" "api_gateway" {
    statement_id  = "AllowAPIGatewayInvoke" # 任意の文字列
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.task_api.function_name
    principal     = "apigateway.amazonaws.com"
    source_arn    = "${aws_apigatewayv2_api.task_api.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.task_api.id
  name        = "$default"
  auto_deploy = true
}
