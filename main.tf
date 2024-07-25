terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.51.1"
    }
  }
}

# Key-pair
resource "tls_private_key" "vpn_rsa_4096" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "vpn_ssh_keys" {
  key_name   = var.vpn_ssh_key
  public_key = tls_private_key.vpn_rsa_4096.public_key_openssh
}

# Save key on host
resource "local_file" "private_key" {
  content = tls_private_key.vpn_rsa_4096.private_key_pem
  filename = var.vpn_ssh_key
}

# VPC
resource "aws_vpc" "vpn_server_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpn vpc"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpn_server_vpc.id
}

# Route Table
resource "aws_route_table" "vpn_route_table" {
  vpc_id = aws_vpc.vpn_server_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "vpn route table"
  }
}

# Subnet
resource "aws_subnet" "vpn_subnet_main" {
  vpc_id = aws_vpc.vpn_server_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "vpn subnet"
  }
}

# Subnet Route Table association
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.vpn_subnet_main.id
  route_table_id = aws_route_table.vpn_route_table.id
}

# Security Groups
resource "aws_security_group" "allow_traffic" {
  name = "alloweb_traffic"
  description = "Allow openvpn"
  vpc_id = aws_vpc.vpn_server_vpc.id

  ingress {
    description = "https"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ssh"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow ssh and openvpn"
  }
}

# ec2 instance
resource "aws_instance" "vpn_server" {
  instance_type = var.ec2_instance_type
  ami = "ami-075d8cd2ff03fa6e9"
  availability_zone = "eu-central-1a"
  key_name = aws_key_pair.vpn_ssh_keys.key_name
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "sudo apt upgrade -y",
      "sudo apt install openvpn nginx -y",
      "sudo systemctl enable openvpn",
      "sudo systemctl start openvpn",
      "sudo systemctl enable nginx",
      "sudo systemctl start nginx"
    ]

    connection {
      type        = "ssh"
      user        = "admin"
      private_key = file("${var.vpn_ssh_key}")
      host        = self.public_ip
    }
  }

  tags = {
    Name = "vpnServer"
  }
}