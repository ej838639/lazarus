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
  smallest_instance = "t2.micro"
  linux_os = "ami-06e85d4c3149db26a"
  project = "lazarus"
}

resource "aws_key_pair" "tf-key-pair" {
  key_name = "tf-key-pair-name"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair-name.pem"
}

# Configure the AWS Provider
provider "aws" {
  region = local.region
}

resource "aws_instance" "lazarus" {
  ami             = local.linux_os
  instance_type   = local.smallest_instance
  key_name        = "tf-key-pair-name"
  security_groups = [aws_security_group.api_sg.name]

  tags = {
    Name = local.project
  }
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
    description = "Docker port for a Flask app"
    protocol    = "tcp"
    from_port   = 3000
    to_port     = 3000
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_public_ip" {
  value = aws_instance.lazarus.public_ip
}
