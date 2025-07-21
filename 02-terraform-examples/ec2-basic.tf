resource "aws_security_group" "ssh" {
  name        = "allow_ssh"
  description = "Autorise SSH depuis n'importe où"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_instance" "web" {
  ami                         = var.instance_ami
  instance_type               = "t2.micro"
  key_name                    = var.ssh_key_name
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  associate_public_ip_address = true

  tags = {
    Name = "example-web-instance"
  }
}
