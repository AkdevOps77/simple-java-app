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
                echo "Building the Maven project..."
                sh 'mvn clean package -DskipTests'
            }
        }

        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    echo "Running SonarQube analysis..."
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

        stage('Docker Build') {
            steps {
                echo "Building Docker image..."
                sh 'sudo docker build -t simple-java-app:latest .'
            }
        }

        stage('Docker Run (Optional)') {
            steps {
                echo "Running Docker container (optional)..."
                sh 'sudo docker run -d --name simple-java-app-container simple-java-app:latest'
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
