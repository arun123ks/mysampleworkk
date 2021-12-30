
resource "aws_vpc" "vpcres" {
  cidr_block       = var.vpccidr
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true
  
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "publicSubnet1" {
  vpc_id     = "${aws_vpc.vpcres.id}"
  cidr_block = var.cidrpubsubnet1
  availability_zone = var.az1
  tags = {
    Name = "publicsubnet1"
  }
}


resource "aws_subnet" "publicSubnet2" {
  vpc_id     = "${aws_vpc.vpcres.id}"
  cidr_block = var.cidrpubsubnet2
  availability_zone = var.az2
  tags = {
    Name = "publicsubnet2"
  }
}

resource "aws_subnet" "PrivateSubnet1" {
  vpc_id     = "${aws_vpc.vpcres.id}"
  cidr_block = var.cidrprisubnet1
  availability_zone = var.az1
  tags = {
    Name = "Privatesubnet1"
  }
}


resource "aws_subnet" "PrivateSubnet2" {
  vpc_id     = "${aws_vpc.vpcres.id}"
  cidr_block = var.cidrprisubnet2
  availability_zone = var.az2
  tags = {
    Name = "privatesubnet2"
  }
}

resource "aws_subnet" "DBSubnet1" {
  vpc_id     = "${aws_vpc.vpcres.id}"
  cidr_block = var.cidrdbsubnet1
  availability_zone = var.az1
  tags = {
    Name = "DBsubnet1"
  }
}


resource "aws_subnet" "DBSubnet2" {
  vpc_id     = "${aws_vpc.vpcres.id}"
  cidr_block = var.cidrdbsubnet2
  availability_zone = var.az2
  tags = {
    Name = "DBSubnet2"
  }
}




resource "aws_internet_gateway" "igw" {
  vpc_id = "${aws_vpc.vpcres.id}"

  tags = {
    Name = "igw"
  }
}


resource "aws_route_table" "publicroutetable" {
  vpc_id = "${aws_vpc.vpcres.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.igw.id}"
  }


  tags = {
    Name = "publicroutetable"
  }
}

resource "aws_route_table_association" "publicsuba" {
  subnet_id      = "${aws_subnet.publicSubnet1.id}"
  route_table_id = "${aws_route_table.publicroutetable.id}"
}

resource "aws_route_table_association" "publicsubb" {
  subnet_id      = "${aws_subnet.publicSubnet2.id}"
  route_table_id = "${aws_route_table.publicroutetable.id}"
}

resource "aws_nat_gateway" "ngw1" {
  allocation_id = aws_eip.eipngw1.id
  subnet_id     = aws_subnet.publicSubnet1.id

  tags = {
    Name = "ngw1"
  }

  depends_on = [aws_internet_gateway.igw]
}




resource "aws_route_table" "privateroutetable1" {
  vpc_id = "${aws_vpc.vpcres.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw1.id}"
  }


  tags = {
    Name = "privateroutetable1"
  }
}

resource "aws_route_table_association" "privatesub1" {
  subnet_id      = "${aws_subnet.PrivateSubnet1.id}"
  route_table_id = "${aws_route_table.privateroutetable1.id}"
}


resource "aws_nat_gateway" "ngw2" {
  allocation_id = aws_eip.eipngw2.id
  subnet_id     = aws_subnet.publicSubnet2.id

  tags = {
    Name = "ngw2"
  }

  depends_on = [aws_internet_gateway.igw]
}




resource "aws_route_table" "privateroutetable2" {
  vpc_id = "${aws_vpc.vpcres.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.ngw2.id}"
  }


  tags = {
    Name = "privateroutetable2"
  }
}

resource "aws_route_table_association" "privatesub2" {
  subnet_id      = "${aws_subnet.PrivateSubnet2.id}"
  route_table_id = "${aws_route_table.privateroutetable2.id}"
}



resource "aws_route_table" "dbroutetable" {
  vpc_id = "${aws_vpc.vpcres.id}"

  tags = {
    Name = "dbroutetable"
  }
}

resource "aws_route_table_association" "dbsub1" {
  subnet_id      = "${aws_subnet.DBSubnet1.id}"
  route_table_id = "${aws_route_table.dbroutetable.id}"
}

resource "aws_route_table_association" "dbsub2" {
  subnet_id      = "${aws_subnet.DBSubnet2.id}"
  route_table_id = "${aws_route_table.dbroutetable.id}"
}


resource "aws_security_group" "mainvpcsg" {
  name        = "ssh-access"
  description = "ssh-access"
  vpc_id      = "${aws_vpc.vpcres.id}"

 
 ingress {
    description = "For ssh"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "MainVPCSG"
  }
}


resource "aws_instance" "mainvpctestpub2" {
  ami           = var.amiid
  instance_type = "t2.micro"
  key_name = var.sshkey
  subnet_id = "${aws_subnet.publicSubnet1.id}"
  vpc_security_group_ids = ["${aws_security_group.mainvpcsg.id}"]
  depends_on                = [aws_security_group.mainvpcsg]
  tags = {
    Name = "basestation"
  }
}


resource "aws_eip" "pubeip" {
  instance = "${aws_instance.mainvpctestpub2.id}"
  vpc      = true
}


resource "aws_eip" "eipngw1" {
  vpc      = true
}

resource "aws_eip" "eipngw2" {
  vpc      = true
}

