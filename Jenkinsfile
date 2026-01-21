pipeline {
    agent any

    tools {
        maven 'maven3'
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO = '725018632306.dkr.ecr.us-east-1.amazonaws.com/simple-java-app'
    }

    stages {

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $ECR_REPO:latest .'
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                      aws ecr get-login-password --region $AWS_REGION \
                      | docker login --username AWS --password-stdin 725018632306.dkr.ecr.$AWS_REGION.amazonaws.com
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh 'docker push $ECR_REPO:latest'
            }
        }
    }
}
