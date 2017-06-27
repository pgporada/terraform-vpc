variable "env" {}
variable "vpc_id" {}
variable "azs" {}
variable "region" {}
variable "vpc_cidr" {}
variable "subnets" { type = "list" }

resource "aws_internet_gateway" "igw" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name      = "${var.env}_igw_${replace(var.region,"-","")}"
    TERRAFORM = "true"
    ENV       = "${var.env}"
  }
}

resource "aws_route_table" "public" {
  count  = "${length(var.subnets)}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name      = "${var.env}_routetable_${element(split(",", var.azs), count.index)}"
    TERRAFORM = "true"
    ENV       = "${var.env}"
  }
}

resource "aws_route" "public" {
  count                  = "${length(var.subnets)}"
  route_table_id         = "${element(aws_route_table.public.*.id, count.index)}"
  gateway_id             = "${aws_internet_gateway.igw.id}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "public" {
  count          = "${length(var.subnets)}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_subnet" "public" {
  count                   = "${length(var.subnets)}"
  vpc_id                  = "${var.vpc_id}"
  cidr_block              = "${var.subnets[count.index]}"
  availability_zone       = "${element(split(",", var.azs), count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name      = "${var.env}_public_subnet_${replace(var.region,"-","")}_${element(split(",", var.azs), count.index)}"
    TERRAFORM = "true"
    ENV       = "${var.env}"
  }
}

output "subnet_ids" {
  value = "${join(",", aws_subnet.public.*.id)}"
}

output "route_tables" {
  value = "${join(",", aws_route_table.public.*.id)}"
}
