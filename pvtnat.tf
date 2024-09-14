resource "aws_vpc" "privatevpc" {
 cidr_block = "10.0.0.0/16"
  tags = {
   Name = "privatevpc"
 }
}



resource "aws_security_group" "my_sg1" {
  name   = "http"
  vpc_id = aws_vpc.privatevpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }	
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


resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.privatevpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
   tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id                  = aws_vpc.privatevpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = true
   tags = {
    Name = "Public Subnet 2"
  }
}

resource "aws_subnet" "private_subnet"{
  vpc_id     = aws_vpc.privatevpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch= "false"
  tags = {
    Name = "private_subnet"
  }
}

resource "aws_subnet" "private_subnet2"{
  vpc_id     = aws_vpc.privatevpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch= "false"
  tags = {
    Name = "private_subnet_2"
  }
}

resource "aws_internet_gateway" "my_ig"{
  vpc_id = aws_vpc.privatevpc.id
  tags = {
    Name = "my_ig"
  }
}

resource "aws_eip" "nat_gateway_eip" {
 domain = "vpc"
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "NAT_Gateway"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.privatevpc.id
  
  route{
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
	}
 
  tags = {
    Name = "Private Route Table"
  }
}


resource "aws_route_table_association" "private_subnet_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_route" "simulation_default_route" {
route_table_id         = "${aws_vpc.privatevpc.default_route_table_id}"
destination_cidr_block = "0.0.0.0/0"
gateway_id             = "${aws_internet_gateway.my_ig.id}"

}


resource "aws_network_interface" "first_interface" {
subnet_id = "${aws_subnet.private_subnet.id}"
security_groups = [aws_security_group.my_sg1.id]
 }

resource "aws_instance" "temp_vm1" {

  ami = "ami-04cdc91e49cb06165"
   
  instance_type = "t3.micro"
  key_name = "vibhapardeep"
  
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.first_interface.id
  }

#  associate_public_ip_address = true
  tags = {
    Name = "my_instance"
  }
 
}