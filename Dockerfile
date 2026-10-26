# ========================================================
# Etapa 1: Build (Compilación y empaquetado)
# ========================================================
FROM eclipse-temurin:25-jdk AS builder

WORKDIR /app

# Copiar archivos del wrapper de Maven y descriptor de dependencias
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Dar permisos de ejecución al wrapper de Maven
RUN chmod +x mvnw

# Descargar dependencias para aprovechar el sistema de caché de capas de Docker
RUN ./mvnw dependency:go-offline -B

# Copiar el código fuente de la aplicación
COPY src ./src

# Compilar y empaquetar el artefacto (.jar), omitiendo pruebas unitarias en el build del contenedor
RUN ./mvnw clean package -DskipTests -B

# ========================================================
# Etapa 2: Runtime (Entorno de ejecución optimizado y seguro)
# ========================================================
FROM eclipse-temurin:25-jre

WORKDIR /app

# Crear un usuario y grupo no root por seguridad (principio de privilegios mínimos)
RUN groupadd -r spring && useradd -r -g spring spring

# Copiar únicamente el archivo JAR generado desde la etapa de compilación
COPY --from=builder /app/target/*.jar app.jar

# Asignar propiedad del archivo JAR al usuario no root
RUN chown spring:spring app.jar

# Cambiar al usuario no root
USER spring:spring

# Exponer el puerto por defecto de Spring Boot
EXPOSE 8080

# Parámetros JVM optimizados para entornos de contenedores
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

# Comando de inicio de la aplicación
ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
