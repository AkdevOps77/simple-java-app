pipeline {
    agent none

    options {
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'us-east-1'
        ECR_REPO   = '725018632306.dkr.ecr.us-east-1.amazonaws.com/simple-java-app'
    }

    // Required to inject Maven path into the shell on all slaves
    tools {
        maven 'maven3' 
    }

    stages {
        stage('Checkout & Build') {
            agent { label 'slave' }
            steps {
                checkout scm
                sh 'mvn clean package -DskipTests'
                // Save the build results to share with slave-2
                stash name: 'full-workspace', includes: '**'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave-2' }
            steps {
                // Pulls the code AND the compiled 'target' folder from slave 1
                unstash 'full-workspace'
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
                // Workspace is already present on slave-1
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