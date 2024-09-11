# FinanceMe Microservice with DevOps CI/CD Pipeline

## Project Overview
FinanceMe is a financial services provider. The core application code was developed by someone else, and I made some modifications, focusing on DevOps pipeline automation.

## Key Technologies
- Spring Boot
- Maven
- Docker
- Jenkins
- Ansible
- Terraform
- Prometheus
- Grafana

## API Endpoints
- **POST** `/createAccount` – Create a new account.
- **PUT** `/updateAccount/{accountNo}` – Update account details.
- **GET** `/viewPolicy/{accountNo}` – View account details.
- **DELETE** `/deletePolicy/{accountNo}` – Delete an account.

## My Contributions
- Improved the CI/CD pipeline.
- Configured infrastructure automation using Terraform.
- Set up Docker for containerization.
- Configured Prometheus and Grafana for monitoring.

## Setup Instructions

### Prerequisites
- AWS Account
- Docker & Docker Hub Account
- Jenkins installed on an AWS EC2 instance
- Maven and JDK installed

### Clone Repository
```sh
git clone git clone https://github.com/suguslove10/finance-me-microservice.git
cd finance-me-microservice 
```

### Build and Run
```sh
mvn clean package
docker build -t finance-me-microservice:v1 .
docker run -p 8081:8080 finance-me-microservice:v1
```



