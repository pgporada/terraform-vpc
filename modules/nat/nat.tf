variable "public_subnet_ids" {}

resource "aws_eip" "nat_gateway" {
  count = "${length(compact(split(",", var.public_subnet_ids)))}"

  # Not usable until https://github.com/hashicorp/terraform/issues/12570
  #  count = "${var.use_aws_nat_gw == 1 ? length(compact(split(",", var.public_subnet_ids))) : 0}"
  vpc = true
}

resource "aws_nat_gateway" "gateway" {
  count = "${length(compact(split(",", var.public_subnet_ids)))}"

  # Not usable until https://github.com/hashicorp/terraform/issues/12570
  #  count = "${var.use_aws_nat_gw == 1 ? length(compact(split(",", var.public_subnet_ids))) : 0}"
  subnet_id = "${element(split(",", var.public_subnet_ids), count.index)}"

  allocation_id = "${element(aws_eip.nat_gateway.*.id, count.index)}"
}

output "eip_ids" {
  value = "${join(",", aws_eip.nat_gateway.*.id)}"
}

output "gateway_ids" {
  value = "${join(",", aws_nat_gateway.gateway.*.id)}"
}

output "public_ips" {
  value = "${join(",", aws_nat_gateway.gateway.*.public_ip)}"
}

output "private_ips" {
  value = "${join(",", aws_nat_gateway.gateway.*.private_ip)}"
}

output "nic_ids" {
  value = "${join(",", aws_nat_gateway.gateway.*.network_interface_id)}"
}
