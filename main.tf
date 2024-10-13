terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.51.1"
    }
  }
}

# Key-pair
resource "tls_private_key" "vpn_ed25519" {
  algorithm = "ED25519"
}

resource "aws_key_pair" "vpn_ssh_keys" {
  key_name   = var.vpn_ssh_key
  public_key = tls_private_key.vpn_ed25519.public_key_openssh
}

# Save key on host
resource "local_file" "private_key" {
  content = tls_private_key.vpn_ed25519.private_key_openssh
  filename = var.vpn_ssh_key
}

# VPC
resource "aws_vpc" "vpn_server_vpc" {
  cidr_block = "10.6.9.0/28"
  enable_dns_hostnames = true
  tags = {
    Name = "vpn_vpc"
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
  cidr_block = aws_vpc.vpn_server_vpc.cidr_block
  availability_zone = var.availability_zone
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
  name = "vpn-server-SG"
  description = "Allow vpn, ssh, http and https"
  vpc_id = aws_vpc.vpn_server_vpc.id

  ingress {
    description = "allow HTTPS"
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow HTTP"
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "allow SSH"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow WireGuard"
    protocol = "udp"
    from_port = 51820
    to_port = 51820
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "Allow OpenVpn"
  #   protocol = "tcp"
  #   from_port = 943
  #   to_port = 943
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  # ingress {
  #   description = "Allow OpenVpn"
  #   protocol = "udp"
  #   from_port = 1194
  #   to_port = 1194
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow ssh, web and vpn"
  }
}

# ec2 instance
resource "aws_instance" "vpn_server" {
  ami = "ami-075d8cd2ff03fa6e9"
  instance_type = var.ec2_instance_type
  key_name = aws_key_pair.vpn_ssh_keys.key_name
  associate_public_ip_address = true
  availability_zone = var.availability_zone

  # provisioner "remote-exec" {
  #   inline = [
  #     "sudo apt update",
  #     "sudo apt upgrade -y",
  #     "sudo apt install ca-certificates curl tzdata wget net-tools gnupg ufw certbot -y",
  #     "sudo ufw allow 80 && sudo ufw allow 22 && sudo ufw allow 443 && sudo ufw allow 943 && sudo ufw allow 1194/udp",
  #     "sudo ufw enable",
  #     "sudo systemctl start ufw",
  #     "wget https://as-repository.openvpn.net/as/install.sh -O /tmp/openvpn-install.sh",
  #     "sudo chmod +x /tmp/openvpn-install.sh",
  #     "DEBIAN_FRONTEND=noninteractive yes | sudo /tmp/openvpn-install.sh >> output-$(date).log",
  #     #"sudo certbot certonly --standalone --preferred-challenges http -d yusic.zapto.org"
  #   ]

  #   connection {
  #     type        = "ssh"
  #     user        = "admin"
  #     private_key = file("${var.vpn_ssh_key}")
  #     host        = self.public_ip
  #   }
  # }

  # Set key permissions

  tags = {
    Name = "Vpn Server"
  }
}