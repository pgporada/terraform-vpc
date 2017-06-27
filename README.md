# Overview: terraform-vpc
Builds the following infrastructure

* VPC
* Public subnet(s)
* Private subnet(s)
* Availability Zone(s)
* Routing tables
* NAT Gateway(s) + EIP
* Internet Gateway

For more terraform related docs, please see our [wiki](https://letsencrypt.atlassian.net/wiki/display/~pporada/Terraform).

- - - -
# Usage
The Makefile will pull down a fresh secrets variable file from S3 during the **plan** and **apply** phases. This file does not exist by default.

    ENVIRONMENT=c6h12o6 make plan
    ENVIRONMENT=c6h12o6 make apply

Create a new environment so we don't have to use the default

    terraform env new ${ENV_NAME}

    # TODO
    # This should be used to create an environment if it doesn't exist
    # ENVIRONMENT=c6h12o6 make plan

Get vars

    aws s3 --profile someawsprofile cp s3://somebucket/terraform/vpc/somevars.tfvars .

Push vars

    aws s3 --profile someawsprofile cp somevars.tfvars s3://somebucket/terraform/vpc/somevars.tfvars

- - - -
# Theme Music
[Erik Petersen - Old Tyme Memory](https://www.youtube.com/watch?v=8uziTOL4zOs)

- - - -
# License and Author Info
(C) [Phil Porada](https://philporada.com) 2016 - philporada@gmail.com
