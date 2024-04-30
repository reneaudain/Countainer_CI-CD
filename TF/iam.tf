resource "aws_iam_user" "Git" {
  name = "GitHubActions"
  path = "/system/"

  tags = {
    tag-key = "tag-value"
    Terraform = "true"
  }
}

resource "aws_iam_access_key" "git_key" {
  user = aws_iam_user.Git.name
}

data "aws_iam_policy_document" "git_policy" {
  statement {
    effect    = "Allow"
    actions   = ["ec2:AmazonEC2ContainerRegistryFullAccess",
        "ecr:GetAuthorizationToken", 
        "ecr:BatchCheckLayerAvailability",
				"ecr:GetDownloadUrlForLayer",
				"ecr:GetRepositoryPolicy",
				"ecr:DescribeRepositories",
				"ecr:ListImages",
				"ecr:DescribeImages",
				"ecr:BatchGetImage",
				"ecr:InitiateLayerUpload",
				"ecr:UploadLayerPart",
				"ecr:CompleteLayerUpload",
				"ecr:PutImage"]
    resources = ["*"]
  }
}

resource "aws_iam_user_policy" "Git_ro" {
  name   = "GitPolicy"
  user   = aws_iam_user.Git.name
  policy = data.aws_iam_policy_document.git_policy.json
}
