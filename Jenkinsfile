pipeline{
    agent any
    environment{
        DEV_SERVER = 'ec2-user@172.31.42.7'
        DEPLOY_SERVER = 'ec2-user@172.31.37.16'
        IMAGE_NAME = 'sagargidwani/java-mvn-privaterepos:php${BUILD_NUMBER}'
    }

    stages{
        stage("build the docker image and push to docker hub"){
            steps{
                script{
                    sshagent(['aws-key']){
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh "scp -r -o strictHostKeyChecking=no devserverconfig ${DEV_SERVER}:/home/ec2-user"
                        sh "ssh -o strictHostKeyChecking=no ${DEV_SERVER} 'bash ~/devserverconfig/docker-script.sh'"
                        sh "ssh ${DEV_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "ssh ${DEV_SERVER} docker build -t ${IMAGE_NAME} /home/ec2-user/devserverconfig"
                        sh "ssh ${DEV_SERVER} sudo docker push ${IMAGE_NAME}"

                    }
                    }

                }
            }
        }
        stage("run the php_db app with docker-compose"){
            steps{
                script{
                    sshagent(['aws-key']){
                        withCredentials([usernamePassword(credentialsId: 'docker-hub', passwordVariable: 'PASSWORD', usernameVariable: 'USERNAME')]) {
                        sh "scp -r -o strictHostKeyChecking=no testserverconfig ${DEPLOY_SERVER}:/home/ec2-user"
                        sh "ssh -o strictHostKeyChecking=no ${DEPLOY_SERVER} 'bash ~/testserverconfig/docker-compose-script.sh'"  
                        sh "ssh ${DEPLOY_SERVER} sudo docker login -u ${USERNAME} -p ${PASSWORD}"
                        sh "ssh ${DEPLOY_SERVER} bash /home/ec2-user/testserverconfig/docker-compose-script.sh ${IMAGE_NAME}"

                        }       
                     }
                }
            }
    
        }
    }
}
