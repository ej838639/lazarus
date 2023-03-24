resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_lb_target_group" "target_group_alb_http" {
  name        = local.target_group_alb_http
  target_type = "instance"
  protocol    = "HTTP"
  port        = 80
  vpc_id      = aws_default_vpc.default.id
  ip_address_type = "ipv4"
  tags = {
    Key=local.project
  }
}