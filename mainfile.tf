resource "aws_vpc" "lwterra" {
  cidr_block = "10.0.0.0/16"
instance_tenancy = "default"


tags = {
Name  = "My VPC"
}
}


resource "aws_subnet" "subnetforlwterra" {
cidr_block = "10.0.1.0/24"
availability_zone = "us-east-1a"
map_public_ip_on_launch = "true"
vpc_id   = aws_vpc.lwterra.id
  tags = {
    Name = "Subnet Made in North-Virginia"
  }
}




resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.lwterra.id

  tags = {
    Name = "my gateway"
  }
}


resource "aws_route" "r" {
  route_table_id            = aws_vpc.lwterra.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
}



resource "aws_security_group" "mysecurityGroup" {
  name        = "My Security group"
  description = "Allow all inbound traffic"
  vpc_id      = aws_vpc.lwterra.id


  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "sec grp for ec2"
  }
}





resource "aws_instance" "myos" {
ami = "ami-01cc34ab2709337aa"
instance_type = "t2.micro"
subnet_id  = aws_subnet.subnetforlwterra.id
availability_zone = "us-east-1a"
key_name = "lwaws2020"
depends_on = [aws_internet_gateway.gw]
security_groups = [ "${aws_security_group.mysecurityGroup.id}" ]
tags = {
Name = "My OS"
}
}


output "dikshant_launched_myos"{
value = aws_instance.myos.availability_zone
}



resource "null_resource" "tempres"{
connection {


type = "ssh"
user = "ec2-user"
private_key = file("C:/Users/diksh/Downloads/lwaws2020.pem")
host = aws_instance.myos.public_ip
}


provisioner "remote-exec"{
inline = [
"sudo yum -y install httpd",
"sudo systemctl enable httpd",
"sudo systemctl start httpd",
]
}


}



resource "aws_ebs_volume" "dikshant_created_storage" {
 availability_zone = aws_instance.myos.availability_zone
 size = 1
 tags = {
   Name = "My storage"
 }
}



resource "aws_volume_attachment" "attach_volume" {
 device_name = "/dev/sdh"
 instance_id = aws_instance.myos.id
 volume_id  = aws_ebs_volume.dikshant_created_storage.id
}


resource "aws_ebs_snapshot" "create_snapshot" {
  volume_id = aws_ebs_volume.dikshant_created_storage.id


  tags = {
    Name = "My storage drive snapshot"
  }
}


