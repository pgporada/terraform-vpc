# Overview: terraform-vpc
Builds the following infrastructure

* VPC
* Public subnet
* Private subnet
* Availability Zone
* Routing tables
* NAT Gateway + EIP
* Internet Gateway

- - - -
# Usage
The Makefile will pull down a fresh secrets variable file from S3 during the **plan** and **apply** phases. This file does not exist by default.

    ENVIRONMENT=c6h12o6 make plan
    ENVIRONMENT=c6h12o6 make apply

- - - -
# Updating variables for an environment

    aws s3 --profile c6h12o6 cp s3://pgporada-state/terraform/vpc/c6h12o6.tfvars .
    vim .tfvars
    aws s3 --profile c6h12o6 cp c6h12o6.tfvars s3://pgporada-state/terraform/vpc/c6h12o6.tfvars

- - - -
# Theme Music
[David Dondero - Ashes on the Highway](https://daviddondero1.bandcamp.com/track/ashes-on-the-highway)
