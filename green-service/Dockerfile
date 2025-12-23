# Green Service Dockerfile
# 從根目錄建立: docker build -t green-service -f green-service/Dockerfile .
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
COPY green-service ./green-service
RUN chmod +x gradlew && ./gradlew :green-service:bootJar --no-daemon

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/green-service/build/libs/*.jar app.jar
EXPOSE 8082
ENTRYPOINT ["java", "-jar", "app.jar"]
