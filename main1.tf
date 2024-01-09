provider "aws" {
  access_key=""
  secret_key= ""
  region     = "ap-south-1"
}
resource "aws_instance" "my_ec2" {
  ami           = "ami-05c0f5389589545b7"
  instance_type = "t2.micro"
  vpc_security_group_ids=[aws_security_group.websg.id]
  key_name="tfkeypair"

tags={
 Name="web-server"
}

user_data= <<-EOF
#!/bin/bash
yum install httpd -y
service httpd start
cd /var/www/html
touch index.html
echo "hello from Terraform" > index.html
EOF
}
resource "aws_security_group" "websg" {
 name="websg"
ingress {
 from_port=var.server_port
 to_port=var.server_port
protocol="tcp"
cidr_blocks= var.publiccidr
}

ingress {
 from_port=22
 to_port=22
protocol="tcp"
cidr_blocks= ["0.0.0.0/0"]
}
egress {
 from_port=0
 to_port=0
protocol="-1"
cidr_blocks= ["0.0.0.0/0"]
}
}
resource "aws_key_pair" "tfkeypair" {
key_name = "tfkeypair"
public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
algorithm = "RSA"
rsa_bits  = 4096
}
resource "local_file" "tfkey" {
content  = tls_private_key.rsa.private_key_pem
filename = "tfkeypair"
}
