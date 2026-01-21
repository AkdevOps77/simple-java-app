pipeline {
    agent none

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO   = '725018632306.dkr.ecr.us-east-1.amazonaws.com/simple-java-app'
    }

    // This is the missing piece! 
    // 'maven3' must match the "Name" you gave in Global Tool Configuration
    tools {
        maven 'maven3' 
    }

    stages {
        stage('Build') {
            agent { label 'slave' }
            steps {
                // Good for debugging: confirms where Jenkins thinks Maven is
                sh 'mvn -version' 
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave-2' }
            steps {
                // This will now work on slave-2 because tools are global
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                          mvn verify sonar:sonar \
                          -Dsonar.projectKey=simple-java-app \
                          -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }

        stage('Docker Build') {
            agent { label 'slave' }
            steps {
                sh "docker build -t ${ECR_REPO}:latest ."
            }
        }

        stage('Login to ECR') {
            agent { label 'slave' }
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                      aws ecr get-login-password --region ${AWS_REGION} | \
                      docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }

        stage('Push Image to ECR') {
            agent { label 'slave' }
            steps {
                sh "docker push ${ECR_REPO}:latest"
            }
        }
    }
}