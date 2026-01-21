# -------- Runtime image (small & secure) --------
FROM eclipse-temurin:17-jre

# Create non-root user
RUN useradd -r -u 1001 appuser

WORKDIR /app

# Copy jar (use wildcard to avoid version issues)
COPY target/*.jar app.jar

# Fix ownership
RUN chown appuser:appuser app.jar

USER appuser

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
