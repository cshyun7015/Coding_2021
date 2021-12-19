resource "aws_vpc" "VPC" {
  cidr_block  = "10.7.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "IB07441-VPC-TCL"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "IB07441-InternetGateway-TCL"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "Subnet_DEV_Public01" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "IB07441-SubnetDEVPublic01-TCL"
  }
}
resource "aws_subnet" "Subnet_DEV_Public02" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "IB07441-SubnetDEVPublic02-TCL"
  }
}

resource "aws_route_table" "RouteTable_DEV_Public" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }

  tags = {
    Name = "IB07441-RouteTable-DEV-Public-TCL"
  }
}

resource "aws_route_table_association" "RouteTableAssociation_SubnetDEVPublic01" {
  subnet_id = aws_subnet.Subnet_DEV_Public01.id
  route_table_id = aws_route_table.RouteTable_DEV_Public.id
}
resource "aws_route_table_association" "RouteTableAssociation_SubnetDEVPublic02" {
  subnet_id = aws_subnet.Subnet_DEV_Public02.id
  route_table_id = aws_route_table.RouteTable_DEV_Public.id
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "SecurityGroup_DEV_Public" {
  name = "IB07441-SecurityGroup-DEV-Public-TCL"
  description = "Security group for DEV Public IB07441 instance"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["${chomp(data.http.local_ip.body)}/32"]
  }
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # ingress {
  #   from_port = 0
  #   to_port = 65535
  #   protocol = "tcp"
  #   cidr_blocks = [aws_vpc.VPC.cidr_block]
  # }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup-DEV-Public-TCL"
  }
}

resource "aws_security_group" "SecurityGroup_LoadBalancer" {
  name = "IB07441-SecurityGroup-LoadBalancer"
  description = "Security group for LoadBalancer"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 3000
    to_port = 3000
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup-LoadBalancer"
  }
}