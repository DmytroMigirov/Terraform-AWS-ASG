#Create VPC 
resource "aws_vpc" "NodeJS_ASG_vpc" {
 cidr_block = var.vpc_cidr_block
 
 tags = {
   Name = "NodeJS_ASG_vpc"
 }
}

#Create Public Subnet 1
resource "aws_subnet" "pub_sub1" {
  vpc_id                  = aws_vpc.NodeJS_ASG_vpc.id
  cidr_block              = var.pub_sub1_cidr_block
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Project = "demo-app"
    Name    = "public_subnet1"

  }
}

# Create Public Subnet2

resource "aws_subnet" "pub_sub2" {
  vpc_id                  = aws_vpc.NodeJS_ASG_vpc.id
  cidr_block              = var.pub_sub2_cidr_block
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Project = "NodeJS_ASG"
    Name    = "public_subnet2"
  }
}

# Create an IG
resource "aws_internet_gateway" "NodeJS_ASG_IG" {
  vpc_id = aws_vpc.NodeJS_ASG_vpc.id
  
  tags = {
    Name = "NodeJS_ASG_IG"
  }
}

# Create a RT
resource "aws_route_table" "NodeJS_ASG_RT" {
  vpc_id = aws_vpc.NodeJS_ASG_vpc.id
  
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.NodeJS_ASG_IG.id
  }
  
  tags = {
    Name = "NodeJS_ASG_RT"
  }
}

# Create route table association of public subnet1

resource "aws_route_table_association" "public_subnet_association1" {
  route_table_id = aws_route_table.NodeJS_ASG_RT.id
  subnet_id      = aws_subnet.pub_sub1.id
}
# Create route table association of public subnet2

resource "aws_route_table_association" "public_subnet_association2" {
  route_table_id = aws_route_table.NodeJS_ASG_RT.id
  subnet_id      = aws_subnet.pub_sub2.id
}
