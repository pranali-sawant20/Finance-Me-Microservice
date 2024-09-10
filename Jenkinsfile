pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        DOCKER_IMAGE_TAG      = "suguslove10/finance-me-microservice:v1"
    }
    stages {
        stage('Clone Git Repository') {
            steps {
                git 'https://github.com/suguslove10/finance-me-microservice.git'
            }
        }
        stage('Build Maven Project') {
            steps {
                sh 'mvn clean package'
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
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh "docker push ${DOCKER_IMAGE_TAG}"
                }
            }
        }
        stage('Terraform Init') {
            steps {
                script {
                    sh '''
                    terraform workspace select test || terraform workspace new test
                    terraform init -input=false
                    '''
                }
            }
        }
        stage('Terraform Plan & Apply') {
            steps {
                script {
                    sh '''
                    terraform plan -out=tfplan -input=false
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }
        stage('Download Prometheus') {
            steps {
                script {
                    sh '''
                    wget https://github.com/prometheus/prometheus/releases/download/v2.53.2/prometheus-2.53.2.linux-amd64.tar.gz -P /opt
                    tar -xvf /opt/prometheus-2.53.2.linux-amd64.tar.gz -C /opt
                    '''
                }
            }
        }
        stage('Update Prometheus.yml with EC2 IP') {
            steps {
                script {
                    // Get the EC2 instance IP from Terraform output
                    def ec2_ip = sh(script: "terraform output -raw instance_public_ip", returnStdout: true).trim()

                    // Replace the placeholder in the prometheus.yml file
                    sh """
                    sed -i 's/PLACEHOLDER_IP/${ec2_ip}/g' /opt/prometheus-2.53.2.linux-amd64/prometheus.yml
                    """
                }
            }
        }
        stage('Terraform Operations for Production Workspace') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                script {
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
                    '''
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                sh 'ansible-playbook -i inventory.ini ansible-playbook.yml'
            }
        }
    }
    post {
        always {
            cleanWs()
        }
        success {
            echo 'Pipeline executed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
