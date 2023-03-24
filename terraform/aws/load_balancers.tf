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

resource "aws_lb_target_group_attachment" "tg_attachment_alb_http_b" {
    target_group_arn = aws_lb_target_group.target_group_alb_http.arn
    target_id        = aws_instance.lazarus_b.id
    port             = 80
}

resource "aws_lb_target_group_attachment" "tg_attachment_alb_http_c" {
    target_group_arn = aws_lb_target_group.target_group_alb_http.arn
    target_id        = aws_instance.lazarus_c.id
    port             = 80
}