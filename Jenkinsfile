pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        DOCKER_IMAGE_TAG      = "suguslove10/finance-me-microservice:v1"
        DOCKER_BUILDKIT       = 1 // Enable Docker BuildKit
    }
    stages {
        stage('Clone Git Repository') {
            steps {
                git 'https://github.com/suguslove10/finance-me-microservice.git'
            }
        }
        stage('Build Maven Project') {
            steps {
                retry(3) {
                    sh 'mvn clean package'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${DOCKER_IMAGE_TAG} --cache-from=${DOCKER_IMAGE_TAG} ."
                    sh 'docker images'
                }
            }
        }
        stage('Push Docker Image to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    retry(3) {
                        sh "echo $PASS | docker login -u $USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE_TAG}"
                    }
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    retry(3) {
                        sh '''
                        terraform workspace select test || terraform workspace new test
                        terraform init -input=false
                        '''
                    }
                }
            }
        }
        stage('Terraform Plan & Apply') {
            steps {
                script {
                    retry(3) {
                        sh '''
                        terraform plan -out=tfplan -input=false
                        terraform apply -auto-approve tfplan
                        terraform output -raw instance_public_ip > instance_ip.txt
                        '''
                    }
                }
            }
        }
        stage('Terraform Operations for Production Workspace') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                script {
                    retry(3) {
                        sh '''
                        terraform workspace select production || terraform workspace new production
                        terraform init -input=false

                        if terraform state show aws_key_pair.example 2>/dev/null; then
                            echo "Key pair already exists in the prod workspace"
                        else
                            terraform import aws_key_pair.example key02 || echo "Key pair already imported"
                        fi

                        terraform plan -out=tfplan -input=false
                        terraform apply -auto-approve tfplan
                        terraform output -raw instance_public_ip > instance_ip.txt
                        '''
                    }
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                script {
                    def instanceIp = readFile('instance_ip.txt').trim()
                    retry(3) {
                        sh """
                            ansible-playbook -i inventory.ini -e "prometheus_ip=${instanceIp}" ansible-playbook.yml
                        """
                    }
                }
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
            script {
                def instanceIp = readFile('instance_ip.txt').trim()
                echo "Application deployed at: http://${instanceIp}:8084"
            }
        }
        failure {
            echo 'Pipeline failed! Please check the logs.'
        }
    }
}
