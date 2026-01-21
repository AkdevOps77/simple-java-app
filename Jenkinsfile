pipeline {
    agent none

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        AWS_REGION = "us-east-1"
        AWS_ACCOUNT_ID = "725018632306"
        ECR_REPO = "simple-java-app"
        IMAGE_TAG = "latest"
        ECR_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}"
    }

    stages {

        stage('Checkout') {
            agent { label 'docker' }
            steps {
                git branch: 'main',
                    url: 'https://github.com/AkdevOps77/simple-java-app.git'
            }
        }

        stage('Build') {
            agent { label 'docker' }
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'sonar' }
            steps {
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                        mvn verify \
                        org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar \
                        -Dsonar.projectKey=simple-java-app \
                        -Dsonar.projectName=simple-java-app \
                        -Dsonar.login=$SONAR_TOKEN
                        '''
                    }
                }
            }
        }

        stage('Docker Build') {
            agent { label 'docker' }
            steps {
                sh '''
                docker build -t $ECR_URI:$IMAGE_TAG .
                '''
            }
        }

        stage('Login to ECR') {
            agent { label 'docker' }
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Push Image to ECR') {
            agent { label 'docker' }
            steps {
                sh '''
                docker push $ECR_URI:$IMAGE_TAG
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Image built and pushed to ECR'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}
