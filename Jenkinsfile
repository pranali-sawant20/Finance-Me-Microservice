pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages {
        stage('Build Project') {
            steps {
                git 'https://github.com/suguslove10/finance-me-microservice.git'
                sh 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    sh 'docker build -t suguslove10/finance-me-microservice:v1 .'
                    sh 'docker images'
                }
            }
        }
        stage('Push to Docker Hub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'Docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh 'docker push suguslove10/finance-me-microservice:v1'
                }
            }
        }
        stage('Terraform Operations - Test Workspace') {
            steps {
                sh '''
                terraform workspace select test || terraform workspace new test
                terraform init
                terraform plan
                terraform apply -auto-approve
                '''
            }
        }
        stage('Get IPs from Terraform') {
            steps {
                script {
                    env.PROMETHEUS_SERVER_IP = sh(script: "terraform output -raw prometheus_server_ip", returnStdout: true).trim()
                    env.APP_SERVER_IP = sh(script: "terraform output -raw app_server_public_ip", returnStdout: true).trim()
                    env.TEST_SERVER_IP = sh(script: "terraform output -raw test_server_public_ip", returnStdout: true).trim()
                }
            }
        }
        stage('Update Prometheus Config') {
            steps {
                script {
                    // Create Prometheus config file locally
                    writeFile file: 'prometheus.yml', text: """
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["${APP_SERVER_IP}:9100", "${TEST_SERVER_IP}:9100"]
"""
                }
                sshagent(['my-ssh-key']) {
                    sh '''
                    scp -o StrictHostKeyChecking=no prometheus.yml ubuntu@${PROMETHEUS_SERVER_IP}:/tmp/prometheus.yml
                    ssh -o StrictHostKeyChecking=no ubuntu@${PROMETHEUS_SERVER_IP} "sudo mv /tmp/prometheus.yml /etc/prometheus/prometheus.yml && sudo systemctl restart prometheus"
                    '''
                }
            }
        }
        stage('Terraform Operations - Production Workspace') {
            when {
                expression { return currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                sh '''
                terraform workspace select production || terraform workspace new production
                terraform init
                terraform destroy -auto-approve
                terraform apply -auto-approve
                '''
            }
        }
    }
}


pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }
    stages{
        stage('build project'){
            steps{
                git 'https://github.com/suguslove10/finance-me-microservice.git'
                sh 'mvn clean package'
              
            }
        }
        stage('Building  docker image'){
            steps{
                script{
                    sh 'docker build -t suguslove10/finance-me-microservice:v1 .'
                    sh 'docker images'
                }
            }
        }
        stage('push to docker-hub'){
            steps{
                withCredentials([usernamePassword(credentialsId: 'Docker-cred', passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    sh "echo $PASS | docker login -u $USER --password-stdin"
                    sh 'docker push suguslove10/finance-me-microservice:v1'
                }
            }
        }
        
        stage('Terraform Operations for test workspace') {
            steps {
                sh '''
                terraform workspace select test || terraform workspace new test
                terraform init
                terraform plan
                terraform destroy -auto-approve
                '''
            }
        }
       stage('Terraform destroy & apply for test workspace') {
            steps {
                sh 'terraform apply -auto-approve'
            }
       }
       stage('Terraform Operations for Production workspace') {
            when {
                expression { return currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                sh '''
                terraform workspace select prod || terraform workspace new prod
                terraform init
                if terraform state show aws_key_pair.example 2>/dev/null; then
                    echo "Key pair already exists in the prod workspace"
                else
                    terraform import aws_key_pair.example key02 || echo "Key pair already imported"
                fi
                terraform destroy -auto-approve
                terraform apply -auto-approve
                '''
            }
       }
    }
}
