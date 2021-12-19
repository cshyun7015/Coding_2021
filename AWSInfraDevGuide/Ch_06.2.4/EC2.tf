data "aws_ami" "Ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
   name   = "name"
   values = ["amzn-ami-hvm-*-x86_64-gp2"]
  }
}

data "aws_ec2_instance_type" "Ec2InstanceType" {
  instance_type = "t2.micro"
}

resource "aws_key_pair" "KeyPair" {
  key_name   = "IB07441_EC2_SSH_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaw4lByVXTd5s+u3vs5zjWDzhPaidTyu+b6H77nI7+qplG6V3sTAVSTgV6U7wB//cZx9SgDq05OAk7U7MZZ1SJ91oUsYuibYaVc4I7BnHSY4RgE2NQjEmHuyZSBugCgG/v0pcEvarOKqxH6wp/ATHxDFd5sn8dwxUjTz5JiR74bOuDgzgBTQr8opraZL46wMyMIT5AD5vpbn3U1qNOOBJOlHvruRIRHG1Nu6DVY0GoSf2fjHZHEriNYt+utjulLfjm2uRZWNjsuMVMYeMpVeuVtVIjgrMD+UGyrfxFaIlUtvn2yndvUf6CA7MPGRKkGA9sENX5vc5M/QW/Vh/HF7EUAgdR7HdYnCClyQ2Py4ftTIhXdw799C5Z+4Gbks2bn67ORPIMTT67dBy6BT++IIHVrgup+NFf8NseNft3S3ABxD/NW4NDP+dF5fCUY7QVAPoOMVmi/ogT9zL1VDsI5BM5Yx6BxxM5opACBN8honTaCTvlPCxjN6nYqNHh1sIrenk= zogzog@SKCC20N01233"
}

variable default_key_name {
  default = "IB07441_EC2_SSH_Key"
}

resource "aws_launch_template" "Launch_Template" {
  name = "IB07441-Launch-Template-Code-Deploy"

  image_id = data.aws_ami.Ami.id

  instance_type = data.aws_ec2_instance_type.Ec2InstanceType.id

  key_name = var.default_key_name

  #vpc_security_group_ids = [aws_security_group.SecurityGroup_DEV_Public.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.IamInstanceProfile_EC2.name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.SecurityGroup_DEV_Public.id]
  }

  placement {
    availability_zone = aws_subnet.Subnet_DEV_Public01.availability_zone
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "IB07441-Test"
    }
  }

  user_data = filebase64("./userdata.sh")
}