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

# resource "aws_eip" "Eip_DEV_01" {
#   vpc = true

#   tags = {
#     Name = "IB07441-Eip-DEV01-TCL"
#   }
# }

# resource "aws_nat_gateway" "Nat_Gateway_DEV_01" {
#   allocation_id = aws_eip.Eip_DEV_01.id
#   subnet_id     = aws_subnet.Subnet_DEV_Public01.id

#   tags = {
#     Name = "IB07441-Nat-Gateway-DEV01-TCL"
#   }
# }

# resource "aws_eip" "Eip_DEV_02" {
#   vpc = true

#   tags = {
#     Name = "IB07441-Eip-DEV02-TCL"
#   }
# }

# resource "aws_nat_gateway" "Nat_Gateway_DEV_02" {
#   allocation_id = aws_eip.Eip_DEV_02.id
#   subnet_id     = aws_subnet.Subnet_DEV_Public02.id

#   tags = {
#     Name = "IB07441-Nat-Gateway-DEV02-TCL"
#   }
# }

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

# resource "aws_subnet" "Subnet_DEV_Private01" {
#   vpc_id = aws_vpc.VPC.id
#   cidr_block = "10.7.11.0/24"
#   availability_zone = data.aws_availability_zones.available.names[0]
#   tags = {
#     Name = "IB07441-SubnetDEVPrivate01-TCL"
#   }
# }
# resource "aws_subnet" "Subnet_DEV_Private02" {
#   vpc_id = aws_vpc.VPC.id
#   cidr_block = "10.7.12.0/24"
#   availability_zone = data.aws_availability_zones.available.names[2]
#   tags = {
#     Name = "IB07441-SubnetDEVPrivate02-TCL"
#   }
# }

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

# resource "aws_route_table" "RouteTable_DEV_Private01" {
#   vpc_id = aws_vpc.VPC.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.Nat_Gateway_DEV_01.id
#   }

#   tags = {
#     Name = "IB07441-RouteTable-DEV-Private01-TCL"
#   }
# }

# resource "aws_route_table" "RouteTable_DEV_Private02" {
#   vpc_id = aws_vpc.VPC.id

#   route {
#     cidr_block = "0.0.0.0/0"
#     gateway_id = aws_nat_gateway.Nat_Gateway_DEV_02.id
#   }

#   tags = {
#     Name = "IB07441-RouteTable-DEV-Private02-TCL"
#   }
# }

resource "aws_route_table_association" "RouteTableAssociation_SubnetDEVPublic01" {
  subnet_id = aws_subnet.Subnet_DEV_Public01.id
  route_table_id = aws_route_table.RouteTable_DEV_Public.id
}
resource "aws_route_table_association" "RouteTableAssociation_SubnetDEVPublic02" {
  subnet_id = aws_subnet.Subnet_DEV_Public02.id
  route_table_id = aws_route_table.RouteTable_DEV_Public.id
}

# resource "aws_route_table_association" "RouteTableAssociation_SubnetDEVPrivate01" {
#   subnet_id = aws_subnet.Subnet_DEV_Private01.id
#   route_table_id = aws_route_table.RouteTable_DEV_Private01.id
# }
# resource "aws_route_table_association" "RouteTableAssociation_SubnetDEVPrivate02" {
#   subnet_id = aws_subnet.Subnet_DEV_Private02.id
#   route_table_id = aws_route_table.RouteTable_DEV_Private02.id
# }

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}

resource "aws_security_group" "SecurityGroup_Web" {
  name = "IB07441-SecurityGroup-Web"
  description = "Security group for Web"
  vpc_id = aws_vpc.VPC.id

  # ingress {
  #   from_port = 22
  #   to_port = 22
  #   protocol = "tcp"
  #   cidr_blocks = ["${chomp(data.http.local_ip.body)}/32"]
  # }
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    security_groups = [aws_security_group.SecurityGroup_LoadBalancer.id]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup-Web"
  }
}

resource "aws_security_group" "SecurityGroup_SSH" {
  name = "IB07441-SecurityGroup-SSH"
  description = "Security group for SSH"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    #cidr_blocks = ["${chomp(data.http.local_ip.body)}/32"]
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup-SSH"
  }
}

resource "aws_security_group" "SecurityGroup_SSH_Inner" {
  name = "IB07441-SecurityGroup-SSH_Inner"
  description = "Security group for SSH_Inner"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    security_groups = [aws_security_group.SecurityGroup_SSH.id]
  }

  tags = {
    Name = "IB07441-SecurityGroup-SSH_Inner"
  }
}

resource "aws_security_group" "SecurityGroup_Kibana" {
  name = "IB07441-SecurityGroup-Kibana"
  description = "Security group for Kibana"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 5601
    to_port = 5601
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup-Kibana"
  }
}

resource "aws_security_group" "SecurityGroup_Logstash" {
  name = "IB07441-SecurityGroup-Logstash"
  description = "Security group for Logstash"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 9200
    to_port = 9200
    protocol = "tcp"
    security_groups = [aws_security_group.SecurityGroup_Web.id]
  }

  tags = {
    Name = "IB07441-SecurityGroup-Logstash"
  }
}

resource "aws_security_group" "SecurityGroup_CI" {
  name = "IB07441-SecurityGroup-CI"
  description = "Security group for CI"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "IB07441-SecurityGroup-CI"
  }
}

resource "aws_security_group" "SecurityGroup_LoadBalancer" {
  name = "IB07441-SecurityGroup-LoadBalancer"
  description = "Security group for LoadBalancer"
  vpc_id = aws_vpc.VPC.id

  ingress {
    from_port = 80
    to_port = 80
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