# Create a VPC to launch our instances into
resource "aws_vpc" "default" {
  cidr_block = "${var.vpc_cidr}"
  tags {
        Name = "tf-test-vpc"
  }
}

# Create an internet gateway to give our subnet access to the outside world
resource "aws_internet_gateway" "default" {
  vpc_id = "${aws_vpc.default.id}"
}

# Create an EIP to attach to NAT Gateway
resource "aws_eip" "nat" {
  vpc      = true
}

# Create a NAT Gateway
resource "aws_nat_gateway" "natgw" {
    allocation_id = "${aws_eip.nat.id}"
    subnet_id = "${aws_subnet.gateway-a.id}"
    depends_on = ["aws_internet_gateway.default"]
}

# Create a subnet to launch our instances into
resource "aws_subnet" "application-a" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet-app-a}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_az_a}"
  tags {
        Name = "subnet-app-a"
  }
}

resource "aws_subnet" "application-b" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet-app-b}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_az_b}"
  tags {
        Name = "subnet-app-b"
  }
}

resource "aws_subnet" "gateway-a" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet-gw-a}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_az_a}"
  tags {
        Name = "subnet-gw-a"
  }
}

resource "aws_subnet" "gateway-b" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet-gw-b}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_az_b}"
  tags {
        Name = "subnet-gw-b"
  }
}

resource "aws_subnet" "database-a" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet-db-a}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_az_a}"
  tags {
        Name = "subnet-db-a"
  }
}

resource "aws_subnet" "database-b" {
  vpc_id                  = "${aws_vpc.default.id}"
  cidr_block              = "${var.subnet-db-b}"
  map_public_ip_on_launch = false
  availability_zone       = "${var.aws_az_b}"
  tags {
        Name = "subnet-db-b"
  }
}
