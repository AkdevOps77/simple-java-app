pipeline {
    agent none

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO  = '725018632306.dkr.ecr.us-east-1.amazonaws.com/simple-java-app'
    }

    stages {

        stage('Build') {
            agent { label 'slave' }
            steps {
                sh '''
                  echo "Running on:"
                  hostname
                  which mvn
                  mvn -version
                  mvn clean package -DskipTests
                '''
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave-2' }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                      mvn verify sonar:sonar \
                      -Dsonar.projectKey=simple-java-app \
                      -Dsonar.projectName=simple-java-app
                    '''
                }
            }
        }

        stage('Docker Build') {
            agent { label 'slave' }
            steps {
                sh '''
                  docker version
                  docker build -t $ECR_REPO:latest .
                '''
            }
        }

        stage('Login to ECR') {
            agent { label 'slave' }
            steps {
                withCredentials([[
                    $class: 'AmazonWebServicesCredentialsBinding',
                    credentialsId: 'aws-credentials'
                ]]) {
                    sh '''
                      aws --version
                      aws ecr get-login-password --region $AWS_REGION \
                      | docker login --username AWS --password-stdin 725018632306.dkr.ecr.$AWS_REGION.amazonaws.com
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
