pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        ANSIBLE_SSH_KEY = credentials('ansible-ssh-key') // Add this for Ansible access
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
                sh 'docker build -t suguslove10/finance-me-microservice:v1 .'
                sh 'docker images'
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
        stage('Terraform Operations') {
            steps {
                sh '''
                terraform init
                terraform apply -auto-approve
                '''
            }
        }
        stage('Retrieve IPs and Update Inventory') {
            steps {
                script {
                    // Retrieve IPs from Terraform outputs
                    def appServerIP = sh(script: "terraform output -raw application_server_ip", returnStdout: true).trim()
                    def testServerIP = sh(script: "terraform output -raw testing_server_ip", returnStdout: true).trim()
                    def prometheusServerIP = sh(script: "terraform output -raw prometheus_server_ip", returnStdout: true).trim()
                    
                    // Create Ansible inventory file
                    writeFile file: 'inventory', text: """
[application_server]
${appServerIP}

[testing_server]
${testServerIP}

[prometheus_server]
${prometheusServerIP}
"""
                }
            }
        }
        stage('Deploy with Ansible') {
            steps {
                sshagent(['ansible-ssh-key']) {
                    sh 'ansible-playbook -i inventory ansible-playbook.yml'
                }
            }
        }
        stage('Clean Up Terraform') {
            when {
                expression { return currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                sh '''
                terraform workspace select production || terraform workspace new production
                terraform destroy -auto-approve
                terraform apply -auto-approve
                '''
            }
        }
    }
}
