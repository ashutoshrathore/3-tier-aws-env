variable "AWS_REGION" {    
    default = "us-east-1"
}

provider "aws" {
    region = "${var.AWS_REGION}"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}