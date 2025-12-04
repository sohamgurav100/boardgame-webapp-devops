# ============================
# 1. Build Stage
# ============================
FROM maven:3.8.5-openjdk-17 AS build

WORKDIR /app

# Copy only required files
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn
COPY src src

# Build Spring Boot project
RUN chmod +x mvnw && ./mvnw clean package -DskipTests


# ============================
# 2. Runtime Stage
# ============================
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy JAR file from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
