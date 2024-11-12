# Set the working directory for the final image
WORKDIR /app

# Copy the JAR file from the build stage
COPY /jenkins-spgboot/target/*.jar app.jar

# Expose the application's port (change 8080 if your app runs on a different port)
EXPOSE 8081

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
