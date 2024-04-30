terraform {
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
