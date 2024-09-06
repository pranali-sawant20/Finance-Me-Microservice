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
                    env.APP_SERVER_IP = sh(script: "terraform output -raw application_server_public_ip", returnStdout: true).trim()
                    env.TEST_SERVER_IP = sh(script: "terraform output -raw testing_server_public_ip", returnStdout: true).trim()
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
                    scp -i ~/.ssh/id_ed25519 prometheus.yml ubuntu@${PROMETHEUS_SERVER_IP}:/home/ubuntu/prometheus.yml
                    ssh -i ~/.ssh/id_ed25519 ubuntu@${PROMETHEUS_SERVER_IP} "docker cp /home/ubuntu/prometheus.yml prometheus:/etc/prometheus/prometheus.yml"
                    '''
                }
            }
        }
    }
}
