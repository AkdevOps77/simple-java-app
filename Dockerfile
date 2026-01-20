# Use OpenJDK 17 base image
FROM eclipse-temurin:17-jdk

# Set working directory
WORKDIR /app

# Copy jar from target
COPY target/java-sonarqube-maven-docker-1.0-SNAPSHOT.jar app.jar

# Run the app
ENTRYPOINT ["java","-jar","app.jar"]
