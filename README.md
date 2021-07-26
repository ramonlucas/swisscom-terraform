swisscom-terraform Quickstart Guide
============================================================

This code will configure the Opensource Network Appliance VyOS (https://vyos.io) in
AWS environment and utilize it as a router to route traffic between two others sites
to demonstrate network, automation and cloud skills.

![AWS topology](swisscom-aws.png?raw=true "AWS topology")

Pre-requisites
--------------

The following pre-requisites must be met prior to executing the lab:

  - Terraform version v1.0.2 must be installed
  - You must have AWS credentials properly configured https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
  - You must have a valid VyOS subscription (Pay-as-You-Go) on AWS Marketplace. https://aws.amazon.com/marketplace/pp/prodview-6i4irz5gqfkru
  - You must create a Key Pair on AWS console before the setup.
  - Take a look at your quotas. This project create at least 3 VPCs. By default, there's a limit of 5 VPCs per region. https://docs.aws.amazon.com/vpc/latest/userguide/amazon-vpc-limits.html

Setup and Configuration
-----------------------

From your personal computer, download this repository.

    git clone https://github.com/ramonlucas/swisscom-terraform

Change the `key_pair` variable on `terraform.tfvars` file with the name of your key pair created on AWS.

Execute terraform init

    terraform init

Execute terraform plan

    terraform plan

Check if there's any error

Execute terraform apply

    terraform apply

After that, check if your infrastructure has been deployed.

Terraform will output the Bastion Host Public IP. This ip should be used to connect to environment.

Continue the setup on https://github.com/ramonlucas/swisscom-ansible to configure the routers.