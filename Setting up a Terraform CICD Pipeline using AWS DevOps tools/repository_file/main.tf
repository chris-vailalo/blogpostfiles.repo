################################################################################
# VPC
################################################################################

#tfsec:ignore:aws-ec2-require-vpc-flow-logs-for-all-vpcs
resource "aws_vpc" "it" {
  #checkov:skip=CKV2_AWS_11: "Ensure VPC flow logging is enabled in all VPCs"
  #checkov:skip=CKV2_AWS_12: "Ensure the default security group of every VPC restricts all traffic"
  
  cidr_block = "10.0.0.0/24"
}


################################################################################
# Subnet
################################################################################

resource "aws_subnet" "it" {
  vpc_id     = aws_vpc.it.id
  cidr_block = "10.0.0.0/25"
}


################################################################################
# EC2 Instance
################################################################################

#tfsec:ignore:aws-ec2-enforce-http-token-imds
#tfsec:ignore:aws-ec2-enable-at-rest-encryption
resource "aws_instance" "it" {
  #checkov:skip=CKV_AWS_79: "Ensure Instance Metadata Service Version 1 is not enabled"
  #checkov:skip=CKV_AWS_8: "Ensure all data stored in the Launch configuration or instance Elastic Blocks Store is securely encrypted"
  #checkov:skip=CKV2_AWS_41: "Ensure an IAM role is attached to EC2 instance"
  #checkov:skip=CKV_AWS_126: "Ensure that detailed monitoring is enabled for EC2 instances"
  #checkov:skip=CKV_AWS_135: "Ensure that EC2 is EBS optimized"

  ami           = "ami-0361bbf2b99f46c1d" #Amazon Linux 2023 for ap-southeast-2
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.it.id

  tags = {
    Name = "test_to_delete"
  }
}


