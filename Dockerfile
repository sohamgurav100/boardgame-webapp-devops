# ============================
# 1. Build Stage
# ============================
FROM maven:3.8.5-openjdk-17 AS build

WORKDIR /app

# Copy Maven files first (faster builds)
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Download dependencies
RUN chmod +x mvnw && ./mvnw dependency:go-offline

# Copy all project files
COPY . .

# Build the Spring Boot app
RUN ./mvnw clean package -DskipTests


# ============================
# 2. Runtime Stage
# ============================
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the JAR file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose application port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
