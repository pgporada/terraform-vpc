variable "region" {}
variable "env" {}
variable "profile" {}
variable "vpc_cidr" {}
variable "state_bucket" {}
variable "account_id" {}

variable "private_subnets" {
  type = "list"
  default = []
}

variable "public_subnets" {
  type = "list"
  default = []
}

terraform {
  required_version = ">= 0.9.9"

  backend "s3" {
    encrypt = true
    acl     = "private"
  }
}

provider "aws" {
  region              = "${var.region}"
  profile             = "${var.profile}"
  allowed_account_ids = ["${var.account_id}"]
}

// Builds our VPC and a CIDR range
module "vpc" {
  source   = "modules/vpc/"
  vpc_cidr = "${var.vpc_cidr}"
  env      = "${var.env}"
  region   = "${var.region}"
}

// Returns data in a list
// Example: "us-east-2a,us-east-2b,us-east-2c"
module "azs" {
  source = "modules/azs/"
}

// Generate subnets and routing tables
module "public" {
  source   = "modules/public/"
  env      = "${var.env}"
  vpc_id   = "${module.vpc.vpc_id}"
  azs      = "${module.azs.azs}"
  region   = "${var.region}"
  vpc_cidr = "${var.vpc_cidr}"
  subnets  = "${var.public_subnets}"
}

// Creates an AWS managed NAT Gateway so private subnet instances can hit the internet
// This could also be handled by a t2.micro instance with an iptables ruleset
module "nat" {
  source            = "modules/nat/"
  public_subnet_ids = "${module.public.subnet_ids}"
}

// Generate subnets and routing tables
module "private" {
  source          = "modules/private"
  env             = "${var.env}"
  vpc_id          = "${module.vpc.vpc_id}"
  azs             = "${module.azs.azs}"
  nat_gateway_ids = "${module.nat.gateway_ids}"
  region          = "${var.region}"
  vpc_cidr        = "${var.vpc_cidr}"
  subnets         = "${var.private_subnets}"
}

output "environment" {
  value = "${var.env}"
}

output "vpc_cidr" {
  value = "${var.vpc_cidr}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "azs" {
  value = "${module.azs.azs}"
}

output "nat_private_ips" {
  value = "${module.nat.private_ips}"
}

output "nat_public_ips" {
  value = "${module.nat.public_ips}"
}

output "nat_nic_ids" {
  value = "${module.nat.nic_ids}"
}

output "public_subnet_ids" {
  value = "${module.public.subnet_ids}"
}

output "public_route_tables" {
  value = "${module.public.route_tables}"
}

output "private_subnet_ids" {
  value = "${module.private.subnet_ids}"
}

output "private_route_tables" {
  value = "${module.private.route_tables}"
}
