terraform {
  backend "remote" {
    organization = "GitHub-Actions_CICD"

    workspaces {
      name = "resume-project"
    }
  }
}
