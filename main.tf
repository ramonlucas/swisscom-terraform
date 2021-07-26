######################################################
## PROVIDERS CONFIG
######################################################

terraform {
  required_providers {
    aws = {
      version = "3.33.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}