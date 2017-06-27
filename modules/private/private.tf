variable "env" {}
variable "vpc_id" {}
variable "azs" {}
variable "region" {}
variable "vpc_cidr" {}
variable "nat_gateway_ids" {}
variable "subnets" { type = "list" }

resource "aws_route_table" "private" {
  count  = "${length(var.subnets)}"
  vpc_id = "${var.vpc_id}"

  tags {
    Name      = "${var.env}_routetable_${element(split(",", var.azs), count.index)}"
    TERRAFORM = "true"
    ENV       = "${var.env}"
  }
}

resource "aws_route" "private" {
  #    count                   = "${length(compact(split(",", var.azs)))}"
  count                  = "${length(var.subnets)}"
  route_table_id         = "${element(aws_route_table.private.*.id, count.index)}"
  nat_gateway_id         = "${element(split(",", var.nat_gateway_ids), count.index)}"
  destination_cidr_block = "0.0.0.0/0"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.subnets)}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}

resource "aws_vpc_endpoint" "private" {
  vpc_id          = "${var.vpc_id}"
  service_name    = "com.amazonaws.${var.region}.s3"
  route_table_ids = ["${aws_route_table.private.*.id}"]

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid":"AllowAll",
            "Effect":"Allow",
            "Principal":"*",
            "Action":"*",
            "Resource":"*"
        }
    ]
}
POLICY
}

resource "aws_subnet" "private" {
  count  = "${length(var.subnets)}"
  vpc_id = "${var.vpc_id}"

  # cidr_block        = "${cidrsubnet(var.vpc_cidr, 2, count.index+2)}"
  cidr_block        = "${var.subnets[count.index]}"
  availability_zone = "${element(split(",", var.azs), count.index)}"

  tags {
    Name      = "${var.env}_private_subnet_${replace(var.region,"-","")}_${element(split(",", var.azs), count.index)}"
    TERRAFORM = "true"
    ENV       = "${var.env}"
  }
}

output "subnet_ids" {
  value = "${join(",", aws_subnet.private.*.id)}"
}

output "route_tables" {
  value = "${join(",", aws_route_table.private.*.id)}"
}
