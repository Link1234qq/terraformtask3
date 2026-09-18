terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.37.0, < 7.0.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "default"

  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = var.managed_by
      Project     = var.app_name
    }
  }
}
