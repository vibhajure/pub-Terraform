resource "aws_vpc" "vibhavpc" {
 cidr_block = "10.0.0.0/16"
  tags = {
   Name = "vibhavpc"
 }
}

# Get available availability zones
data "aws_availability_zones" "available" {

  state = "available"

}

resource "aws_subnet" "public_subnet"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch= "true"
  tags = {
    Name = "public_subnet"
  }
}


resource "aws_subnet" "private_subnet"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch= "false"
  availability_zone  = data.aws_availability_zones.available.names[0]
    tags = {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "private_subnet2"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch= "false"
  availability_zone  = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "private_subnet2"
  }
}


resource "aws_internet_gateway" "my_ig"{
  vpc_id = aws_vpc.vibhavpc.id
  tags = {
    Name = "vibhavpc1gateway"
  }
}

resource "aws_route" "simulation_default_route" {
  route_table_id         = "${aws_vpc.vibhavpc.default_route_table_id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.my_ig.id}"
}

resource "aws_security_group" "my_sg1" {
  name   = "http"
  vpc_id = aws_vpc.vibhavpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "private_db_subnet_group" {
name       = "private-db-subnet-group"
description = "DB subnet group for private subnets"
subnet_ids = [aws_subnet.private_subnet.id, aws_subnet.private_subnet2.id]
tags={
name ="My DB subnet Group"
} 
}

resource "aws_db_instance" "my_rds_instance" {
db_subnet_group_name = aws_db_subnet_group.private_db_subnet_group.id
#vpc_id = "aws_vpc.vibhavpc.id"
allocated_storage    = 20
engine               = "mysql"
instance_class       = "db.t3.micro"
identifier           = "my-rds-instance"
username			 = "admin"
password 			 =  "welcome@123"
backup_retention_period = 7
vpc_security_group_ids = [aws_security_group.my_sg1.id]  
#db_subnet_group_name = aws_db_subnet_group.my_db_subnet_group.id
skip_final_snapshot= true
}

resource "aws_instance" "temp_vm1" {

  ami = "ami-04cdc91e49cb06165"
  subnet_id = aws_subnet.public_subnet.id
 # subnet_id = aws_subnet.vibha2_subnet.id
  security_groups = [aws_security_group.my_sg1.id]
  
  instance_type = "t3.micro"
  key_name = "vibhapardeep"
  
#  associate_public_ip_address = true
  tags = {
    Name = "Vibha6"
  }
 
}