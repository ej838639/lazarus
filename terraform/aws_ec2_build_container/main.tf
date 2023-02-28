terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

locals {
  region = "us-west-2"
  zone_b = "${local.region}b"
  zone_c = "${local.region}c"
  smallest_instance = "t2.micro"
  linux_os = "ami-06e85d4c3149db26a"
  project = "lazarus2"
}

resource "aws_key_pair" "my-key-pair" {
  key_name = "my-key-pair-name"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "my-key-pair.pem"
}

# Configure the AWS Provider
provider "aws" {
  region = local.region
}

resource "aws_security_group" "api_sg" {
  name        = "${local.project}-sg"
  description = "${local.project} security group"

  ingress {
    description = "SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Docker container port for Flask app"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Docker port for a Flask app"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "lazarus_b" {
  ami           = local.linux_os
  instance_type = local.smallest_instance
  key_name = aws_key_pair.my-key-pair.key_name
  security_groups = [aws_security_group.api_sg.name]
  availability_zone = local.zone_b

  tags = {
    Name = local.project
  }

  user_data = <<-EOT
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo useradd docker_runner
  sudo passwd -d docker_runner
  sudo usermod -a -G docker docker_runner
  su - docker_runner
  docker pull registry.hub.docker.com/ej838639/lazarus:latest
  docker run \
  --name lazarus \
  -p 80:80 \
  -d \
  ej838639/lazarus:latest

  EOT
}

resource "aws_instance" "lazarus_c" {
  ami           = local.linux_os
  instance_type = local.smallest_instance
  key_name = aws_key_pair.my-key-pair.key_name
  security_groups = [aws_security_group.api_sg.name]
  availability_zone = local.zone_c

  tags = {
    Name = local.project
  }

  user_data = <<-EOT
  #!/bin/bash
  sudo yum update -y
  sudo amazon-linux-extras install docker -y
  sudo service docker start
  sudo useradd docker_runner
  sudo passwd -d docker_runner
  sudo usermod -a -G docker docker_runner
  su - docker_runner
  docker pull registry.hub.docker.com/ej838639/lazarus:latest
  docker run \
  --name lazarus \
  -p 80:80 \
  -d \
  ej838639/lazarus:latest

  EOT
}

output "hyperlink_lazarus_b" {
  value = "http://${aws_instance.lazarus_b.public_ip}"
}

output "hyperlink_lazarus_c" {
  value = "http://${aws_instance.lazarus_c.public_ip}"
}
