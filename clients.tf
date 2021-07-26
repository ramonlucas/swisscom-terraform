######################################################
## AWS INSTANCE - BASTION HOST
######################################################

resource "aws_instance" "bastion" {
  ami                         = "ami-00f22f6155d6d92c5"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.router_subnet_internet.id
  source_dest_check           = false
  private_ip                  = var.bastion_ip
  associate_public_ip_address = true
  key_name                    = var.key_pair
  vpc_security_group_ids      = [aws_security_group.router_allow_all.id]
  user_data                   = <<EOF
#!/bin/bash
yum update
yum install -y vim git
sudo amazon-linux-extras install ansible2
EOF

  tags = {
    Name = "bastion-host"
  }
}

######################################################
## AWS INSTANCE - CLIENTS
######################################################

resource "aws_instance" "clients" {
  for_each               = local.clients

  ami                    = each.value.ami
  instance_type          = each.value.instance_type
  subnet_id              = each.value.subnet_id
  private_ip             = each.value.private_ip
  key_name               = each.value.key_name
  user_data              = data.template_cloudinit_config.config[each.key].rendered
  vpc_security_group_ids = each.value.vpc_security_group_ids

  tags = {
    Name = "pc-${each.key}"
  }
}

data "template_cloudinit_config" "config" {
  for_each               = local.clients

  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
#!/bin/bash
/sbin/route del default
/sbin/route add default gw "${each.value.gateway}"
sed -i 's/nameserver.*/nameserver 1.1.1.1/g' /etc/resolv.conf
EOF
  }
}
