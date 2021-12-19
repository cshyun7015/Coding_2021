resource "aws_key_pair" "KeyPair" {
  key_name   = "IB07441_EC2_SSH_Key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCaw4lByVXTd5s+u3vs5zjWDzhPaidTyu+b6H77nI7+qplG6V3sTAVSTgV6U7wB//cZx9SgDq05OAk7U7MZZ1SJ91oUsYuibYaVc4I7BnHSY4RgE2NQjEmHuyZSBugCgG/v0pcEvarOKqxH6wp/ATHxDFd5sn8dwxUjTz5JiR74bOuDgzgBTQr8opraZL46wMyMIT5AD5vpbn3U1qNOOBJOlHvruRIRHG1Nu6DVY0GoSf2fjHZHEriNYt+utjulLfjm2uRZWNjsuMVMYeMpVeuVtVIjgrMD+UGyrfxFaIlUtvn2yndvUf6CA7MPGRKkGA9sENX5vc5M/QW/Vh/HF7EUAgdR7HdYnCClyQ2Py4ftTIhXdw799C5Z+4Gbks2bn67ORPIMTT67dBy6BT++IIHVrgup+NFf8NseNft3S3ABxD/NW4NDP+dF5fCUY7QVAPoOMVmi/ogT9zL1VDsI5BM5Yx6BxxM5opACBN8honTaCTvlPCxjN6nYqNHh1sIrenk= zogzog@SKCC20N01233"
}

variable default_key_name {
  default = "IB07441_EC2_SSH_Key"
}

data "aws_ami" "Ami" {
  owners = ["amazon"]
  most_recent = true

  filter {
   name   = "name"
   values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "block-device-mapping.volume-type"
    values = ["gp2"]
  }
}

data "aws_ec2_instance_type" "Ec2InstanceType" {
  instance_type = "t2.micro"
}

resource "aws_instance" "Instance_LbEc2Instance" {
  ami = data.aws_ami.Ami.id
  availability_zone = aws_subnet.Subnet_DEV_Public01.availability_zone
  instance_type = data.aws_ec2_instance_type.Ec2InstanceType.id
  key_name = var.default_key_name
  vpc_security_group_ids = [
    aws_security_group.SecurityGroup_LoadBalancer.id, 
    aws_security_group.SecurityGroup_SSH.id
  ]
  subnet_id = aws_subnet.Subnet_DEV_Public01.id
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
getenforce
setenforce 0
echo '\n' >> /etc/ssh/sshd_config
echo 'Port 22' >> /etc/ssh/sshd_config
curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/authorized_keys >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
chmod 700 /home/ec2-user/.ssh
chown ec2-user:ec2-user -R /home/ec2-user/.ssh
EOF

  tags = {
    Name = "IB07441-Instance-LbEc2Instance"
  }
}

resource "aws_instance" "Instance_Web1Ec2Instance" {
  ami = data.aws_ami.Ami.id
  availability_zone = aws_subnet.Subnet_DEV_Public01.availability_zone
  instance_type = data.aws_ec2_instance_type.Ec2InstanceType.id
  key_name = var.default_key_name
  vpc_security_group_ids = [
    aws_security_group.SecurityGroup_Web.id, 
    aws_security_group.SecurityGroup_SSH.id
  ]
  subnet_id = aws_subnet.Subnet_DEV_Public01.id
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
getenforce
setenforce 0
echo '\n' >> /etc/ssh/sshd_config
echo 'Port 22' >> /etc/ssh/sshd_config
curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/authorized_keys >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
chmod 700 /home/ec2-user/.ssh
chown ec2-user:ec2-user -R /home/ec2-user/.ssh
EOF

  tags = {
    Name = "IB07441-Instance-Web1Ec2Instance"
  }
}

resource "aws_instance" "Instance_Web2Ec2Instance" {
  ami = data.aws_ami.Ami.id
  availability_zone = aws_subnet.Subnet_DEV_Public01.availability_zone
  instance_type = data.aws_ec2_instance_type.Ec2InstanceType.id
  key_name = var.default_key_name
  vpc_security_group_ids = [
    aws_security_group.SecurityGroup_Web.id, 
    aws_security_group.SecurityGroup_SSH.id
  ]
  subnet_id = aws_subnet.Subnet_DEV_Public01.id
  associate_public_ip_address = true

  user_data = <<-EOF
#!/bin/bash
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
getenforce
setenforce 0
echo '\n' >> /etc/ssh/sshd_config
echo 'Port 22' >> /etc/ssh/sshd_config
curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/authorized_keys >> /home/ec2-user/.ssh/authorized_keys
chmod 600 /home/ec2-user/.ssh/authorized_keys
chmod 700 /home/ec2-user/.ssh
chown ec2-user:ec2-user -R /home/ec2-user/.ssh
EOF

  tags = {
    Name = "IB07441-Instance-Web2Ec2Instance"
  }
}

# resource "aws_instance" "Instance_KibanaEc2Instance" {
#   ami = data.aws_ami.Ami.id
#   availability_zone = aws_subnet.Subnet_DEV_Public01.availability_zone
#   instance_type = data.aws_ec2_instance_type.Ec2InstanceType.id
#   key_name = var.default_key_name
#   vpc_security_group_ids = [
#     aws_security_group.SecurityGroup_Kibana.id,
#     aws_security_group.SecurityGroup_Logstash.id, 
#     aws_security_group.SecurityGroup_SSH.id
#   ]
#   subnet_id = aws_subnet.Subnet_DEV_Public01.id
#   associate_public_ip_address = true

#   user_data = <<-EOF
# #!/bin/bash
# rm /etc/localtime
# ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
# getenforce
# setenforce 0
# echo '\n' >> /etc/ssh/sshd_config
# echo 'Port 22' >> /etc/ssh/sshd_config
# mkdir /home/ec2-user/.ssh
# curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/authorized_keys >> /home/ec2-user/.ssh/authorized_keys
# chmod 600 /home/ec2-user/.ssh/authorized_keys
# chmod 700 /home/ec2-user/.ssh
# chown ec2-user:ec2-user -R /home/ec2-user/.ssh
# shutdown -r now
# EOF

#   tags = {
#     Name = "IB07441-Instance-KibanaEc2Instance"
#   }
# }

# resource "aws_instance" "Instance_CIEc2Instance" {
#   ami = data.aws_ami.Ami.id
#   availability_zone = aws_subnet.Subnet_DEV_Public01.availability_zone
#   instance_type = data.aws_ec2_instance_type.Ec2InstanceType.id
#   key_name = var.default_key_name
#   vpc_security_group_ids = [
#     aws_security_group.SecurityGroup_Web.id,
#     aws_security_group.SecurityGroup_CI.id, 
#     aws_security_group.SecurityGroup_SSH.id
#   ]
#   subnet_id = aws_subnet.Subnet_DEV_Public01.id
#   associate_public_ip_address = true

#   user_data = <<-EOF
# #!/bin/bash
# rm /etc/localtime
# ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
# getenforce
# setenforce 0
# echo '\n' >> /etc/ssh/sshd_config
# echo 'Port 22' >> /etc/ssh/sshd_config
# yum clean all
# yum -y remove java-1.7.0-openjdk-1.7.0.261-2.6.22.1.83.amzn1.x86_64
# yum -y install epel-release wget java-1.8.0-openjdk-devel
# yum install --enablerepo=epel -y ansible git
# sed -i 's/.*host_key_checking.*/host_key_checking = False/g' /etc/ansible/ansible.cfg
# wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins.io/redhat/jenkins.repo
# rpm --import http://pkg.jenkins.io/redhat/jenkins.io.key
# yum -y install jenkins
# curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/id_rsa > /home/ec2-user/.ssh/id_rsa
# curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/authorized_keys_local >> /home/ec2-user/.ssh/authorized_keys
# chmod 400 /home/ec2-user/.ssh/id_rsa
# chown ec2-user:ec2-user -R /home/ec2-user/.ssh
# mkdir /var/lib/jenkins/.ssh
# curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/id_rsa > /var/lib/jenkins/.ssh/id_rsa
# chmod 400 /var/lib/jenkins/.ssh/id_rsa
# curl -s https://raw.githubusercontent.com/devops-book/cloudformation/master/ssh_config > /var/lib/jenkins/.ssh/config
# chmod 400 /var/lib/jenkins/.ssh/config
# chmod 700 /var/lib/jenkins/.ssh
# chown jenkins:jenkins -R /var/lib/jenkins/.ssh
# shutdown -r now
# EOF

#   tags = {
#     Name = "IB07441-Instance-CIEc2Instance"
#   }
# }

output "AmiId" {
  value = data.aws_ami.Ami.id
}
output "mylocalip" {
  value = chomp(data.http.local_ip.body)
}