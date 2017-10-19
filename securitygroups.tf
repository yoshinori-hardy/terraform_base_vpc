resource "aws_security_group" "vpn-sg" {
  name = "vpn-sg"
  description = "Allow inbound VPN connections"
  vpc_id = "${aws_vpc.default.id}"
  ingress {
    from_port = 4500
    to_port = 4500
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    },
  ingress {
    from_port = 500
    to_port = 500
    protocol = "udp"
    cidr_blocks = ["0.0.0.0/0"]
    },
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    },
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    },
  tags {
    Name = "vpn-sg"
    environment = "${var.env}"
    }
}

resource "aws_security_group" "nat-sg" {
  name = "nat-sg"
  description = "Traffic for NAT"
  vpc_id = "${aws_vpc.default.id}"
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    },
  tags {
    Name = "nat-sg"
    environment = "${var.env}"
    }
}

resource "aws_security_group" "internet-out-sg" {
  name = "internet-out-sg"
  description = "Outbound traffic to the internet"
  vpc_id = "${aws_vpc.default.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = "tcp"
    security_groups = ["${aws_security_group.app-sg.id}"]
    },
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    },
  tags {
    Name = "internet-out-sg"
    environment = "${var.env}"
   }
}

resource "aws_security_group" "app-sg" {
  name = "app-sg"
  description = "Traffic for app tier"
  vpc_id = "${aws_vpc.default.id}"
  ingress {
    from_port = 0
    to_port = 0
    protocol = -1
    self = true
    },
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = ["${aws_security_group.vpn-sg.id}"]
    },
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = ["${aws_security_group.alb-sg.id}"]
    },
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    },
  tags {
    Name = "app-sg"
    environment = "${var.env}"
    }
}

resource "aws_security_group" "alb-sg" {
  name = "alb-sg"
  description = "Traffic for app load balancer"
  vpc_id = "${aws_vpc.default.id}"
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    },
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    },
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    },
  tags {
    Name = "alb-sg"
    environment = "${var.env}"
    }
}

resource "aws_security_group" "db-sg" {
  name = "db-sg"
  description = "Traffic for db tier"
  vpc_id = "${aws_vpc.default.id}"
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    self = true
    },
  ingress {
    from_port = 3306
    to_port = 3306
    protocol = "tcp"
    security_groups = ["${aws_security_group.app-sg.id}","${aws_security_group.vpn-sg.id}"]
    },
  egress {
    from_port = 0
    to_port = 0
    protocol = -1
    cidr_blocks = ["0.0.0.0/0"]
    },
  tags {
    Name = "db-sg"
    environment = "${var.env}"
    }
}
