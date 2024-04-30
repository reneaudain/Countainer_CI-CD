terraform {
  backend "remote" {
    organization = "GitHub-Actions_CICD"

    workspaces {
      tags = ["resume-project"]
      #tags = ["some-tag"]
    }
  }
}
