terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.47.0"
    }
  }

  backend "remote" {
    organization = "GitHub-Actions_CICD"

    workspaces {
      name = "resume-project"
      #tags = ["some-tag"]
    }
  }
}
provider "aws" {
  region = var.region
}
