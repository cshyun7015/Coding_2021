resource "aws_cloud9_environment_ec2" "Cloud9_Environment_Ec2" {
  instance_type = "m5.large"
  subnet_id = aws_subnet.Subnet_Public_01.id
  name          = "IB07441-Cloud9"
}