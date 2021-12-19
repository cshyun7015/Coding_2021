#!/bin/bash
yum upgrade -y
yum install -y aws-cli
yum install -y git
yum install -y ruby
wget https://aws-codedeploy-ap-northeast-2.s3.ap-northeast-2.amazonaws.com/latest/install
chmod +x ./install
./install auto
rm /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Seoul /etc/localtime
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
yum install -y nodejs
wget http://bit.ly/2vESNuc -O /home/ec2-user/helloworld.js
wget http://bit.ly/2vVvT18 -O /etc/init/helloworld.conf
start helloworld