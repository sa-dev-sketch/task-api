resource "aws_cloudfront_distribution" "task_api" {
  enabled = true
  price_class         = "PriceClass_200" # 全世界より安価（北米・欧州・アジア等）

  # オリジン（配信元）
  origin {
    domain_name = replace(aws_apigatewayv2_api.task_api.api_endpoint, "https://", "")
    origin_id   = "task-api-gateway"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  # デフォルトキャッシュビヘイビア
  default_cache_behavior {
    target_origin_id       = "task-api-gateway"
    viewer_protocol_policy = "redirect-to-https"

    # APIなのでキャッシュしない
    allowed_methods = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods  = ["GET", "HEAD"] # キャッシュ不要だが記載必須のため書いている（TTLは0なので実際はキャッシュされない）

    forwarded_values {
      query_string = true
      headers      = ["Authorization"]
      cookies {
        forward = "none"
      }
    }

    min_ttl     = 0
    default_ttl = 0
    max_ttl     = 0
  }

  # 地理的制限
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # 証明書の設定（今回はCloudFrontのデフォルトドメインを使用する）
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "task-api-cloudfront"
  }
}