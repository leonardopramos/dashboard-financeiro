FROM eclipse-temurin:24-jdk AS builder

WORKDIR /workspace

COPY gradlew gradlew
COPY gradle gradle
COPY build.gradle settings.gradle ./
COPY src src

RUN chmod +x gradlew
RUN ./gradlew bootJar --no-daemon

FROM eclipse-temurin:24-jre

RUN mkdir /app
WORKDIR /app
COPY --from=builder /workspace/build/libs/*.jar /app/app.jar

EXPOSE 8081

CMD ["java", "-XX:MaxRAMPercentage=80.0", "-jar", "app.jar"]
