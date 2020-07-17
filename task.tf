provider "aws" {
	region="ap-south-1"
}
resource "aws_vpc" "myvpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = {
    Name = "myvpc"
  }
}
resource "aws_subnet" "subnet1a" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1a"
  }
  depends_on = [
    aws_vpc.myvpc
  ]
}
resource "aws_subnet" "subnet1b" {
  vpc_id     = aws_vpc.myvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet1b"
  }
  depends_on = [         
    aws_vpc.myvpc
  ]
}
resource "aws_internet_gateway" "mygateway" {
  vpc_id = aws_vpc.myvpc.id
  tags = {
    Name = "mygateway"
  }
  depends_on = [
    aws_vpc.myvpc
  ]
}
resource "aws_route_table" "myroutetable" {
  vpc_id = aws_vpc.myvpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mygateway.id
  }
  depends_on = [
    aws_internet_gateway.mygateway
  ]

}

resource "aws_route_table_association" "subnetasso1a" {
  subnet_id      = aws_subnet.subnet1a.id
  route_table_id = aws_route_table.myroutetable.id
  depends_on = [
    aws_route_table.myroutetable
  ]
}
resource "aws_main_route_table_association" "mainsubnetasso1b" {
  vpc_id         = aws_vpc.myvpc.id
  route_table_id = aws_route_table.myroutetable.id
  depends_on = [
    aws_route_table_association.subnetasso1a
  ]
}

resource "aws_security_group" "wpsec" {
  name = "wpsec"
  vpc_id = aws_vpc.myvpc.id
  
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "wpsec"
  }
}
 
resource "aws_security_group" "mysqlsec" {
 name = "mysqlsec"
 vpc_id = aws_vpc.myvpc.id
  
  ingress {
    description = "MYSQL-rule"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks =  ["0.0.0.0/0"]
  }
  
  tags = {
    Name = "mysqlsec"
  }
}
 
resource "aws_instance" "wordpress" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.subnet1a.id
  vpc_security_group_ids = [aws_security_group.wpsec.id]
  key_name = "demokey"
  availability_zone = "ap-south-1a"
  tags = {
    Name = "wordpress"
  }
  depends_on = [
    aws_route_table_association.subnetasso1a,aws_security_group.wpsec
  ]
}

resource "aws_instance" "mysql" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id = aws_subnet.subnet1b.id
  vpc_security_group_ids = [aws_security_group.mysqlsec.id]
  key_name = "demokey"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "mysql"
  }
  depends_on = [
    aws_security_group.mysqlsec
  ]
} 


