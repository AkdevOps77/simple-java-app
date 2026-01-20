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
                    sh '''
                    mvn verify \
                    org.sonarsource.scanner.maven:sonar-maven-plugin:3.11.0.3922:sonar \
                    -Dsonar.projectKey=simple-java-app \
                    -Dsonar.projectName=simple-java-app
                    '''
                }
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t simple-java-app:latest .
                '''
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
