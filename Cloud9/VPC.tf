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

resource "aws_eip" "Eip_03" {
  vpc = true

  tags = {
    Name = "IB07441-Eip-03-EKS-WorkShop"
  }
}

resource "aws_nat_gateway" "Nat_Gateway_03" {
  allocation_id = aws_eip.Eip_03.id
  subnet_id     = aws_subnet.Subnet_Public_03.id

  tags = {
    Name = "IB07441-Nat-Gateway-03-EKS-WorkShop"
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
resource "aws_subnet" "Subnet_Public_03" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.3.0/24"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "IB07441-Subnet-Public-03-EKS-WorkShop"
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
resource "aws_subnet" "Subnet_Private_03" {
  vpc_id = aws_vpc.VPC.id
  cidr_block = "10.7.13.0/24"
  availability_zone = data.aws_availability_zones.available.names[3]
  tags = {
    Name = "IB07441-Subnet-Private-03-EKS-WorkShop"
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

resource "aws_route_table" "RouteTable_Private_03" {
  vpc_id = aws_vpc.VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.Nat_Gateway_03.id
  }

  tags = {
    Name = "IB07441-RouteTable-Private-03-EKS-WorkShop"
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
resource "aws_route_table_association" "RouteTableAssociation_Subnet_Public_03" {
  subnet_id = aws_subnet.Subnet_Public_03.id
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
resource "aws_route_table_association" "RouteTableAssociation_Subnet_Private_03" {
  subnet_id = aws_subnet.Subnet_Private_03.id
  route_table_id = aws_route_table.RouteTable_Private_03.id
}

data "http" "local_ip" {
  url = "http://ipv4.icanhazip.com"
}