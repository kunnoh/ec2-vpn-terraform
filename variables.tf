variable "vpn_ssh_key" {
  description = "vpn ssh private key"
  type = string
  default = ".terraform/local/priv_key"
}

variable "ec2_instance_type" {
  description = "type of instance"
  type = string
  default = "t2.micro"
}

variable "ec2_instance_ami" {
  description = "type of instance ami"
  type = string
  default = "ami-075d8cd2ff03fa6e9"
}

variable "ec2_username" {
  description = "server username"
  type = string
  default = "admin"
}

variable "availability_zone" {
  description = "availability region for the ec2"
  type = string
  default = "eu-central-1a"
}
