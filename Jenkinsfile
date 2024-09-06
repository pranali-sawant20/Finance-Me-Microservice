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
                    // Updated to match Terraform output names
                    env.PROMETHEUS_SERVER_IP = sh(script: "terraform output -raw prometheus_server_ip", returnStdout: true).trim()
                    env.APP_SERVER_IP = sh(script: "terraform output -raw app_server_public_ip", returnStdout: true).trim()
                    env.TEST_SERVER_IP = sh(script: "terraform output -raw test_server_public_ip", returnStdout: true).trim()
                }
            }
        }
        stage('Update Prometheus Config') {
            steps {
                sshagent(['my-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@${PROMETHEUS_SERVER_IP} <<EOF
                    echo 'global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["${APP_SERVER_IP}:9100", "${TEST_SERVER_IP}:9100"]
' | sudo tee /etc/prometheus/prometheus.yml
                    sudo systemctl restart prometheus
                    EOF
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
