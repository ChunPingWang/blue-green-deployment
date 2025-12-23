# Spring Cloud Gateway Dockerfile
# 從根目錄建立: docker build -t api-gateway -f spring-cloud-gateway/Dockerfile .
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
COPY spring-cloud-gateway ./spring-cloud-gateway
RUN chmod +x gradlew && ./gradlew :spring-cloud-gateway:bootJar --no-daemon

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
RUN mkdir -p /app/config
COPY --from=builder /app/spring-cloud-gateway/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
