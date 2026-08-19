# ==========================================
# Stage 1: Build JAR file
# ==========================================
FROM eclipse-temurin:17-jdk-alpine AS build

WORKDIR /app

# Copy toàn bộ source code và cấu hình vào container
COPY . .

# Fix lỗi ký tự xuống dòng Windows (CRLF) và cấp quyền thực thi cho gradlew
RUN sed -i 's/\r$//' gradlew && chmod +x gradlew

# Build JAR bỏ qua test, tắt daemon và giới hạn RAM để tránh tràn bộ nhớ gói Free
ENV GRADLE_OPTS="-Dorg.gradle.jvmargs=-Xmx256m -Dorg.gradle.daemon=false"
RUN ./gradlew bootJar -x test --no-daemon --stacktrace

# ==========================================
# Stage 2: Chạy ứng dụng nhẹ gọn (JRE)
# ==========================================
FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

# Copy file jar được tạo ra từ stage build
COPY --from=build /app/build/libs/*.jar app.jar

# Render tự động gán biến PORT (mặc định là 10000 hoặc theo cấu hình của bạn)
EXPOSE 8080

# Chạy ứng dụng Spring Boot
ENTRYPOINT ["java", "-jar", "app.jar"]