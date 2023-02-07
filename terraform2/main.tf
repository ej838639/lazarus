terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-west-2"
}

locals {
  smallest_instance = "t2.micro"
  linux_os = "ami-06e85d4c3149db26a"
}

resource "aws_instance" "lazarus" {
  ami           = local.linux_os
  instance_type = local.smallest_instance
  key_name = "tf-key-pair"

  tags = {
    Name = "lazarus"
  }
}

resource "aws_key_pair" "tf-key-pair" {
  key_name = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "local_file" "tf-key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "tf-key-pair"
}

output "instance_public_ip" {
  value = aws_instance.lazarus.public_ip
}
