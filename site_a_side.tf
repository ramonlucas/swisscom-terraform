######################################################
## VPC
######################################################

resource "aws_vpc" "site_a" {
  cidr_block           = var.vpc_site_a_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "vpc-site-a"
  }
}

######################################################
## SUBNETS
######################################################

resource "aws_subnet" "site_a_subnet_link" {
  vpc_id            = aws_vpc.site_a.id
  cidr_block        = var.site_a_subnet_link_cidr
  availability_zone = var.aws_az

  tags = {
    Name = "vpc-site-a-subnet-link"
  }
}

resource "aws_subnet" "site_a_subnet_a1" {
  vpc_id            = aws_vpc.site_a.id
  cidr_block        = var.site_a_subnet_a1_cidr
  availability_zone = var.aws_az

  tags = {
    Name = "vpc-site-a-subnet-a1"
  }
}

resource "aws_subnet" "site_a_subnet_a2" {
  vpc_id            = aws_vpc.site_a.id
  cidr_block        = var.site_a_subnet_a2_cidr
  availability_zone = var.aws_az

  tags = {
    Name = "vpc-site-a-subnet-a2"
  }
}

######################################################
## ROUTE TABLE / ROUTE TABLE ASSOCIATION
######################################################

resource "aws_route_table" "site_a_link" {
  vpc_id = aws_vpc.site_a.id

  route {
    cidr_block                = var.vpc_router_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.router_site_a.id
  }

  tags = {
    "Name" = "site-a-link-rt"
  }
}

resource "aws_route_table_association" "site_a_link" {
  subnet_id      = aws_subnet.site_a_subnet_link.id
  route_table_id = aws_route_table.site_a_link.id
}

######################################################
## SECURITY GROUP
######################################################

/*
 * The firewall is with rules "allow all" just for test purpose and demonstration 
 * of knowledge in skills like Network, Automate and Cloud.
 * I strongly recommend that in production environments these rules are as restrictive 
 * as possible following the principles of least privilege.
*/

resource "aws_security_group" "site_a_allow_all" {
  name   = "site-a-allow-all"
  vpc_id = aws_vpc.site_a.id

  ingress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-site-a-allow-all"
  }
}

######################################################
## AWS INSTANCE - VYOS ROUTER
######################################################

resource "aws_instance" "vyos_site_a" {
  ami                    = var.vyos_ami
  instance_type          = var.vyos_instance_type
  key_name               = var.key_pair

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.int_site_a_eth0.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.int_site_a_eth1.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.int_site_a_eth2.id}"
  }

  tags = {
    Name = "vyos_site_a"
  }
}

######################################################
## NETWORK INTERFACES
######################################################

resource "aws_network_interface" "int_site_a_eth0" {
  subnet_id         = aws_subnet.site_a_subnet_link.id
  private_ips       = [var.vyos_site_a_ip_eth0]
  security_groups   = [aws_security_group.site_a_allow_all.id]
  source_dest_check = false
}

resource "aws_network_interface" "int_site_a_eth1" {
  subnet_id         = aws_subnet.site_a_subnet_a1.id
  private_ips       = [var.vyos_site_a_ip_eth1]
  security_groups   = [aws_security_group.site_a_allow_all.id]
  source_dest_check = false
}

resource "aws_network_interface" "int_site_a_eth2" {
  subnet_id         = aws_subnet.site_a_subnet_a2.id
  private_ips       = [var.vyos_site_a_ip_eth2]
  security_groups   = [aws_security_group.site_a_allow_all.id]
  source_dest_check = false
}
