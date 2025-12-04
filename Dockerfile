# ============================
# 1. Build Stage
# ============================
FROM maven:3.8.5-openjdk-17 AS build

WORKDIR /app

# Copy only Maven wrapper and pom.xml first (to leverage caching)
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Make mvnw executable
RUN chmod +x mvnw

# Copy the rest of the project source
COPY src src

# Build the application
RUN ./mvnw -B clean package -DskipTests


# ============================
# 2. Runtime Stage
# ============================
FROM openjdk:17-jdk-slim

WORKDIR /app

# Copy the generated JAR from previous stage
COPY --from=build /app/target/*.jar app.jar

# Expose the application port
EXPOSE 8080

# Run the Spring Boot app
ENTRYPOINT ["java", "-jar", "app.jar"]
