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
  backend "s3" {
    bucket = "task-api-tfstate-893946677925"
    key    = "terraform.tfstate" # S3内でのファイル名
    region = "ap-northeast-3"
  }
}

provider "aws" {
  region  = "ap-northeast-3"
}
