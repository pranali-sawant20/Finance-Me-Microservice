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
                    terraform output -raw instance_public_ip > instance_ip.txt
                    '''
                }
            }
        }
        stage('Update Only When Necessary') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                script {
                    sh '''
                    terraform workspace select production || terraform workspace new production
                    terraform init -input=false

                    # Only run apply if there are changes detected
                    terraform plan -input=false -out=tfplan || echo "No changes detected"
                    if [ -f tfplan ]; then
                        terraform apply -auto-approve tfplan
                        terraform output -raw instance_public_ip > instance_ip.txt
                    fi
                    '''
                }
            }
        }
        stage('Run Ansible Playbook') {
            steps {
                script {
                    sh '''
                    export INSTANCE_IP=$(cat instance_ip.txt)
                    ansible-playbook -i inventory.ini -e "instance_ip=$INSTANCE_IP" ansible-playbook.yml
                    '''
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
