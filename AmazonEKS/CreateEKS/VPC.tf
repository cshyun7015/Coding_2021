resource "aws_vpc" "VPC" {
  cidr_block  = "10.7.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "IB07441-VPC-EKS-WorkShop"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = aws_vpc.VPC.id
  tags = {
    Name = "IB07441-InternetGateway-EKS-WorkShop"
  }
}

resource "aws_eip" "Eip_01" {
  vpc = true

  tags = {
    Name = "IB07441-Eip-01-EKS-WorkShop"
  }
}

resource "aws_nat_gateway" "Nat_Gateway_01" {
  allocation_id = aws_eip.Eip_01.id
  subnet_id     = aws_subnet.Subnet_Public_01.id

  tags = {
    Name = "IB07441-Nat-Gateway-01-EKS-WorkShop"
  }
}

resource "aws_eip" "Eip_02" {
  vpc = true

  tags = {
    Name = "IB07441-Eip-02-EKS-WorkShop"
  }
}

resource "aws_nat_gateway" "Nat_Gateway_02" {
  allocation_id = aws_eip.Eip_02.id
  subnet_id     = aws_subnet.Subnet_Public_02.id

  tags = {
    Name = "IB07441-Nat-Gateway-02-EKS-WorkShop"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "Subnet_Public_01" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.1.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "IB07441-Subnet-Public-01-EKS-WorkShop"
  }
}
resource "aws_subnet" "Subnet_Public_02" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "IB07441-Subnet-Public-02-EKS-WorkShop"
  }
}

resource "aws_subnet" "Subnet_Private_01" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.11.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "IB07441-Subnet-Private-01-EKS-WorkShop"
  }
}
resource "aws_subnet" "Subnet_Private_02" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.12.0/24"
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = {
    Name = "IB07441-Subnet-Private-02-EKS-WorkShop"
  }
}

resource "aws_route_table" "RouteTable_Public" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.InternetGateway.id
  }

  tags = {
    Name = "IB07441-RouteTable-Public-EKS-WorkShop"
  }
}

resource "aws_route_table" "RouteTable_Private_01" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_Gateway_01.id
  }

  tags = {
    Name = "IB07441-RouteTable-Private-01-EKS-WorkShop"
  }
}

resource "aws_route_table" "RouteTable_Private_02" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_Gateway_02.id
  }

  tags = {
    Name = "IB07441-RouteTable-Private-02-EKS-WorkShop"
  }
}

resource "aws_route_table_association" "RouteTableAssociation_Subnet_Public_01" {
  subnet_id = aws_subnet.Subnet_Public_01.id
  route_table_id = aws_route_table.RouteTable_Public.id
}
resource "aws_route_table_association" "RouteTableAssociation_Subnet_Public_02" {
  subnet_id = aws_subnet.Subnet_Public_02.id
  route_table_id = aws_route_table.RouteTable_Public.id
}

resource "aws_route_table_association" "RouteTableAssociation_Subnet_Private_01" {
  subnet_id = aws_subnet.Subnet_Private_01.id
  route_table_id = aws_route_table.RouteTable_Private_01.id
}
resource "aws_route_table_association" "RouteTableAssociation_Subnet_Private_02" {
  subnet_id = aws_subnet.Subnet_Private_02.id
  route_table_id = aws_route_table.RouteTable_Private_02.id
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

# resource "aws_security_group" "SecurityGroup_Public" {
#   name = "IB07441-SecurityGroup-Public-EKS-WorkShop"
#   description = "Security group for Public IB07441 instance"
#   vpc_id = aws_vpc.VPC.id

#   # ingress {
#   #   from_port = 22
#   #   to_port = 22
#   #   protocol = "tcp"
#   #   cidr_blocks = ["${chomp(data.http.local_ip.body)}/32"]
#   # }
#   ingress {
#     from_port = 3000
#     to_port = 3000
#     protocol = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "IB07441-SecurityGroup-Public-EKS-WorkShop"
#   }
# }

# resource "aws_security_group" "SecurityGroup_Private" {
#   name = "IB07441-SecurityGroup-Private-EKS-WorkShop"
#   description = "Security group for Private IB07441 instance"
#   vpc_id = aws_vpc.VPC.id

#   ingress {
#     from_port = 3000
#     to_port = 3000
#     protocol = "tcp"
#     security_groups = [aws_security_group.SecurityGroup_LoadBalancer.id]
#   }

#   egress {
#     from_port = 0
#     to_port = 0
#     protocol = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

#   tags = {
#     Name = "IB07441-SecurityGroup-Private-EKS-WorkShop"
#   }
# }