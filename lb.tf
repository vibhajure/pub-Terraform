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


resource "aws_lb" "my_load_balancer" {  
  name               = "my-load-balancer"  
  internal           = false  
  load_balancer_type = "application"  
  security_groups    = [aws_security_group.my_sg1.id]  
  subnets = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]            

  enable_deletion_protection = false  

  tags = {  
    Name = "example-load-balancer"  
  }  
} 

resource "aws_subnet" "public_subnet1"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch= "true"
  availability_zone  = data.aws_availability_zones.available.names[0]
    tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch= "true"
  availability_zone  = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "public_subnet2"
  }
}

#created target group1
resource "aws_lb_target_group" "my_target_group1" {
  name        = "my-target-group1"
  vpc_id      = aws_vpc.vibhavpc.id
  port        = 80  # Port on which the EC2 instance is listening
  protocol    = "HTTP"
  health_check {
    timeout       = 5
    interval      = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    
  }
}


#created target group2
resource "aws_lb_target_group" "my_target_group2" {
  name        = "my-target-group2"
  vpc_id      = aws_vpc.vibhavpc.id
  port        = 80  # Port on which the EC2 instance is listening
  protocol    = "HTTP"
  health_check {
    timeout       = 5
    interval      = 10
    healthy_threshold = 2
    unhealthy_threshold = 2
    
  }
}
resource "aws_lb_target_group_attachment" "target_group_attachment1" {
  target_group_arn = aws_lb_target_group.my_target_group1.arn
  target_id       = aws_instance.machine1.id
}

resource "aws_lb_target_group_attachment" "target_group_attachment2" {
  target_group_arn = aws_lb_target_group.my_target_group2.arn
  target_id       = aws_instance.machine2.id
}



# Create Listener 1

resource "aws_lb_listener" "my_listener1" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port             = 80
  protocol			= "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group1.arn
  }
}

# Create Listener 2

resource "aws_lb_listener" "my_listener2" {
  load_balancer_arn = aws_lb.my_load_balancer.arn
  port             = 81
  protocol			= "HTTP"
   default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.my_target_group2.arn
  }
}

resource "aws_lb_listener_rule" "rule" {  
  listener_arn = aws_lb_listener.my_listener1.arn  

  priority = 100  

  condition {  
    path_pattern {
     values = ["/api"] 
  } 
  }  

    action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "This is fixed response with path pattern - Vibha"
      status_code  = "200"
    }
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

resource "aws_instance" "machine1" {
  ami = "ami-04cdc91e49cb06165"
  instance_type = "t3.micro"
  key_name = "vibhapardeep"
  subnet_id = aws_subnet.public_subnet1.id
  security_groups = [aws_security_group.my_sg1.id]
  user_data = <<-EOF
  #!/bin/bash
  echo "*** Installing apache2"
  sudo apt update -y
  sudo apt install apache2 -y
  echo "*** Completed Installing apache2"
  EOF
			  
    tags = {
  Name = "m1"
  }
}

resource "aws_instance" "machine2" {
  ami = "ami-04cdc91e49cb06165"
  instance_type = "t3.micro"
  key_name = "vibhapardeep"
  subnet_id = aws_subnet.public_subnet2.id
  security_groups = [aws_security_group.my_sg1.id]
  tags = {
  Name = "m2"
  }
  }

 
 
  








