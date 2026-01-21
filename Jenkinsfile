pipeline {
    agent any

    tools {
        maven 'maven3'
        jdk 'jdk17'
    }

    environment {
        MAVEN_OPTS = "-Dmaven.repo.local=$WORKSPACE/.m2"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main',
                    url: 'https://github.com/AkdevOps77/simple-java-app.git'
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
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
    steps {
        sh 'sudo docker build -t simple-java-app:latest .'
    }
}
        stage('Login to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION \
                | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com
                '''
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh '''
                docker push $ECR_URI:$IMAGE_TAG
                '''
            }
        }
    }
    }

    post {
        success {
            echo '✅ Pipeline completed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}
