variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"
}
 
variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  default     = "10.0.1.0/24"
}
 
variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  default     = "10.0.2.0/24"
}
 
variable "instance_type" {
  description = "EC2 instance type for Wazuh"
  default     = "t3.xlarge"
}
 
variable "bucket_name" {
  description = "Globally unique name for the S3 bucket storing Terraform state"
  default     = "terraform-state-storage-unique-12345"
}
 
variable "ami_id" {
  description = "AMI ID for the EC2 instance (e.g., Amazon Linux 2)"
  default     = "ami-021a584b49225376d" # Replace with one valid for your region
}
