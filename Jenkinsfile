stage('Build') {
            agent { label 'slave' }
            steps {
                sh 'mvn clean package -DskipTests'
                // Save the JAR file so other agents can use it
                stash name: 'build-artifacts', includes: 'target/*.jar'
            }
        }

        stage('SonarQube Analysis') {
            agent { label 'slave-2' }
            steps {
                // Bring the JAR and code to slave-2
                unstash 'build-artifacts' 
                withSonarQubeEnv('SonarQube') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh "mvn sonar:sonar -Dsonar.projectKey=simple-java-app -Dsonar.login=${SONAR_TOKEN}"
                    }
                }
            }
        }

        stage('Docker Build') {
            agent { label 'slave' }
            steps {
                unstash 'build-artifacts' // Ensure the JAR is present for the Docker COPY command
                sh "docker build -t ${ECR_REPO}:latest ."
            }
        }