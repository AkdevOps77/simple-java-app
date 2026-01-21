pipeline {
    agent none

    options {
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO   = '725018632306.dkr.ecr.us-east-1.amazonaws.com/simple-java-app'
    }

    stages {

        stage('Checkout') {
            agent { label 'slave' }
            steps {
                checkout scm
            }
        }

        stage('Build') {
            agent { label 'slave' }
            steps {
                sh 'which mvn'
                sh 'mvn -version'
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave-2' }
            steps {
                checkout scm
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh '''
                          mvn verify sonar:sonar \
                          -Dsonar.projectKey=simple-java-app \
                          -Dsonar.login=$SONAR_TOKEN
                        '''
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
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                  credentialsId: 'aws-credentials']]) {
                    sh '''
                      aws ecr get-login-password --region $AWS_REGION | \
                      docker login --username AWS --password-stdin ${ECR_REPO}
                    '''
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
