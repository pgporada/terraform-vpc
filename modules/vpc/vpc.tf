variable "region" {}
variable "env" {}
variable "vpc_cidr" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags {
    Name      = "${var.env}_${replace(var.region,"-","")}"
    ENV       = "${var.env}"
    TERRAFORM = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "vpc_cidr" {
  value = "${aws_vpc.vpc.cidr_block}"
}
