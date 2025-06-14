resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "SecurityVPC" }
}
 
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
}
 
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "us-east-1b"
}
 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}
 
resource "aws_eip" "nat_eip" {
  vpc = true
}
 
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}
 
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}
 
resource "aws_route" "internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
 
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}
 
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
}
 
resource "aws_route" "nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}
 
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}
 
resource "aws_iam_role" "ssm_role" {
  name = "EC2_SSM_Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action = "sts:AssumeRole"
    }]
  })
}
 
resource "aws_iam_role_policy_attachment" "ssm_attach" {
  role       = aws_iam_role.ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}
 
resource "aws_iam_instance_profile" "ec2_profile" {
  name = "EC2SSMProfile"
  role = aws_iam_role.ssm_role.name
}
 
resource "aws_security_group" "ec2_sg" {
  name        = "wazuh-sg"
  description = "Allow internal Wazuh traffic"
  vpc_id      = aws_vpc.main_vpc.id
 
  ingress {
    from_port   = 1514
    to_port     = 1515
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
 
resource "aws_instance" "security_monitor" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = aws_subnet.private_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name
  security_groups        = [aws_security_group.ec2_sg.id]
 
  user_data              = filebase64("${path.module}/../scripts/setup.sh")
 
  tags = {
    Name = "Wazuh-Instance"
  }
}
 
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.bucket_name
}
