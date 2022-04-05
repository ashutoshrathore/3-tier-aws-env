data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

variable "ami_key_pair_name" {}

resource "aws_instance" "WebServer" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pubsubnet.id
    vpc_security_group_ids = aws_security_group.sshperm.id
    key_name = "${var.ami_key_pair_name}"

}


resource "aws_instance" "AppServer" {
    ami = data.aws_ami.ubuntu.id
    instance_type = "t2.micro"
    subnet_id = aws_subnet.pvtsubnet.id
    vpc_security_group_ids = aws_security_group.sshperm.id
    key_name = "${var.ami_key_pair_name}"

}

resource "aws_db_instance" "default" {
  allocated_storage    = 10
  max_allocated_storage = 50
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "mydb"
  #username             = #This needs to be stored in Hashicorp vault or AWS SSM Parameter
  #password             = #This needs to be stored in Hashicorp vault or AWS SSM Parameter
  db_subnet_group_name = aws_subnet.pvtsubnet.id
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
}