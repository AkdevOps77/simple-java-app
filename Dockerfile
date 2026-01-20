# Use OpenJDK 17 base image
FROM eclipse-temurin:17-jdk

# Set working directory inside the container
WORKDIR /app

# Copy the JAR built by Maven
COPY target/simple-java-app-1.0-SNAPSHOT.jar app.jar

# Expose port if your app needs one (optional)
# EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
