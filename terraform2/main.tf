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

  tags = {
    Name = "lazarus"
  }
}

output "instance_public_ip" {
  value = aws_instance.lazarus.public_ip
}
