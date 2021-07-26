######################################################
## VARIABLES and LOCALS
######################################################

variable "aws_region" {
  description = "Default to Virginia region."
  default     = "eu-central-1"
}

variable "aws_az" {
  description = "Availability zone"
  default     = "eu-central-1a"
}

variable "vpc_router_cidr" {
  description = "VPC Router Cidr"
  default     = "10.0.0.0/16"
}

variable "router_subnet_internet_cidr" {
  description = "VPC Router - Subnet internet - Cidr"
  default     = "10.0.0.0/24"
}

variable "router_subnet_site_a_cidr" {
  description = "VPC Router - Subnet site A - Cidr"
  default     = "10.0.1.0/24"
}

variable "router_subnet_site_b_cidr" {
  description = "VPC Router - Subnet site A - Cidr"
  default     = "10.0.2.0/24"
}

variable "vpc_site_a_cidr" {
  description = "VPC Router Cidr"
  default     = "10.1.0.0/16"
}

variable "site_a_subnet_link_cidr" {
  description = "VPC site a - Subnet link - Cidr"
  default     = "10.1.0.0/24"
}

variable "site_a_subnet_a1_cidr" {
  description = "VPC site a - Subnet a1 - Cidr"
  default     = "10.1.1.0/24"
}

variable "site_a_subnet_a2_cidr" {
  description = "VPC site a - Subnet a2 - Cidr"
  default     = "10.1.2.0/24"
}

variable "vpc_site_b_cidr" {
  description = "VPC Router Cidr"
  default     = "10.2.0.0/16"
}

variable "site_b_subnet_link_cidr" {
  description = "VPC site b - Subnet link - Cidr"
  default     = "10.2.0.0/24"
}

variable "site_b_subnet_b1_cidr" {
  description = "VPC site b - Subnet b1 - Cidr"
  default     = "10.2.1.0/24"
}

variable "site_b_subnet_b2_cidr" {
  description = "VPC site b - Subnet b2 - Cidr"
  default     = "10.2.2.0/24"
}

variable "vyos_router_ip_eth0" {
  description = "Vyos IP - eth0 - Central Router"
  default     = "10.0.0.100"
}

variable "vyos_router_ip_eth1" {
  description = "Vyos IP - eth1 - Central Router"
  default     = "10.0.1.100"
}

variable "vyos_router_ip_eth2" {
  description = "Vyos IP - eth2 - Central Router"
  default     = "10.0.2.100"
}

variable "vyos_site_a_ip_eth0" {
  description = "Vyos IP - eth0 - Site A"
  default     = "10.1.0.100"
}

variable "vyos_site_a_ip_eth1" {
  description = "Vyos IP - eth1 - Site A"
  default     = "10.1.1.100"
}

variable "vyos_site_a_ip_eth2" {
  description = "Vyos IP - eth2 - Site A"
  default     = "10.1.2.100"
}

variable "vyos_site_b_ip_eth0" {
  description = "Vyos IP - eth0 - Site B"
  default     = "10.2.0.100"
}

variable "vyos_site_b_ip_eth1" {
  description = "Vyos IP - eth1 - Site B"
  default     = "10.2.1.100"
}

variable "vyos_site_b_ip_eth2" {
  description = "Vyos IP - eth2 - Site B"
  default     = "10.2.2.100"
}

variable "vyos_ami" {
  description = "Vyos AMI"
  default     = "ami-0788ed084b54d6dd1"
}

variable "vyos_instance_type" {
  description = "Vyos Instance Type"
  default     = "c4.large"
}

variable "key_pair" {
  description = "Key Pair to be used."
}

variable "bastion_ip" {
  description = "Bastion IP"
  default     = "10.0.0.200"
}

variable "clients_instance_type" {
  description = "Clients Instance Type"
  default     = "t2.micro"
}

variable "clients_ami" {
  description = "Clients AMI"
  default     = "ami-00f22f6155d6d92c5"
}

locals {
  clients = {
    client-a1-1 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.1.1.51",
      subnet_id              = aws_subnet.site_a_subnet_a1.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_a_allow_all.id],
      gateway                = aws_network_interface.int_site_a_eth1.private_ip
    },
    client-a1-2 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.1.1.52",
      subnet_id              = aws_subnet.site_a_subnet_a1.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_a_allow_all.id],
      gateway                = aws_network_interface.int_site_a_eth1.private_ip
    },
    client-a2-1 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.1.2.51",
      subnet_id              = aws_subnet.site_a_subnet_a2.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_a_allow_all.id],
      gateway                = aws_network_interface.int_site_a_eth2.private_ip
    },
    client-a2-2 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.1.2.52",
      subnet_id              = aws_subnet.site_a_subnet_a2.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_a_allow_all.id],
      gateway                = aws_network_interface.int_site_a_eth2.private_ip
    },
    client-b1-1 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.2.1.51",
      subnet_id              = aws_subnet.site_b_subnet_b1.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_b_allow_all.id],
      gateway                = aws_network_interface.int_site_b_eth1.private_ip
    },
    client-b1-2 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.2.1.52",
      subnet_id              = aws_subnet.site_b_subnet_b1.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_b_allow_all.id],
      gateway                = aws_network_interface.int_site_b_eth1.private_ip
    },
    client-b2-1 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.2.2.51",
      subnet_id              = aws_subnet.site_b_subnet_b2.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_b_allow_all.id],
      gateway                = aws_network_interface.int_site_b_eth2.private_ip
    },
    client-b2-2 = {
      instance_type          = var.clients_instance_type,
      ami                    = var.clients_ami
      private_ip             = "10.2.2.52",
      subnet_id              = aws_subnet.site_b_subnet_b2.id,
      key_name               = var.key_pair,
      vpc_security_group_ids = [aws_security_group.site_b_allow_all.id],
      gateway                = aws_network_interface.int_site_b_eth2.private_ip
    }

  }
}
