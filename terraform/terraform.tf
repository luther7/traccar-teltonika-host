terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.61.0"
    }
    tailscale = {
      source  = "tailscale/tailscale"
      version = "~> 0.16.2"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5.1"
    }
  }

  backend "s3" {}
}

provider "aws" {
  region = "ap-southeast-2"
}
