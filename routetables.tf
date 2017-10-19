# Create the VPC route tables
resource "aws_route_table" "nat_routes" {
  vpc_id = "${aws_vpc.default.id}"
  route {
     cidr_block = "0.0.0.0/0"
     nat_gateway_id = "${aws_nat_gateway.natgw.id}"
  }
  tags {
        Name = "nat-route"
  }
}

resource "aws_route_table" "ig_routes" {
  vpc_id = "${aws_vpc.default.id}"
  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = "${aws_internet_gateway.default.id}"
  }
  tags {
        Name = "ig-route"
  }
}

# Route table associations
resource "aws_route_table_association" "app-nat-a" {
    subnet_id = "${aws_subnet.application-a.id}"
    route_table_id = "${aws_route_table.nat_routes.id}"
}
resource "aws_route_table_association" "app-nat-b" {
    subnet_id = "${aws_subnet.application-b.id}"
    route_table_id = "${aws_route_table.nat_routes.id}"
}
resource "aws_route_table_association" "db-nat-a" {
    subnet_id = "${aws_subnet.database-a.id}"
    route_table_id = "${aws_route_table.nat_routes.id}"
}
resource "aws_route_table_association" "db-nat-b" {
    subnet_id = "${aws_subnet.database-b.id}"
    route_table_id = "${aws_route_table.nat_routes.id}"
}
resource "aws_route_table_association" "db-ig-a" {
    subnet_id = "${aws_subnet.gateway-a.id}"
    route_table_id = "${aws_route_table.ig_routes.id}"
}
resource "aws_route_table_association" "db-ig-b" {
    subnet_id = "${aws_subnet.gateway-b.id}"
    route_table_id = "${aws_route_table.ig_routes.id}"
}
