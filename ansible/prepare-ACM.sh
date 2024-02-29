#! /bin/bash
pip3 install boto3
aws configure set aws_access_key_id $1
aws configure set aws_secret_access_key $2
/home/ec2-user/.local/bin/ansible-inventory -i inventory_aws_ec2.yml --graph
chmod 400 /home/ec2-user/.ssh/id_rsa 
/home/ec2-user/.local/bin/ansible-playbook -i inventory_aws_ec2.yml /home/ec2-user/dockercompose-playbook.yml -e "DOCKER_IMAGE=$3 DOCKER_REG_PASSWORD=$4"
rm /home/ec2-user/.ssh/id_rsa 