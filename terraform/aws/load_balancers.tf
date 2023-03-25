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

resource "aws_default_subnet" "default_2b" {
  availability_zone = "us-west-2b"

  tags = {
    Name = "Default subnet for us-west-2b"
  }
}

resource "aws_default_subnet" "default_2c" {
  availability_zone = "us-west-2c"

  tags = {
    Name = "Default subnet for us-west-2c"
  }
}

resource "aws_lb" "load_balancer_alb" {
  name               = local.load_balancer_alb
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.api_sg.id]
  subnets            = ["${aws_default_subnet.default_2b.id}","${aws_default_subnet.default_2c.id}"]

  tags = {
    Key=local.project
  }
}

resource "aws_lb_listener" "listener_https_alb" {
  load_balancer_arn = aws_lb.load_balancer_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = "arn:aws:acm:us-west-2:254394382277:certificate/17710933-2ac8-4393-b004-73a37e8100fb"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.target_group_alb_http.arn
  }
}

resource "aws_lb_listener" "listener_http_alb" {
  load_balancer_arn = aws_lb.load_balancer_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_eip" "eip_b" {
  tags = {
    Key=local.project
    Zone="zone_b"
  }
}

resource "aws_eip" "eip_c" {
  tags = {
    Key=local.project
    Zone="zone_c"
  }
}

resource "aws_route53_zone" "sntxrr" {
  name = "sntxrr.org"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.sntxrr.zone_id
  name    = "sntxrr.org"
  type    = "A"
  ttl     = 300
  records = [aws_eip.eip_b.public_ip,aws_eip.eip_c.public_ip]
}