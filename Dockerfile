# -------- Runtime image (small & secure) --------
FROM eclipse-temurin:17-jre

# Create app user
RUN useradd -r -u 1001 appuser

WORKDIR /app

# Copy the built jar
COPY target/simple-java-app-1.0-SNAPSHOT.jar app.jar

# Change ownership
RUN chown appuser:appuser app.jar

USER appuser

# (Optional) If app listens on a port
# EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
