# Build stage
FROM gradle:8-jdk17 AS build
WORKDIR /app
COPY .. .
RUN ./gradlew bootJar --no-daemon -x test

# Run stage
FROM eclipse-temurin:17-jre
WORKDIR /app
COPY --from=build /app/build/libs/*SNAPSHOT.jar app.jar
# Trường hợp build ra tên thường, dùng dòng sau nếu dòng trên không khớp:
# COPY --from=build /app/build/libs/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]