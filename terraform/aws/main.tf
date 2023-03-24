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
  project = "lazarus-prod"

  load_balancer_alb = "${local.project}-alb"
  load_balancer_nlb = "${local.project}-nlb"
  target_group_alb_http = "${local.project}-alb-http-group"
  target_group_nlb_http = "${local.project}-nlb-http-group"
  target_group_nlb_https = "${local.project}-nlb-https-group"
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

  ingress {
    description = "Port to receive https traffic on load balancers"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
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
