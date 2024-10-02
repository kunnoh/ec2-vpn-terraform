# public IP
output "instance_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.vpn_server
}

# public dns
output "instance_public_dns" {
  description = "PublicDNS of the EC2 instance"
  value       = aws_instance.vpn_server.public_dns
}
