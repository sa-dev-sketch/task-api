terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~>2.8.0"
    }
  }
}

provider "aws" {
  region  = "ap-northeast-3"
}


# GitHub Actionsからのplan失敗テスト用
resource "aws_vpc" "intentional_failure" {
  cidr_block = "これは絶対に無効なCIDR"
}