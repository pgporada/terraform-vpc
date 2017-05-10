variable "public_subnet_ids" {}

resource "aws_eip" "nat_gateway" {
    count 	= 1
    vpc     = true
}

resource "aws_nat_gateway" "gateway" {
    count           = 1
    subnet_id       = "${element(split(",", var.public_subnet_ids), count.index)}"
    allocation_id   = "${element(aws_eip.nat_gateway.*.id, count.index)}"
}

output "eip_ids" { value = "${join(",", aws_eip.nat_gateway.*.id)}" }
output "gateway_ids" { value = "${join(",", aws_nat_gateway.gateway.*.id)}" }
output "public_ips" { value = "${join(",", aws_nat_gateway.gateway.*.public_ip)}" }
output "private_ips" { value = "${join(",", aws_nat_gateway.gateway.*.private_ip)}" }
output "nic_ids" { value = "${join(",", aws_nat_gateway.gateway.*.network_interface_id)}" }
