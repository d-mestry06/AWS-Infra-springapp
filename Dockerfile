# ─────────────────────────────────────────────────────────────
# Stage 1 — Build
# ─────────────────────────────────────────────────────────────
FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Cache Maven deps before copying source (faster rebuilds)
COPY pom.xml .
RUN mvn dependency:go-offline -q

# Build fat JAR
COPY src ./src
RUN mvn clean package -DskipTests -q

# ─────────────────────────────────────────────────────────────
# Stage 2 — Run
# ─────────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Non-root user (security best practice)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring

COPY --from=build /app/target/*.jar app.jar

# Port 80 — matches:
#   • application.properties  (server.port=80)
#   • ALB target group        (port = 80)
#   • docker-compose mapping  (80:80)
EXPOSE 80

ENTRYPOINT ["java", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]
