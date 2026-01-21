pipeline {
    agent none

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO   = '725018632306.dkr.ecr.us-east-1.amazonaws.com/simple-java-app'
    }

    tools {
        maven 'maven3' 
    }

    stages {
        stage('Build') {
            agent { label 'slave' }
            steps {
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave' }
            steps {
                withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                    sh '''
                      mvn verify sonar:sonar \
                      -Dsonar.projectKey=simple-java-app \
                      -Dsonar.projectName=simple-java-app \
                      -Dsonar.host.url=http://98.94.68.197:9000 \
                      -Dsonar.login=$SONAR_TOKEN
                    '''
                }
            }
        }

        stage('Docker Build') {
            agent { label 'slave' }
            steps {
                sh 'docker build -t $ECR_REPO:latest .'
            }
        }

        stage('Login to ECR') {
            agent { label 'slave' }
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-credentials', 
                    usernameVariable: 'AWS_ACCESS_KEY_ID', 
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                      aws ecr get-login-password --region $AWS_REGION | \
                      docker login --username AWS --password-stdin $ECR_REPO
                    '''
                }
            }
        }

        stage('Push Image to ECR') {
            agent { label 'slave' }
            steps {
                sh 'docker push $ECR_REPO:latest'
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