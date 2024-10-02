variable "vpn_ssh_key" {
  description = "vpn ssh public key"
  type = string
  default = ".terraform/local/vpn_key"
  # default = "vpn_key"
}

variable "ec2_instance_type" {
  description = "type of instance to provision"
  type = string
  default = "t2.micro"
}

variable "ec2_username" {
  description = "server username"
  type = string
  default = "admin"
}

variable "availability_zone" {
  description = "availability region of your system"
  type = string
  default = "eu-central-1a"
}
