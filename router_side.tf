######################################################
## VPC
######################################################

resource "aws_vpc" "router" {
  cidr_block           = var.vpc_router_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    "Name" = "vpc-router"
  }
}

######################################################
## SUBNETS
######################################################



resource "aws_subnet" "router_subnet_internet" {
  vpc_id            = aws_vpc.router.id
  cidr_block        = var.router_subnet_internet_cidr
  availability_zone = var.aws_az

  tags = {
    Name = "vpc-router-subnet-internet"
  }
}

resource "aws_subnet" "router_subnet_site_a" {
  vpc_id            = aws_vpc.router.id
  cidr_block        = var.router_subnet_site_a_cidr
  availability_zone = var.aws_az

  tags = {
    Name = "vpc-router-subnet-site-a"
  }
}

resource "aws_subnet" "router_subnet_site_b" {
  vpc_id            = aws_vpc.router.id
  cidr_block        = var.router_subnet_site_b_cidr
  availability_zone = var.aws_az

  tags = {
    Name = "vpc-router-subnet-site-b"
  }

}

######################################################
## INTERNET GATEWAY
######################################################

resource "aws_internet_gateway" "router_igw" {
  vpc_id = aws_vpc.router.id
  tags = {
    Name = "igw-router"
  }
}

######################################################
## PEERING CONNECTION
######################################################

resource "aws_vpc_peering_connection" "router_site_a" {
  vpc_id      = aws_vpc.router.id
  peer_vpc_id = aws_vpc.site_a.id
  auto_accept = true
  tags = {
    Name = "Peering-router-to-site-a"
  }
}

resource "aws_vpc_peering_connection" "router_site_b" {
  vpc_id      = aws_vpc.router.id
  peer_vpc_id = aws_vpc.site_b.id
  auto_accept = true
  tags = {
    Name = "Peering-router-to-site-b"
  }
}

######################################################
## ROUTE TABLE / ROUTE TABLE ASSOCIATION
######################################################

resource "aws_route_table" "router_internet" {

  vpc_id = aws_vpc.router.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.router_igw.id
  }
  route {
    cidr_block                = var.vpc_site_a_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.router_site_a.id
  }
  route {
    cidr_block                = var.vpc_site_b_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.router_site_b.id
  }

  tags = {
    "Name" = "router-internet-rt"
  }
}

resource "aws_route_table_association" "router_internet" {
  subnet_id      = aws_subnet.router_subnet_internet.id
  route_table_id = aws_route_table.router_internet.id
}

resource "aws_route_table" "router_site_a" {

  vpc_id = aws_vpc.router.id

  route {
    cidr_block                = var.vpc_site_a_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.router_site_a.id
  }

  tags = {
    "Name" = "router-site-a-rt"
  }
}

resource "aws_route_table_association" "router_site_a" {
  subnet_id      = aws_subnet.router_subnet_site_a.id
  route_table_id = aws_route_table.router_site_a.id
}

resource "aws_route_table" "router_site_b" {

  vpc_id = aws_vpc.router.id

  route {
    cidr_block                = var.vpc_site_b_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.router_site_b.id
  }

  tags = {
    "Name" = "router-site-b-rt"
  }
}

resource "aws_route_table_association" "router_site_b" {
  subnet_id      = aws_subnet.router_subnet_site_b.id
  route_table_id = aws_route_table.router_site_b.id
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

resource "aws_security_group" "router_allow_all" {
  name = "router-allow-all"
  vpc_id = aws_vpc.router.id

  ingress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "vpc-router-allow-all"
  }
}

######################################################
## AWS INSTANCE - VYOS ROUTER
######################################################

resource "aws_instance" "vyos_router" {
  ami                         = var.vyos_ami
  instance_type               = var.vyos_instance_type
  key_name                    = var.key_pair

  network_interface {
    device_index         = 0
    network_interface_id = "${aws_network_interface.int_router_eth0.id}"
  }

  network_interface {
    device_index         = 1
    network_interface_id = "${aws_network_interface.int_router_eth1.id}"
  }

  network_interface {
    device_index         = 2
    network_interface_id = "${aws_network_interface.int_router_eth2.id}"
  }

  tags = {
    Name = "vyos_router"
  }
}

######################################################
## NETWORK INTERFACES
######################################################

resource "aws_network_interface" "int_router_eth0" {
  subnet_id         = aws_subnet.router_subnet_internet.id
  private_ips       = [var.vyos_router_ip_eth0]
  security_groups   = [aws_security_group.router_allow_all.id]
  source_dest_check = false
}

resource "aws_network_interface" "int_router_eth1" {
  subnet_id         = aws_subnet.router_subnet_site_a.id
  private_ips       = [var.vyos_router_ip_eth1]
  security_groups   = [aws_security_group.router_allow_all.id]
  source_dest_check = false
}

resource "aws_network_interface" "int_router_eth2" {
  subnet_id         = aws_subnet.router_subnet_site_b.id
  private_ips       = [var.vyos_router_ip_eth2]
  security_groups   = [aws_security_group.router_allow_all.id]
  source_dest_check = false
}

######################################################
## ELASTIC IP
######################################################

resource "aws_eip" "router_public_ip" {
  depends_on = [
    aws_instance.vyos_router
  ]

  vpc                       = true
  network_interface         = aws_network_interface.int_router_eth0.id
  associate_with_private_ip = var.vyos_router_ip_eth0

  tags = {
    Name = "Router Public IP"
  }
}
