# Blue Service Dockerfile
# 從根目錄建立: docker build -t blue-service -f blue-service/Dockerfile .
FROM eclipse-temurin:17-jdk-jammy AS builder
WORKDIR /app
COPY build.gradle settings.gradle gradlew ./
COPY gradle ./gradle
COPY blue-service ./blue-service
RUN chmod +x gradlew && ./gradlew :blue-service:bootJar --no-daemon

FROM eclipse-temurin:17-jre-jammy
WORKDIR /app
COPY --from=builder /app/blue-service/build/libs/*.jar app.jar
EXPOSE 8081
ENTRYPOINT ["java", "-jar", "app.jar"]
