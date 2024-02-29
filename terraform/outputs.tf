output "public-ip"{
  value = module.myserver-ec2.ec2-ip.public_ip
}

output "private-ip"{
  value = module.myserver-ec2.ec2-ip.private_ip
}

output "ami"{
  value = module.myserver-ec2.ec2-ip.ami
}

output "subnet-id" {
  value = module.myserver-subnet.subnet.id
}