terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~>5.51.1"
    }
  }
}

provider "aws" {
    alias = "Europe"
    region = "eu-central-1"
}

data "aws_region" "current" {
  provider = aws.Europe
}

# key-pair
# resource "tls_private_key" "rsa_4096" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# variable "key_name" {
  
# }

# resource "aws_key_pair" "vpn_ssh_keys" {
#   key_name   = var.key_name
#   public_key = tls_private_key.rsa_4096.public_key_openssh
# }

# vpc
resource "aws_vpc" "vpn_server_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "vpn-vpc"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.vpn_server_vpc.id
}

# route table
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
    Name = "vpn_route_table_main"
  }
}

# subnet
resource "aws_subnet" "vpn_subnet_main" {
  vpc_id = aws_vpc.vpn_server_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"
  tags = {
    Name = "vpn-subnet"
  }
}

# subnet route table associate
resource "aws_route_table_association" "a" {
  subnet_id = aws_subnet.vpn_subnet_main.id
  route_table_id = aws_route_table.vpn_route_table.id
}

# create security groups
resource "aws_security_group" "allow_web" {
  name = "alloweb_traffic"
  description = "Allow web"
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
    Name = "allow web traffic, ssh"
  }
}

# network interface
resource "aws_network_interface" "vpn_server_nic" {
  subnet_id = aws_subnet.vpn_subnet_main.id
  private_ips = [ "10.0.1.49" ]
  security_groups = [ aws_security_group.allow_web.id ]
}

# elastic ip
resource "aws_eip" "vpn_eip" {
  domain = "vpc"
  network_interface = aws_network_interface.vpn_server_nic.id
  associate_with_private_ip = "10.0.1.49"
  depends_on = [ aws_internet_gateway.gw ]
}

# create ec2 instance
resource "aws_instance" "vpn_server" {
  instance_type = "t2.micro"
  ami           = "ami-075d8cd2ff03fa6e9"
  availability_zone = "eu-central-1a"

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.vpn_server_nic.id
  }

  user_data = <<-EOF
    sudo apt update -y
    sudo apt upgrade -y
    sudo apt install nginx
    sudo systemctl enable nginx
    sudo systemctl start nginx
  EOF
  tags = {
    Name = "vpnServer"
  }
}