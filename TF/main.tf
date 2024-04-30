#provider "aws" {
#  region = local.region
#  access_key = var.Access_key
#  secret_key = var.Secret_key
#}

data "aws_vpc" "default" {
  default = true
}

resource "aws_default_subnet" "default_az1" {
  availability_zone = "us-east-1a"

  tags = {
    Name = "Default subnet for us-east-1a"
  }
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}
data "aws_availability_zones" "available" {}

locals {
  name   = "ex-${basename(path.cwd)}"
  region = "us-east-1"
  ec2_name = "ubuntu-docker-server"

  vpc_cidr = "172.31.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  user_data = <<-EOT
    #!/bin/bash
    # Add Docker's official GPG key:
    sudo apt-get update -y
    curl -fsSL https://get.docker.com -o install-docker.sh
    sudo sh install-docker.sh
    sudo chmod 777 /var/run/docker.sock
    sudo mkdir /home/ubuntu/docker

    #sudo apt-get update -y
    #sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo apt install unzip -y
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" &&
    unzip awscliv2.zip &&
    sudo ./aws/install

    export AWS_ACCESS_KEY_ID=${var.Access_key}
    export AWS_SECRET_ACCESS_KEY=${var.Secret_key}
    export AWS_DEFAULT_REGION=${var.region}
    aws configure
    echo ${var.Access_key}
    echo ${var.Secret_key}
    echo ${var.region}

    #aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${var.account_id}.dkr.ecr.${var.region}.amazonaws.com

  EOT

  tags = {
    Name       = local.name
    Terraform    = "true${path.cwd}"

  }
}



module "ec2_instance"{
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = local.ec2_name

  ami = data.aws_ami.ubuntu.image_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.generated_key.key_name
  monitoring             = true
  vpc_security_group_ids = [aws_security_group.ubuntu_docker_sg.id]
  subnet_id              = aws_default_subnet.default_az1.id
  user_data = base64encode(local.user_data)
  #iam_instance_profile = "${aws_iam_instance_profile.Kontroller_EKS.name}"
  
  #create_iam_instance_profile = true
  
  #iam_role_description        = "IAM role for EC2 instance that controls ec2"
  #iam_role_policies = {
  #  AdministratorAccess = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
  #}
  availability_zone = data.aws_availability_zones.available.names[0]
  associate_public_ip_address = true


  tags = {
    Terraform   = "true"
    Environment = "dev"
  }
}

resource "tls_private_key" "controller" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.controller.public_key_openssh
}
resource "local_file" "private_key_pem" {
  content  = tls_private_key.controller.private_key_pem
  filename = var.key_name
}



resource "aws_security_group" "ubuntu_docker_sg" {
  name        = "ssh, http, https"
  description = "Allow tcp inbound traffic and all outbound traffic"
  vpc_id      = data.aws_vpc.default.id

  tags = {
    Name = "buntu_docker_sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  description = "allow https"
  security_group_id = aws_security_group.ubuntu_docker_sg.id
  cidr_ipv4         = var.allow_all
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  description = "allow ssh"
  security_group_id = aws_security_group.ubuntu_docker_sg.id
  cidr_ipv4         = var.allow_all
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.ubuntu_docker_sg.id
  cidr_ipv4         = var.allow_all
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}
resource "aws_vpc_security_group_egress_rule" "all" {
  security_group_id = aws_security_group.ubuntu_docker_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

/*module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = local.name
  description = "Security group for example usage with EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  ingress_rules       = ["ssh-22-tcp", "https-443-tcp"]
  egress_rules        = ["all-all"]

  tags = local.tags
}*/
resource "aws_ecr_repository" "aws_ecr" {
  name                 = "resume-project"
  image_tag_mutability = "MUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}
