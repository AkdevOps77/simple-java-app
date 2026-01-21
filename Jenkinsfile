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
                // Ensure there is no 'steps' keyword outside of a 'stage'
                sh 'mvn -version'
                sh 'mvn clean package -DskipTests'
                stash name: 'app-jar', includes: 'target/*.jar'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave-2' }
            steps {
                // If you use scripted blocks inside declarative, use 'script'
                script {
                    unstash 'app-jar'
                    withSonarQubeEnv('SonarQube') {
                        withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                            sh "mvn sonar:sonar -Dsonar.projectKey=simple-java-app -Dsonar.login=${SONAR_TOKEN}"
                        }
                    }
                }
            }
        }

        stage('Docker Build & Push') {
            agent { label 'slave' }
            steps {
                unstash 'app-jar'
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', credentialsId: 'aws-credentials']]) {
                    sh """
                    docker build -t ${ECR_REPO}:latest .
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                    docker push ${ECR_REPO}:latest
                    """
                }
            }
        }
    }
}