pipeline{
    agent any

     environment{
        DEV_SERVER= 'ec2-user@172.31.45.200'
        IMAGE_NAME= "sagargidwani/java-mvn-privaterepos:${BUILD_NUMBER}"
        ACM_IP= 'ec2-user@172.31.11.99'
        AWS_ACCESS_KEY_ID =credentials("AWS_ACCESS_KEY_ID")
        AWS_SECRET_ACCESS_KEY=credentials("AWS_SECRET_ACCESS_KEY")
        DOCKER_REG_PASSWORD=credentials("DOCKER_REG_PASSWORD")
    }

    stages{
        stage("build the docker image and push to docker hub"){
            steps{
                script{
                    sshagent(['aws-key']){
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh "scp -r -o strictHostKeyChecking=no devserverconfig ${DEV_SERVER}:/home/ec2-user"
                        sh "ssh -o strictHostKeyChecking=no ${DEV_SERVER} 'bash ~/docker-files/docker-script.sh'"
                        sh "ssh ${DEV_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "ssh ${DEV_SERVER} sudo docker build -t ${IMAGE_NAME} /home/ec2-user/docker-files/"
                        sh "ssh ${DEV_SERVER} sudo docker push ${IMAGE_NAME}"

                    }
                    }

                }
            }
        }
        
        stage("TF create EC2"){
            steps{
                script{
                      //withCredentials([$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'yogita_aws_credentials', accessKeyVariable: 'AWS_ACCESS_KEY_ID', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']) {
                    dir("terraform"){
                        sh "terraform init"
                        sh "terraform apply -auto-approve"
                        EC2_PUBLIC_IP=sh(
                            script: "terraform output public-ip",
                            returnStdout: true
                        ).trim()
                        echo "${EC2_PUBLIC_IP}"
                    }

                }
            }
        
        }
        
        stage("RUN ansible playbook on ACM"){
            agent any
            steps{
                script{
                    sleep(time: 90, unit: "SECONDS")
                    echo "copy ansible files on ACM and run the playbook"
                    sshagent(['aws-key']) {
                    sh "scp -o StrictHostKeyChecking=no ansible/* ${ACM_IP}:/home/ec2-user"
                        //copy the ansible target key on ACM as private key file
                        withCredentials([sshUserPrivateKey(credentialsId: 'Ansible-key',keyFileVariable: 'keyfile',usernameVariable: 'user')]){ 
                          sh "scp  $keyfile ${ACM_IP}:/home/ec2-user/.ssh/id_rsa"    
                        
                    sh "ssh  ${ACM_IP} bash /home/ec2-user/prepare-ACM.sh ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} ${IMAGE_NAME} ${DOCKER_REG_PASSWORD} "
                        }
                    }
                }
            }    
        }
    }
}
