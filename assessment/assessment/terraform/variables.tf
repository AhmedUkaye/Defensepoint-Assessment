variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnet_cidr" { default = "10.0.1.0/24" }
variable "private_subnet_cidr" { default = "10.0.2.0/24" }
variable "instance_type" { default = "t3.xlarge" }
variable "bucket_name" { default = "terraform-state-storage" }
