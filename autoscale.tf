
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

resource "aws_subnet" "public_subnet1"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone  = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch= "true"
  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "public_subnet2"{
  vpc_id     = aws_vpc.vibhavpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone  = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch= "true"
  tags = {
    Name = "public_subnet2"
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




# Define the launch template  
resource "aws_launch_template" "my_launch_config" {  
  name          = "my-launch-configuration"  
  image_id     = "ami-08eb150f611ca277f"  # Example AMI ID  
  #security_groups = [aws_security_group.my_sg1.id]
  network_interfaces {
  security_groups = [aws_security_group.my_sg1.id]
  #associate_public_ip_address = true
  #subnet_id                   = aws_subnet.name1.id
  #delete_on_termination       = true 
}
  key_name = "vibhapardeep"
  instance_type = "t3.micro"
  lifecycle {  
  create_before_destroy = true  
  }  
  }
# Define the Auto Scaling Group  
resource "aws_autoscaling_group" "my_asg" {  
launch_template {  
    id      = aws_launch_template.my_launch_config.id  
    version = "$Latest"  
  }   
  min_size            = 1  
  max_size            = 2 
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.public_subnet1.id, aws_subnet.public_subnet2.id]  # Replace with your subnet ID  

  # Define health check type  
  health_check_type = "EC2"  
  
}  

# Optional: Define scaling policies  
resource "aws_autoscaling_policy" "scale_out" {  
  name                   = "scale-out"  
  scaling_adjustment      = 1  
  adjustment_type        = "ChangeInCapacity"  
  autoscaling_group_name = aws_autoscaling_group.my_asg.name  
}  

resource "aws_autoscaling_policy" "scale_in" {  
  name                   = "scale-in"  
  scaling_adjustment      = -1  
  adjustment_type        = "ChangeInCapacity"  
  autoscaling_group_name = aws_autoscaling_group.my_asg.name  
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {  
  alarm_name          = "cpu_high"  
  comparison_operator = "GreaterThanThreshold"  
  evaluation_periods  = "2"  
  metric_name        = "CPUUtilization"  
  namespace          = "AWS/EC2"  
  period             = "60"  
  statistic          = "Average"  
  threshold          = "10"  
  
  alarm_actions = [aws_autoscaling_policy.scale_out.arn]  
  
  dimensions = {  
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name  
  }  
}  

resource "aws_cloudwatch_metric_alarm" "cpu_low" {  
  alarm_name          = "cpu_low"  
  comparison_operator = "LessThanThreshold"  
  evaluation_periods  = "2"  
  metric_name        = "CPUUtilization"  
  namespace          = "AWS/EC2"  
  period             = "60"  
  statistic          = "Average"  
  threshold          = "10"  
  
  alarm_actions = [aws_autoscaling_policy.scale_in.arn]  
  
  dimensions = {  
    AutoScalingGroupName = aws_autoscaling_group.my_asg.name  
	}
	}
