resource "aws_vpc" "vibhavpc" {
 cidr_block = "10.0.0.0/16"
  tags = {
   Name = "vibhavpc"
 }
}

resource "aws_subnet" "public_subnet"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch= "true"
  tags = {
    Name = "public_subnet"
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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_eip" "instance_eip" {
domain = "vpc"
instance= aws_instance.temp_vm1.id
}

  resource "aws_instance" "temp_vm1" {

  ami = "ami-04cdc91e49cb06165"
  subnet_id = aws_subnet.public_subnet.id
 
  security_groups = [aws_security_group.my_sg1.id]
  
  instance_type = "t3.micro"
  key_name = "vibhapardeep"
  
  #associate_public_ip_address = true
  tags = {
    Name = "public_instance"
  }
 
}