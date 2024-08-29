terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
  }

  backend "s3" {
    bucket = "traccar-terraform-state"
    key    = "terraform-state"
    region = "ap-southeast-2"
  }
}

provider "aws" {
  region = "ap-southeast-2"
}
