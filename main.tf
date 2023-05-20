provider "aws" {
  region = "us-east-1"
  profile = "default"
}

resource "aws_vpc" "ctf_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name           = "ctf-vpc"
    CaptureTheFlag = "Challenge"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = var.public_subnet_cidr
  vpc_id     = aws_vpc.ctf_vpc.id

  tags = {
    Name           = "public-subnet"
    CaptureTheFlag = "Challenge"
  }
}

resource "aws_subnet" "private_subnet" {
  cidr_block = var.private_subnet_cidr
  vpc_id     = aws_vpc.ctf_vpc.id

  tags = {
    Name           = "private-subnet"
    CaptureTheFlag = "Challenge"
  }
}

resource "aws_internet_gateway" "ctf_igw" {
  vpc_id = aws_vpc.ctf_vpc.id

  tags = {
    Name           = "ctf-igw"
    CaptureTheFlag = "Challenge"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.ctf_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ctf_igw.id
  }

  tags = {
    Name           = "public-route-table"
    CaptureTheFlag = "Challenge"
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_security_group" "public_sg" {
  name        = "ctf_public_sg"
  description = "Public security group"
  vpc_id      = aws_vpc.ctf_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "private_sg" {
  name        = "ctf_private_sg"
  description = "Private security group"
  vpc_id      = aws_vpc.ctf_vpc.id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.public_sg.id]
  }
}

resource "aws_instance" "public_instance" {
  count = var.public_instance_count

  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ctf_key_pair.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]

  associate_public_ip_address = true

  user_data = "IyEvYmluL2Jhc2gKCnl1bSB1cGRhdGUgLXkKeXVtIGluc3RhbGwgZ2NjIGh0dHBkIC15CmVjaG8gIjxodG1sPjxib2R5PjxoMT5Db25ncmF0dWxhdGlvbnMsIFlvdSBGb3VuZCB0aGUgV2VicGFnZSEgVmFsaWRhdGlvbiBDb2RlID0gVHJlZWZyb2c8L2gxPjwvYm9keT48L2h0bWw+IiA+L3Zhci93d3cvaHRtbC9pbmRleC5odG1sCnN5c3RlbWN0bCBzdGFydCBodHRwZApzeXN0ZW1jdGwgZW5hYmxlIGh0dHBkCgojIENyZWF0ZSBhIEMgZmlsZQplY2hvIC1lICcjaW5jbHVkZSA8c3RkaW8uaD5cbmludCBtYWluKCkgeyBwcmludGYoIkNvbmdyYXR1bGF0aW9ucywgWW91IEZvdW5kIHRoZSBCaW5hcnkgRmlsZSEgVmFsaWRhdGlvbiBjb2RlID0gTG9ibyIpOyByZXR1cm4gMDsgfScgPiB0ZW1wLmMKCiMgQ29tcGlsZSB0aGUgQyBmaWxlIGludG8gYSBiaW5hcnkKZ2NjIHRlbXAuYyAtbyBuZXRjb25maWcKCiMgUmVtb3ZlIHRoZSB0ZW1wb3JhcnkgQyBmaWxlCnllcyB8IHJtIHRlbXAuYwoKIyBDcmVhdGUgYSB0ZXh0IGZpbGUKZWNobyAiQ29uZ3JhdHVsYXRpb25zLCBZb3UgRm91bmQgdGhlIHRleHQgRmlsZSBGbGFnISBWYWxpZGF0aW9uIGNvZGUgPSBNaWNrIiA+IENIQU5HRUxPRwoKIyBDcmVhdGUgYSBoaWRkZW4gZmlsZQplY2hvICJDb25ncmF0dWxhdGlvbnMsIFlvdSBGb3VuZCB0aGUgYmluYXJ5IEZpbGUgRmxhZyEgVmFsaWRhdGlvbiBjb2RlID0gUnViaXgiID4gLnN5c2NvbmZpZwoKIyBHZXQgYSBsaXN0IG9mIHJvb3QgbGV2ZWwgZGlyZWN0b3JpZXMKcm9vdF9kaXJzPSgkKGxzIC8gfCBncmVwIC12RSAiKGRldnxwcm9jfHN5c3xydW58Ym9vdHxiaW58c2Jpbnx1c3J8bGlifGV0Y3xyb290KSIpKQoKIyBHZXQgYSByYW5kb20gcm9vdCBsZXZlbCBkaXJlY3RvcnkgYW5kIHN1YmRpcmVjdG9yeSBmb3IgZWFjaCBmaWxlCmZvciBmaWxlIGluIG5ldGNvbmZpZyBDSEFOR0VMT0cgLnN5c2NvbmZpZzsgZG8KICBzdWNjZXNzPTAKICB3aGlsZSBbICRzdWNjZXNzIC1lcSAwIF07IGRvCiAgICByb290X2Rpcj0ke3Jvb3RfZGlyc1skUkFORE9NICUgJHsjcm9vdF9kaXJzW0BdfV19CiAgICBzdWJfZGlycz0oJChscyAtZCAvJHJvb3RfZGlyLyovIDI+L2Rldi9udWxsKSkKICAgIGlmIFsgJHsjc3ViX2RpcnNbQF19IC1lcSAwIF07IHRoZW4KICAgICAgY29udGludWUKICAgIGZpCiAgICBzdWJfZGlyPSR7c3ViX2RpcnNbJFJBTkRPTSAlICR7I3N1Yl9kaXJzW0BdfV19CiAgICBpZiBbIC13ICRzdWJfZGlyIF07IHRoZW4KICAgICAgIyBUcnkgdG8gbW92ZSB0aGUgZmlsZSB0byB0aGUgcmFuZG9tIGRpcmVjdG9yeQogICAgICBtdiAkZmlsZSAkc3ViX2RpciAmJiBzdWNjZXNzPTEKICAgIGZpCiAgZG9uZQoKICAjIFByaW50IHRoZSBsb2NhdGlvbiBvZiB0aGUgZmlsZQogIGVjaG8gIkZpbGUgbG9jYXRpb246ICRzdWJfZGlyJGZpbGUiID4+IC92YXIvbG9nL2ZsYWdfcGxhbnRpbmcubG9nCmRvbmUK"

  tags = {
    Name = "CaptureTheFlag-Public-${count.index + 1}"
  }

  depends_on = [aws_route_table.public_route_table]
}

resource "aws_instance" "private_instance" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.ctf_key_pair.key_name
  subnet_id              = aws_subnet.private_subnet.id
  vpc_security_group_ids = [aws_security_group.private_sg.id]

  user_data = filebase64("${path.module}/mysql_setup.sh")

  depends_on = [aws_instance.public_instance]
  tags = {
    Name           = "private-instance-mysql"
    CaptureTheFlag = "Challenge"
  }
}

resource "tls_private_key" "ctf_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "ctf_key_pair" {
  key_name   = "ctf-key-pair"
  public_key = tls_private_key.ctf_key.public_key_openssh
}

resource "local_file" "ctf_key_private" {
  content  = tls_private_key.ctf_key.private_key_pem
  filename = "ctf-key-pair-private.pem"
}

resource "local_file" "ctf_key_public" {
  content  = tls_private_key.ctf_key.public_key_openssh
  filename = "ctf-key-pair-public.pem"
}