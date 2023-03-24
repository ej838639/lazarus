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
