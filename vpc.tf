data "aws_availability_zones" "available" {
  state = "available"
}

#vpc
resource "aws_vpc" "my_vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = var.instance_tenancy
  enable_dns_hostnames = "true"

  tags = {
    Name = "dev-vpc"
    Terraform = "true"
  }
}

#public-subnets
resource "aws_subnet" "public" {
  count= length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = element(var.public_subnet_cidr, count.index)
  map_public_ip_on_launch = "true"
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "public-${count.index+1}"
  }
}

#private-subnets

resource "aws_subnet" "private" {
  count= length(data.aws_availability_zones.available.names)
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = element(var.private_subnet_cidr, count.index)
  availability_zone= element(data.aws_availability_zones.available.names, count.index)

  tags = {
    Name = "private-${count.index+1}"
  }
}


#ig
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "gw"
  }
}
#ngw

resource "aws_eip" "eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name = "Dev-ngw"
  }

  depends_on = [
    aws_eip.eip
  ]
}


#routetables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.route_table_cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route"
  }
}
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = var.route_table_cidr
    nat_gateway_id = aws_nat_gateway.ngw.id
  }

  tags = {
    Name = "private-route"
  }
}

#associates

resource "aws_route_table_association" "public" {
  count = length(aws_subnet.public[*])
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private[*])
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}
