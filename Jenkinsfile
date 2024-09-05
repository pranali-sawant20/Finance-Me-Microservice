pipeline {
    agent any
    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/suguslove10/finance-me-microservice.git'
            }
        }
        stage('Build') {
            steps {
                sh 'mvn clean package'
            }
        }
        stage('Deploy to App Server') {
            steps {
                sshagent (credentials: ['your-ssh-key']) {
                    sh 'scp target/app.war ubuntu@${APP_SERVER_IP}:/var/lib/tomcat9/webapps/'
                }
            }
        }
        stage('Deploy to Test Server') {
            steps {
                sshagent (credentials: ['your-ssh-key']) {
                    sh 'scp target/app.war ubuntu@${TEST_SERVER_IP}:/var/lib/tomcat9/webapps/'
                }
            }
        }
        stage('Update Prometheus Config') {
            steps {
                sshagent (credentials: ['your-ssh-key']) {
                    sh '''
                    ssh ubuntu@${PROMETHEUS_SERVER_IP} << EOF
                    echo 'global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "node_exporter"
    static_configs:
      - targets: ["${APP_SERVER_IP}:9100", "${TEST_SERVER_IP}:9100"]
EOF
                    sudo systemctl restart prometheus
                    '''
                }
            }
        }
    }
}

