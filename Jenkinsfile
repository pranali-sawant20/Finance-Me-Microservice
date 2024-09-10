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
        stage('Terraform Plan & Apply - Test') {
            steps {
                script {
                    sh '''
                    terraform plan -out=tfplan-test -input=false
                    terraform apply -auto-approve tfplan-test
                    '''
                    // Capture public IP for test server
                    def testPublicIp = sh(script: 'terraform output -raw test_public_ip', returnStdout: true).trim()
                    env.TEST_PUBLIC_IP = testPublicIp
                }
            }
        }
        stage('Terraform Plan & Apply - Production') {
            steps {
                script {
                    sh '''
                    terraform workspace select production || terraform workspace new production
                    terraform init -input=false
                    terraform plan -out=tfplan-prod -input=false
                    terraform apply -auto-approve tfplan-prod
                    '''
                    // Capture public IP for production server
                    def prodPublicIp = sh(script: 'terraform output -raw prod_public_ip', returnStdout: true).trim()
                    env.PROD_PUBLIC_IP = prodPublicIp
                }
            }
        }
        stage('Run Ansible Playbook for Test Server') {
            steps {
                script {
                    sh """
                    ansible-playbook -i ${env.TEST_PUBLIC_IP}, ansible-playbook.yml --extra-vars "prometheus_ip=${env.TEST_PUBLIC_IP}"
                    """
                }
            }
        }
        stage('Run Ansible Playbook for Production Server') {
            steps {
                script {
                    sh """
                    ansible-playbook -i ${env.PROD_PUBLIC_IP}, ansible-playbook.yml --extra-vars "prometheus_ip=${env.PROD_PUBLIC_IP}"
                    """
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
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}
