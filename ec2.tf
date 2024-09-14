resource "aws_instance" "temp_vm1" {

  ami = "ami-04cdc91e49cb06165"

  instance_type = "t3.micro"
  key_name = "vibhapardeep"
 

  tags = {

    Name = "Vibha6"


  }

}





#