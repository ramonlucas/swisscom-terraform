######################################################
## OUTPUT IPs
######################################################

output "bastion_ip" {
  description = "Bastion Host Public IP"
  value       = aws_instance.bastion.*.public_ip[0]
}

output "router_public_ip" {
  description = "Bastion Host Public IP"
  value       = aws_eip.router_public_ip.public_ip
}
