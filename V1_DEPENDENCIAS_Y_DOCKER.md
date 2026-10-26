# Versión 1 (v1) - Creación del Proyecto, Gestión de Dependencias y Dockerización

Este documento describe detalladamente todo lo implementado desde la creación inicial del proyecto `tout-api`, incluyendo la configuración de dependencias en Maven, arquitectura base, configuración de la aplicación y la infraestructura contenerizada con Docker y Docker Compose.

---

## 📑 Tabla de Contenidos
1. [Resumen del Proyecto y Stack Tecnológico](#1-resumen-del-proyecto-y-stack-tecnológico)
2. [Estructura del Proyecto](#2-estructura-del-proyecto)
3. [Configuración de Dependencias (pom.xml)](#3-configuración-de-dependencias-pomxml)
   - [Web & REST API](#31-web--rest-api)
   - [Persistencia & JPA](#32-persistencia--jpa)
   - [Migraciones con Flyway](#33-migraciones-con-flyway)
   - [Bases de Datos & Drivers](#34-bases-de-datos--drivers)
   - [Productividad y Mapeo: Lombok y MapStruct](#35-productividad-y-mapeo-lombok-y-mapstruct)
   - [Testing](#36-testing)
   - [Plugins y Procesadores de Anotaciones](#37-plugins-y-procesadores-de-anotaciones)
4. [Configuración de la Aplicación (application.yaml)](#4-configuración-de-la-aplicación-applicationyaml)
5. [Dockerización del Proyecto](#5-dockerización-del-proyecto)
   - [Construcción Multietapa (Dockerfile)](#51-construcción-multietapa-dockerfile)
   - [Optimización de Contexto (.dockerignore)](#52-optimización-de-contexto-dockerignore)
   - [Orquestación con Docker Compose (docker-compose.yml)](#53-orquestación-con-docker-compose-docker-composeyml)
6. [Guía de Comandos y Ejemplos de Uso](#6-guía-de-comandos-y-ejemplos-de-uso)

---

## 1. Resumen del Proyecto y Stack Tecnológico

El proyecto `tout-api` es una API REST construida sobre el ecosistema Spring con Java 25.

- **Java Version:** 25 (Eclipse Temurin)
- **Framework Principal:** Spring Boot 4.1.2
- **Acceso a Datos:** Spring Data JPA / Hibernate
- **Base de Datos:** PostgreSQL 17 (en producción/Docker) y H2 (en memoria/desarrollo)
- **Control de Versiones de BD:** Flyway
- **Mapeo y Boilerplate:** MapStruct 1.6.3 + Lombok
- **Contenedores:** Docker (Multi-stage build) y Docker Compose

---

## 2. Estructura del Proyecto

```text
tout-api/
├── .dockerignore                     # Archivos excluidos del contexto de Docker
├── .mvn/                             # Wrapper de Maven
├── Dockerfile                        # Definición multi-stage de la imagen Docker
├── HELP.md                           # Documentación de ayuda generada por Spring Initializr
├── README.md                         # Guía rápida del proyecto
├── V1_DEPENDENCIAS_Y_DOCKER.md       # Este documento explicativo v1
├── docker-compose.yml                # Orquestación de servicios (PostgreSQL + API)
├── mvnw / mvnw.cmd                   # Scripts ejecutables del wrapper de Maven
├── pom.xml                           # Definición de dependencias y plugins Maven
└── src/
    ├── main/
    │   ├── java/com/edu/toutapi/
    │   │   └── ToutApiApplication.java # Clase principal de Spring Boot
    │   └── resources/
    │       └── application.yaml       # Configuración centralizada de Spring Boot
    └── test/
        └── java/com/edu/toutapi/
            └── ToutApiApplicationTests.java # Prueba de carga de contexto
```

---

## 3. Configuración de Dependencias (pom.xml)

El archivo `pom.xml` fue organizado y documentado por bloques funcionales para facilitar su mantenimiento.

### 3.1. Web & REST API
```xml
<!-- Proporciona soporte para controladores REST, serialización/deserialización JSON (Jackson) y Tomcat embebido -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc</artifactId>
</dependency>
```
* **Uso:** Expone endpoints HTTP/REST y gestiona solicitudes web.

---

### 3.2. Persistencia & JPA
```xml
<!-- Abstracción de acceso a datos con Hibernate, JPA y gestión de transacciones -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa</artifactId>
</dependency>
```
* **Uso:** Permite interactuar con la base de datos relacional mediante repositorios e interfaces JPA (`JpaRepository`).

---

### 3.3. Migraciones con Flyway
```xml
<!-- Gestión y versionamiento automático de scripts de base de datos -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-flyway</artifactId>
</dependency>
<!-- Soporte específico de Flyway para PostgreSQL -->
<dependency>
    <groupId>org.flywaydb</groupId>
    <artifactId>flyway-database-postgresql</artifactId>
</dependency>
```
* **Uso:** Aplica scripts SQL versionados (`V1__init.sql`, etc.) garantizando consistencia en las estructuras de base de datos entre diferentes entornos.

---

### 3.4. Bases de Datos & Drivers
```xml
<!-- Base de datos en memoria para desarrollo rápido y pruebas -->
<dependency>
    <groupId>com.h2database</groupId>
    <artifactId>h2</artifactId>
    <scope>runtime</scope>
</dependency>
<!-- Interfaz web para visualizar y consultar la base de datos H2 localmente -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-h2console</artifactId>
</dependency>
<!-- Driver JDBC para conexión con base de datos PostgreSQL (producción/entorno local) -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <scope>runtime</scope>
</dependency>
```

---

### 3.5. Productividad y Mapeo: Lombok y MapStruct
```xml
<!-- Reduce código repetitivo (getters, setters, constructores, builder, etc.) en tiempo de compilación -->
<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <optional>true</optional>
</dependency>
<!-- Generador de código para mapeo rápido y con seguridad de tipos entre Entidades y DTOs -->
<dependency>
    <groupId>org.mapstruct</groupId>
    <artifactId>mapstruct</artifactId>
    <version>${org.mapstruct.version}</version>
</dependency>
```

---

### 3.6. Testing
```xml
<!-- Pruebas para la capa web (MockMvc, WebMvcTest, etc.) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-webmvc-test</artifactId>
    <scope>test</scope>
</dependency>
<!-- Pruebas para la capa de datos (DataJpaTest, repositorios, etc.) -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-data-jpa-test</artifactId>
    <scope>test</scope>
</dependency>
<!-- Pruebas para verificar migraciones de Flyway -->
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-flyway-test</artifactId>
    <scope>test</scope>
</dependency>
```

---

### 3.7. Plugins y Procesadores de Anotaciones
Para que Lombok y MapStruct operen en armonía sin que los mappers fallen por falta de getters/setters, se configuró `maven-compiler-plugin` con `lombok-mapstruct-binding`:

```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-compiler-plugin</artifactId>
    <configuration>
        <compilerArgs>
            <!-- Inyección de dependencias como @Component/Spring Bean en los mappers generados -->
            <arg>-Amapstruct.defaultComponentModel=spring</arg>
            <arg>-Amapstruct.unmappedTargetPolicy=IGNORE</arg>
        </compilerArgs>
        <annotationProcessorPaths>
            <!-- 1. Binding: Coordina Lombok con MapStruct -->
            <path>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok-mapstruct-binding</artifactId>
                <version>${lombok-mapstruct-binding.version}</version>
            </path>
            <!-- 2. Procesador Lombok -->
            <path>
                <groupId>org.projectlombok</groupId>
                <artifactId>lombok</artifactId>
            </path>
            <!-- 3. Procesador MapStruct -->
            <path>
                <groupId>org.mapstruct</groupId>
                <artifactId>mapstruct-processor</artifactId>
                <version>${org.mapstruct.version}</version>
            </path>
        </annotationProcessorPaths>
    </configuration>
</plugin>
```

#### Ejemplo de uso de Lombok y MapStruct:
```java
// Entidad con Lombok
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User {
    private Long id;
    private String name;
    private String email;
}

// DTO
public record UserResponseDto(Long id, String name, String email) {}

// Mapper con MapStruct (se inyecta como @Autowired / bean de Spring)
@Mapper(componentModel = "spring")
public interface UserMapper {
    UserResponseDto toDto(User user);
    User toEntity(UserResponseDto dto);
}
```

---

## 4. Configuración de la Aplicación (application.yaml)

El archivo `application.yaml` se configuró parametrizado mediante variables de entorno para adaptarse sin cambios entre ejecución local y Docker:

```yaml
spring:
  application:
    name: tout-api

  datasource:
    # URL parametrizada: por defecto apunta a localhost, pero en Docker toma jdbc:postgresql://db:5432/tout_db
    url: ${SPRING_DATASOURCE_URL:jdbc:postgresql://localhost:5432/tout_db}
    username: ${SPRING_DATASOURCE_USERNAME:tout_user}
    password: ${SPRING_DATASOURCE_PASSWORD:tout_secret_password}
    driver-class-name: org.postgresql.Driver

  jpa:
    hibernate:
      ddl-auto: ${SPRING_JPA_HIBERNATE_DDL_AUTO:validate}
    open-in-view: false
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.PostgreSQLDialect
        format_sql: true

  flyway:
    enabled: ${SPRING_FLYWAY_ENABLED:false}
    baseline-on-migrate: true
```

---

## 5. Dockerización del Proyecto

### 5.1. Construcción Multietapa (Dockerfile)

Se implementó un patrón **Multi-stage Build** para minimizar el tamaño de la imagen final y reforzar la seguridad:

```dockerfile
# ========================================================
# Etapa 1: Build (Compilación y empaquetado)
# ========================================================
FROM eclipse-temurin:25-jdk AS builder

WORKDIR /app

# Copiar archivos necesarios para resolver dependencias
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

RUN chmod +x mvnw

# Descargar dependencias para aprovechar la caché de Docker
RUN ./mvnw dependency:go-offline -B

# Copiar código fuente
COPY src ./src

# Compilar y generar el archivo JAR
RUN ./mvnw clean package -DskipTests -B

# ========================================================
# Etapa 2: Runtime (Entorno de ejecución seguro y liviano)
# ========================================================
FROM eclipse-temurin:25-jre

WORKDIR /app

# Usuario no root para principio de privilegios mínimos
RUN groupadd -r spring && useradd -r -g spring spring

# Copiar únicamente el artefacto empaquetado
COPY --from=builder /app/target/*.jar app.jar

# Asignar permisos al usuario spring
RUN chown spring:spring app.jar
USER spring:spring

EXPOSE 8080

# Opciones de JVM para entornos contenerizados
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "exec java $JAVA_OPTS -jar app.jar"]
```

#### Ventajas clave del Dockerfile:
1. **Separación JDK / JRE:** La imagen final solo contiene el JRE (sin compiladores ni herramientas innecesarias).
2. **Caché de capas:** `dependency:go-offline` descarga librerías antes de copiar el código, evitando descargas repetitivas si el `pom.xml` no cambia.
3. **Seguridad:** Ejecución con usuario `spring:spring` (no root).
4. **Optimización de memoria:** `-XX:+UseContainerSupport` y `-XX:MaxRAMPercentage=75.0` garantizan que la JVM respete los límites del contenedor.

---

### 5.2. Optimización de Contexto (.dockerignore)

Evita enviar archivos innecesarios al motor de Docker:
- `target/`
- `.git/` / `.gitignore`
- `.idea/` / `*.iml`
- `.env` / logs

---

### 5.3. Orquestación con Docker Compose (docker-compose.yml)

Define dos servicios interconectados a través de una red bridge (`tout-network`):

```yaml
services:
  # Base de Datos PostgreSQL
  db:
    image: postgres:17-alpine
    container_name: tout-db
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME:-tout_db}
      POSTGRES_USER: ${DB_USER:-tout_user}
      POSTGRES_PASSWORD: ${DB_PASSWORD:-tout_secret_password}
    ports:
      - "${DB_PORT:-5432}:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${DB_USER:-tout_user} -d ${DB_NAME:-tout_db}"]
      interval: 10s
      timeout: 5s
      retries: 5
      start_period: 10s
    networks:
      - tout-network

  # Aplicación Spring Boot
  app:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: tout-api
    restart: unless-stopped
    depends_on:
      db:
        condition: service_healthy # Espera a que PostgreSQL esté 100% operativo
    environment:
      SPRING_DATASOURCE_URL: jdbc:postgresql://db:5432/${DB_NAME:-tout_db}
      SPRING_DATASOURCE_USERNAME: ${DB_USER:-tout_user}
      SPRING_DATASOURCE_PASSWORD: ${DB_PASSWORD:-tout_secret_password}
      SPRING_JPA_HIBERNATE_DDL_AUTO: validate
      SPRING_FLYWAY_ENABLED: "true"
      SERVER_PORT: "8080"
    ports:
      - "${APP_PORT:-8080}:8080"
    networks:
      - tout-network

volumes:
  postgres_data:
    driver: local

networks:
  tout-network:
    driver: bridge
```

#### Aspectos destacados de Compose:
- **`healthcheck` en PostgreSQL:** Verifica periódicamente `pg_isready`.
- **`condition: service_healthy`:** La API no iniciará hasta que la BD acepte conexiones activas, evitando errores de inicialización y caídas al arrancar.
- **Volumen `postgres_data`:** Garantiza la persistencia de datos tras reiniciar o detener contenedores.

---

## 6. Guía de Comandos y Ejemplos de Uso

### 6.1. Levantar el stack completo
```bash
# Construir imágenes e iniciar servicios en segundo plano
docker compose up -d --build
```

### 6.2. Monitorear logs
```bash
# Logs de todos los servicios
docker compose logs -f

# Logs específicos de la API
docker compose logs -f app

# Logs específicos de PostgreSQL
docker compose logs -f db
```

### 6.3. Verificar estado de contenedores
```bash
docker compose ps
```

### 6.4. Detener servicios
```bash
# Detener contenedores preservando datos
docker compose down

# Detener y borrar volúmenes (reiniciar base de datos limpia)
docker compose down -v
```

### 6.5. Compilación y ejecución local (sin Docker)
```bash
# Compilar proyecto y correr tests con Maven Wrapper
./mvnw clean test

# Empaquetar proyecto
./mvnw clean package

# Ejecutar aplicación localmente
./mvnw spring-boot:run
```

---
*Documento generado para registrar la versión inicial (v1) del proyecto `tout-api`.*
