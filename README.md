# tout-api

API REST desarrollada con Spring Boot y PostgreSQL.

## 🚀 Despliegue con Docker y Docker Compose

### Requisitos previos
- Docker Engine
- Docker Compose

### Configuración inicial
1. Copia el archivo de variables de entorno de ejemplo:
   ```bash
   cp .env.example .env
   ```
2. (Opcional) Edita el archivo `.env` con las credenciales deseadas.

### Ejecución
Para construir y levantar los contenedores de la aplicación y la base de datos:
```bash
docker compose up -d --build
```

### Verificación
- Ver logs de los servicios:
  ```bash
  docker compose logs -f
  ```
- Comprobar estado de los contenedores:
  ```bash
  docker compose ps
  ```

### Detener los servicios
```bash
docker compose down
```
*(Para eliminar también los volúmenes de datos, agrega `-v`: `docker compose down -v`)*
