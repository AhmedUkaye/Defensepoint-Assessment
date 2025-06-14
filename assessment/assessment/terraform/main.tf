resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = { Name = "SecurityVPC" }
}
 
resource "aws_subnet" "public_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "ap-south-1a"
}
 
resource "aws_subnet" "private_subnet" {
  vpc_id = aws_vpc.main_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "ap-south-1b"
}
 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}
 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}
 
resource "aws_route" "default_route" {
  route_table_id = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}
 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id = aws_subnet.public_subnet.id
}
 
resource "aws_instance" "security_monitor" {
  ami = "ami-0abcdef1234567890"  # Choose appropriate AMI
  instance_type = var.instance_type
  subnet_id = aws_subnet.private_subnet.id
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
  security_groups = [aws_security_group.ec2_sg.id]
  tags = { Name = "Wazuh-Instance" }
}
 
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
}
