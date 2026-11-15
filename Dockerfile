# Étape 1 : compilation
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN chmod +x mvnw && ./mvnw -q -B dependency:go-offline
COPY src src
RUN ./mvnw -q -B package -DskipTests

# Étape 2 : exécution (image légère, utilisateur non root)
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd -r -u 1001 maketo
COPY --from=build /app/target/*.jar app.jar
USER maketo
ENV JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:+UseSerialGC"
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
