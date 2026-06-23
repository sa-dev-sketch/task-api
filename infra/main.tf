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