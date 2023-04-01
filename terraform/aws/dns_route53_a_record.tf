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

resource "aws_route53_record" "www" {
  zone_id = "Z09672325EJGTAQ1VGC8"
  name    = "sntxrr.org"
  type    = "A"
  ttl     = 300
  records = [aws_eip.eip_b.public_ip,aws_eip.eip_c.public_ip]
}