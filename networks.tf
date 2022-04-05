resource "aws_vpc" "myvpc" {
  cidr_block       = "172.20.0.0/16"
  instance_tenancy = default
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = {
    Name = "MYVPC"
  }
}

resource "aws_subnet" "pubsubnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "172.20.10.0/24"
    map_public_ip_on_launch = "true"
    tags {
        Name = "PublicSubnet"
    }
}
resource "aws_subnet" "pvtsubnet" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "172.20.20.0/24"
    tags {
        Name = "PrivateSubnet"
    }
}


resource "aws_internet_gateway" "GW" {
  vpc_id = aws_vpc.myvpc.id

  tags = {
    Name = "MYIGW"
  }
}

resource "aws_eip" "eip" {
  vpc = true
  instance = aws_instance.WebServer.id
}

resource "aws_nat_gateway" "NGate" {
  allocation_id = aws_eip.eip.id
  subnet_id = aws_subnet.pubsubnet.id
  tags = {
    "Name" = "MYNGate"
  }
}
output "nat_gateway_ip" {
  value = aws_eip.eip.public_ip
}

resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.myvpc.id
    route {
        cidr_block = "0.0.0.0/0" 
        gateway_id = aws_internet_gateway.GW.id
        nat_gateway_id = aws_nat_gateway.NGate.id 
    }
    
    tags {
        Name = "PublicrouteTable"
    }
}

resource "aws_route_table_association" "routetablepubsubnet"{
    subnet_id = aws_subnet.pubsubnet.id
    route_table_id = aws_route_table.publicrt.id
}

resource "aws_security_group" "sshperm" {
name = "sshperm"
vpc_id = aws_vpc.myvpc.id
ingress {
    cidr_blocks = [
      "0.0.0.0/0"
    ]
from_port = 2222
    to_port = 2222
    protocol = "tcp"
  }
  egress {
   from_port = 0
   to_port = 0
   protocol = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}



