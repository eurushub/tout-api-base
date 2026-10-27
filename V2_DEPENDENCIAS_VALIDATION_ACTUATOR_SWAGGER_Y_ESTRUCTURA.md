# Versión 2 (v2) - Dependencias de Validación, Actuator, Swagger / OpenAPI y Estructura del Proyecto

Este documento describe en detalle todos los cambios agregados en la **Versión 2 (v2)** del proyecto `tout-api`. Se explican las nuevas dependencias integradas (`spring-boot-starter-validation`, `springdoc-openapi-starter-webmvc-ui`, `spring-boot-starter-actuator`), la nueva arquitectura y organización de paquetes, los ajustes en la configuración de `application.yaml` y ejemplos prácticos de código y uso.

---

## 📑 Tabla de Contenidos
1. [Resumen de Cambios v2](#1-resumen-de-cambios-v2)
2. [Nueva Estructura de Paquetes y Directorios](#2-nueva-estructura-de-paquetes-y-directorios)
   - [Paquete `common`](#21-paquete-common-componentes-transversales)
   - [Paquete `module`](#22-paquete-module-arquitectura-modular-o-por-dominio)
   - [Directorio `db/migration`](#23-directorio-dbmigration)
3. [Nuevas Dependencias (pom.xml)](#3-nuevas-dependencias-pomxml)
   - [3.1. Jakarta Bean Validation (Hibernate Validator)](#31-jakarta-bean-validation-hibernate-validator)
   - [3.2. SpringDoc OpenAPI & Swagger UI](#32-springdoc-openapi--swagger-ui)
   - [3.3. Spring Boot Actuator](#33-spring-boot-actuator)
4. [Configuración en application.yaml](#4-configuración-en-applicationyaml)
   - [Configuración de SpringDoc / Swagger](#41-configuración-de-springdoc--swagger)
   - [Configuración de Actuator (Health, Info, Metrics)](#42-configuración-de-actuator-health-info-metrics)
5. [Guía de Implementación y Ejemplos de Código](#5-guía-de-implementación-y-ejemplos-de-código)
   - [Ejemplo 1: DTO con Anotaciones de Validación](#ejemplo-1-dto-con-anotaciones-de-validación)
   - [Ejemplo 2: Controlador REST con Swagger (@Tag, @Operation) y @Valid](#ejemplo-2-controlador-rest-con-swagger-tag-operation-y-valid)
   - [Ejemplo 3: Manejo Global de Errores de Validación](#ejemplo-3-manejo-global-de-errores-de-validación)
   - [Ejemplo 4: Configuración Global de OpenAPI (@OpenAPIDefinition)](#ejemplo-4-configuración-global-de-openapi-openapidefinition)
6. [Acceso y Verificación de Endpoints](#6-acceso-y-verificación-de-endpoints)
   - [Endpoints de Swagger](#endpoints-de-swagger)
   - [Endpoints de Actuator](#endpoints-de-actuator)

---

## 1. Resumen de Cambios v2

En esta iteración se fortaleció la base del backend incorporando capacidades de:
- **Validación de Entradas:** Validación declarativa de DTOs y payloads HTTP mediante Bean Validation.
- **Documentación Interactiva:** Exposición automática y estandarizada de la API bajo la especificación OpenAPI 3 con interfaz Swagger UI.
- **Observabilidad y Monitoreo:** Métricas de rendimiento, telemetría y comprobaciones de estado de salud (*health checks*, *liveness*, *readiness*) con Spring Boot Actuator.
- **Modularización y Estructura Limpia:** Creación de la estructura de carpetas transversales (`common`) y módulos de negocio (`module`) para mantener un código escalable y desacoplado.

---

## 2. Nueva Estructura de Paquetes y Directorios

Se establecieron los siguientes paquetes base en `src/main/java/com/edu/toutapi/` y recursos:

```text
src/main/
├── java/com/edu/toutapi/
│   ├── ToutApiApplication.java       # Clase principal de Spring Boot
│   │
│   ├── common/                       # Componentes compartidos y transversales
│   │   ├── config/                   # Clases de configuración (@Configuration, Swagger, Cors, Security, etc.)
│   │   ├── dto/                      # DTOs globales (ApiResponse, ErrorResponse, PageResponse, etc.)
│   │   ├── exception/                # Manejadores de excepciones (@RestControllerAdvice) y excepciones custom
│   │   └── util/                     # Clases utilitarias, constantes y helpers
│   │
│   └── module/                       # Módulos funcionales de negocio (Package-by-Feature)
│       └── [nombre_modulo]/          # Ejemplo: user, auth, product, etc.
│           ├── controller/           # Endpoints HTTP / REST Controllers
│           ├── dto/                  # Request y Response DTOs del módulo
│           ├── mapper/               # Mapeadores MapStruct (Entity <-> DTO)
│           ├── model/                # Entidades JPA (@Entity)
│           ├── repository/           # Repositorios Spring Data JPA
│           └── service/              # Lógica de negocio (Interfaces e Implementaciones)
│
└── resources/
    ├── application.yaml              # Configuración central de la aplicación
    └── db/
        └── migration/                # Scripts SQL versionados de Flyway (V1__..., V2__...)
```

### 2.1. Paquete `common` (Componentes Transversales)
- **`common/config/`:** Aloja configuraciones de beans globales como `OpenApiConfig`, `WebMvcConfig` (CORS), seguridad, serialización Jackson, etc.
- **`common/dto/`:** Modelos de datos genéricos reutilizables en múltiples módulos (por ejemplo, estructuras estándar para respuestas HTTP exitosas o paginadas).
- **`common/exception/`:** Captura y procesamiento centralizado de errores (`GlobalExceptionHandler`), evitando duplicar bloques `try-catch` en los controladores.
- **`common/util/`:** Métodos estáticos, constantes generales, formateadores de fecha, etc.

### 2.2. Paquete `module` (Arquitectura Modular o por Dominio)
Organizado siguiendo el principio **Package by Feature**, donde cada módulo de negocio encapsula sus capas (controlador, servicio, repositorio, entidad, DTO y mapper), promoviendo alta cohesión y bajo acoplamiento.

### 2.3. Directorio `db/migration`
Ubicación estándar donde Flyway busca y ejecuta los scripts de migración SQL en orden cronológico (`V1__crear_tabla_usuarios.sql`, `V2__agregar_columnas.sql`, etc.).

---

## 3. Nuevas Dependencias (pom.xml)

En el archivo `pom.xml` se agregaron las siguientes dependencias clave:

### 3.1. Jakarta Bean Validation (Hibernate Validator)

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-validation</artifactId>
</dependency>
```

#### ¿Qué es y para qué sirve?
Implementa la especificación **Jakarta Bean Validation** usando **Hibernate Validator** como motor de referencia. Permite validar los datos de entrada de las peticiones HTTP (cuerpos JSON, parámetros de URL, headers) de forma declarativa mediante anotaciones en las clases DTO.

#### Anotaciones principales:
| Anotación | Descripción | Ejemplo de Uso |
| :--- | :--- | :--- |
| `@NotNull` | El campo no debe ser `null` (admite cadenas vacías). | `@NotNull(message = "El ID es obligatorio")` |
| `@NotEmpty` | El elemento (String, Collection, Map, Array) no es nulo y su longitud/tamaño es > 0. | `@NotEmpty(message = "La lista no puede estar vacía")` |
| `@NotBlank` | El String no es nulo, no está vacío y contiene al menos un carácter que no sea espacio en blanco. | `@NotBlank(message = "El nombre es obligatorio")` |
| `@Size(min, max)` | Valida que la longitud de un String o colección esté en el rango especificado. | `@Size(min = 3, max = 50)` |
| `@Min` / `@Max` | Valida valores numéricos mínimos o máximos permitidos. | `@Min(18) @Max(120)` |
| `@Positive` / `@PositiveOrZero` | Valida que el número sea estrictamente positivo (> 0) o positivo con cero (>= 0). | `@Positive(message = "El precio debe ser mayor a 0")` |
| `@Email` | Valida que el texto cumpla con el formato estándar de correo electrónico. | `@Email(message = "Correo electrónico inválido")` |
| `@Pattern(regexp)` | Valida que el texto coincida con una expresión regular dada. | `@Pattern(regexp = "^[0-9]{8,10}$")` |
| `@Past` / `@Future` | Valida que una fecha sea en el pasado o en el futuro. | `@Past LocalDate fechaNacimiento;` |
| `@Valid` | Indica a Spring que debe validar en cascada los objetos anidados dentro de otro DTO. | `@Valid DireccionDto direccion;` |

---

### 3.2. SpringDoc OpenAPI & Swagger UI

```xml
<properties>
    <!-- Versión compatible con Spring Boot 4.x / 3.x -->
    <springdoc.version>2.8.5</springdoc.version>
</properties>

<dependency>
    <groupId>org.springdoc</groupId>
    <artifactId>springdoc-openapi-starter-webmvc-ui</artifactId>
    <version>${springdoc.version}</version>
</dependency>
```

#### ¿Qué es y para qué sirve?
- **OpenAPI 3:** Es el estándar de la industria para describir APIs RESTful de forma independiente del lenguaje.
- **Swagger UI:** Genera una interfaz web interactiva en tiempo real donde desarrolladores, testers y consumidores de la API pueden explorar, documentar y probar directamente las peticiones HTTP (GET, POST, PUT, DELETE) con payloads reales.
- **SpringDoc:** Lee automáticamente los controladores de Spring Boot, los parámetros, los DTOs y las anotaciones de validación, construyendo el archivo OpenAPI JSON/YAML sin necesidad de escribirlo manualmente.

#### Anotaciones principales de SpringDoc / Swagger:
| Anotación | Ubicación | Descripción |
| :--- | :--- | :--- |
| `@Tag` | Controlador (`Class`) | Agrupa los endpoints bajo un módulo o sección temática con nombre y descripción. |
| `@Operation` | Método Endpoint | Describe qué hace el endpoint, su resumen (`summary`) y detalle (`description`). |
| `@ApiResponse` / `@ApiResponses` | Método Endpoint | Documenta los posibles códigos de estado HTTP (200, 201, 400, 404, 500) y esquemas retornados. |
| `@Parameter` | Parámetro de método | Documenta parámetros de ruta (`@PathVariable`), de consulta (`@RequestParam`) o de cabecera (`@RequestHeader`). |
| `@Schema` | Campo en DTO / Clase | Documenta atributos de un modelo, agregando descripción, ejemplos (`example = "juan@mail.com"`), si es obligatorio, etc. |

---

### 3.3. Spring Boot Actuator

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

#### ¿Qué es y para qué sirve?
Proporciona características de **observabilidad y monitoreo listas para producción** (*Production-Ready Features*). Permite auditar el estado interno de la aplicación en tiempo de ejecución:
- Monitoreo del estado de salud de la base de datos, Flyway, espacio en disco, memoria JVM.
- Integración nativa con Kubernetes / Docker mediante sondas de vida (*Liveness*) y preparación (*Readiness*).
- Exposición de métricas de rendimiento (peticiones HTTP por segundo, tiempos de respuesta, hilos activos, recolección de basura).

---

## 4. Configuración en application.yaml

Se añadieron los siguientes bloques de configuración en `src/main/resources/application.yaml`:

```yaml
# ====================================================================
# SPRINGDOC OPENAPI / SWAGGER CONFIGURATION
# ====================================================================
springdoc:
  api-docs:
    path: /v3/api-docs             # Ruta donde se sirve la especificación OpenAPI en formato JSON
    enabled: true                  # Habilita la generación de OpenAPI docs
  swagger-ui:
    path: /swagger-ui.html         # URL para acceder a la interfaz gráfica de Swagger
    enabled: true                  # Habilita la interfaz Swagger UI
    operations-sorter: method      # Ordena los endpoints por método HTTP (DELETE, GET, POST, PUT)
    tags-sorter: alpha             # Ordena las categorías/tags alfabéticamente
    display-request-duration: true # Muestra el tiempo de respuesta (en ms) de cada petición ejecutada
    doc-expansion: none            # Mantiene las secciones colapsadas por defecto para una vista limpia
  show-actuator: true              # Expone los endpoints de Actuator dentro de la documentación de Swagger

# ====================================================================
# SPRING BOOT ACTUATOR CONFIGURATION (HEALTH & METRICS)
# ====================================================================
management:
  endpoints:
    web:
      exposure:
        include: health,info,metrics # Endpoints expuestos públicamente vía HTTP
      base-path: /actuator           # Prefijo base para todos los endpoints de Actuator
  endpoint:
    health:
      show-details: always          # Muestra el detalle completo de salud (PostgreSQL, disco, etc.)
      probes:
        enabled: true               # Habilita sondas de Liveness (/livez) y Readiness (/readyz)
    info:
      enabled: true                 # Habilita el endpoint /actuator/info
  info:
    env:
      enabled: true                 # Permite exponer variables de entorno configuradas en info
```

---

## 5. Guía de Implementación y Ejemplos de Código

A continuación se muestran ejemplos prácticos de cómo utilizar e integrar estas nuevas herramientas en el código del proyecto.

### Ejemplo 1: DTO con Anotaciones de Validación

Ubicación sugerida: `com.edu.toutapi.module.usuario.dto.CrearUsuarioDto`

```java
package com.edu.toutapi.module.usuario.dto;

import io.swagger.v3.oas.annotations.media.Schema;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Positive;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@Schema(description = "Datos requeridos para el registro de un nuevo usuario")
public class CrearUsuarioDto {

    @NotBlank(message = "El nombre no puede estar vacío")
    @Size(min = 2, max = 50, message = "El nombre debe tener entre 2 y 50 caracteres")
    @Schema(description = "Nombre completo del usuario", example = "Carlos Pérez", requiredMode = Schema.RequiredMode.REQUIRED)
    private String nombre;

    @NotBlank(message = "El correo electrónico es obligatorio")
    @Email(message = "Debe proporcionar una dirección de correo válida")
    @Schema(description = "Correo electrónico único del usuario", example = "carlos.perez@example.com", requiredMode = Schema.RequiredMode.REQUIRED)
    private String email;

    @NotBlank(message = "La contraseña es obligatoria")
    @Size(min = 8, max = 30, message = "La contraseña debe tener entre 8 y 30 caracteres")
    @Schema(description = "Contraseña de acceso", example = "Secreto123*", requiredMode = Schema.RequiredMode.REQUIRED)
    private String password;

    @Positive(message = "La edad debe ser un número positivo")
    @Schema(description = "Edad del usuario", example = "28")
    private Integer edad;
}
```

---

### Ejemplo 2: Controlador REST con Swagger (@Tag, @Operation) y @Valid

Ubicación sugerida: `com.edu.toutapi.module.usuario.controller.UsuarioController`

```java
package com.edu.toutapi.module.usuario.controller;

import com.edu.toutapi.module.usuario.dto.CrearUsuarioDto;
import com.edu.toutapi.module.usuario.dto.UsuarioResponseDto;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/v1/usuarios")
@Tag(name = "Usuarios", description = "Operaciones y gestión de usuarios del sistema")
public class UsuarioController {

    @PostMapping
    @Operation(summary = "Crear un nuevo usuario", description = "Registra un usuario en el sistema validando sus campos obligatorios.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "201", description = "Usuario creado exitosamente"),
        @ApiResponse(responseCode = "400", description = "Datos de entrada inválidos o faltantes"),
        @ApiResponse(responseCode = "409", description = "El correo electrónico ya se encuentra registrado")
    })
    public ResponseEntity<UsuarioResponseDto> crearUsuario(
            @Valid @RequestBody CrearUsuarioDto dto) {
        
        // La anotación @Valid activa la validación automática de Hibernate Validator
        // Si hay errores, Spring lanzará una excepción MethodArgumentNotValidException
        
        UsuarioResponseDto nuevoUsuario = UsuarioResponseDto.builder()
                .id(1L)
                .nombre(dto.getNombre())
                .email(dto.getEmail())
                .build();

        return ResponseEntity.status(HttpStatus.CREATED).body(nuevoUsuario);
    }

    @GetMapping("/{id}")
    @Operation(summary = "Obtener usuario por ID", description = "Busca y retorna la información de un usuario dado su identificador único.")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Usuario encontrado"),
        @ApiResponse(responseCode = "404", description = "Usuario no encontrado")
    })
    public ResponseEntity<UsuarioResponseDto> obtenerPorId(
            @Parameter(description = "Identificador único del usuario", example = "1")
            @PathVariable Long id) {
        
        UsuarioResponseDto usuario = UsuarioResponseDto.builder()
                .id(id)
                .nombre("Carlos Pérez")
                .email("carlos.perez@example.com")
                .build();

        return ResponseEntity.ok(usuario);
    }
}
```

---

### Ejemplo 3: Manejo Global de Errores de Validación

Ubicación sugerida: `com.edu.toutapi.common.exception.GlobalExceptionHandler`

Cuando un cliente envía datos inválidos, `@Valid` genera `MethodArgumentNotValidException`. Con un manejador global retornamos un formato estructurado y amigable:

```java
package com.edu.toutapi.common.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@RestControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<Map<String, Object>> manejarErroresValidacion(MethodArgumentNotValidException ex) {
        Map<String, String> erroresCampos = new HashMap<>();
        
        for (FieldError error : ex.getBindingResult().getFieldErrors()) {
            erroresCampos.put(error.getField(), error.getDefaultMessage());
        }

        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("timestamp", LocalDateTime.now());
        respuesta.put("status", HttpStatus.BAD_REQUEST.value());
        respuesta.put("error", "Error de Validación de Campos");
        respuesta.put("detalles", erroresCampos);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST).body(respuesta);
    }
}
```

#### Respuesta de error generada en formato JSON:
```json
{
  "timestamp": "2026-10-26T23:00:00.123",
  "status": 400,
  "error": "Error de Validación de Campos",
  "detalles": {
    "nombre": "El nombre no puede estar vacío",
    "email": "Debe proporcionar una dirección de correo válida",
    "password": "La contraseña debe tener entre 8 y 30 caracteres"
  }
}
```

---

### Ejemplo 4: Configuración Global de OpenAPI (@OpenAPIDefinition)

Ubicación sugerida: `com.edu.toutapi.common.config.OpenApiConfig`

```java
package com.edu.toutapi.common.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("TOUT API - Documentación Oficial")
                        .version("v2.0.0")
                        .description("API REST para el sistema TOUT con Spring Boot, JPA, Actuator y Validación de datos.")
                        .contact(new Contact()
                                .name("Equipo de Desarrollo TOUT")
                                .email("soporte@tout.edu.pe"))
                        .license(new License()
                                .name("Apache 2.0")
                                .url("https://springdoc.org")));
    }
}
```

---

## 6. Acceso y Verificación de Endpoints

Una vez que la aplicación esté en ejecución (`./mvnw spring-boot:run` o vía Docker en `http://localhost:8080`), se pueden verificar los siguientes endpoints:

### Endpoints de Swagger
| Recurso | URL | Descripción |
| :--- | :--- | :--- |
| **Swagger UI (Interfaz Web)** | `http://localhost:8080/swagger-ui.html` | Panel interactivo para visualizar y ejecutar endpoints. |
| **OpenAPI Docs (JSON)** | `http://localhost:8080/v3/api-docs` | Especificación completa de OpenAPI en formato JSON estandarizado. |
| **OpenAPI Docs (YAML)** | `http://localhost:8080/v3/api-docs.yaml` | Especificación completa en formato YAML. |

### Endpoints de Actuator
| Recurso | URL | Descripción |
| :--- | :--- | :--- |
| **Base Actuator** | `http://localhost:8080/actuator` | Lista de hipermedios y endpoints de monitoreo disponibles. |
| **Health Check** | `http://localhost:8080/actuator/health` | Estado general de salud (`UP` / `DOWN`), PostgreSQL, espacio en disco. |
| **Liveness Probe** | `http://localhost:8080/actuator/health/liveness` | Indica si el contenedor/proceso de la app está vivo (para Kubernetes). |
| **Readiness Probe** | `http://localhost:8080/actuator/health/readiness` | Indica si la app está lista para recibir tráfico HTTP. |
| **Info** | `http://localhost:8080/actuator/info` | Información general sobre la versión y build de la aplicación. |
| **Métricas** | `http://localhost:8080/actuator/metrics` | Lista de métricas disponibles del sistema (memoria, JVM, CPU, hilos). |
| **Métrica específica** | `http://localhost:8080/actuator/metrics/jvm.memory.used` | Consulta de valor de una métrica en particular. |

#### Ejemplo de respuesta de `/actuator/health`:
```json
{
  "status": "UP",
  "components": {
    "db": {
      "status": "UP",
      "details": {
        "database": "PostgreSQL",
        "validationQuery": "isValid()"
      }
    },
    "diskSpace": {
      "status": "UP",
      "details": {
        "total": 494384795648,
        "free": 321849184256,
        "threshold": 10485760,
        "exists": true
      }
    },
    "ping": {
      "status": "UP"
    }
  },
  "groups": [
    "liveness",
    "readiness"
  ]
}
```

---

## 📌 Conclusión

Con la adición de **Validation**, **Swagger/OpenAPI**, **Actuator** y la **Estructura Modular**, el proyecto `tout-api` cuenta ahora con:
1. **Calidad de Datos:** Protección automática contra payloads inválidos antes de tocar la lógica de negocio.
2. **Documentación Viva:** Catálogo interactivo de APIs sincronizado automáticamente con el código.
3. **Observabilidad Empresarial:** Telemetría y diagnóstico para monitorización continua y despliegue en entornos como Docker y Kubernetes.
4. **Escalabilidad del Código:** Paquetes desacoplados que facilitan el trabajo colaborativo y la adición de nuevas funcionalidades.
