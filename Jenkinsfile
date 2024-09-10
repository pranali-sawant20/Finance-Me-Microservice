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
                    // Capture public IP from terraform output
                    def publicIp = sh(script: 'terraform output -raw public_ip', returnStdout: true).trim()
                    env.PUBLIC_IP = publicIp
                }
            }
        }
        stage('Update Prometheus Config') {
            steps {
                script {
                    // Update the prometheus.yml file with the new public IP
                    sh """
                    sed -i 's/REPLACE_WITH_PUBLIC_IP/${env.PUBLIC_IP}/g' /opt/prometheus-2.53.2.linux-amd64/prometheus.yml
                    """
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
