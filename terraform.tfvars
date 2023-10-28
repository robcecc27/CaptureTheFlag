region = "us-east-1"
## EC2 Instance Variables ---------------------
instance_type         = "t2.micro"
public_instance_count = 1
## Networking Variables ------------------------
vpc_cidr            = "10.0.0.0/16"
public_subnet_cidr  = "10.0.1.0/24"
private_subnet_cidr = "10.0.2.0/24"
