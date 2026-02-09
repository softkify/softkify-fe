# Softkify Frontend - Guía Docker

## **Requisitos**

Antes de ejecutar Docker, confirma que tienes instalado:

```powershell
# Verificar Docker
docker --version

# Verificar Docker Compose
docker-compose --version

# O si usas Docker Desktop (ya viene integrado)
docker compose version
```

---

## **Desarrollo con Docker**

### **Opción 1: Usar docker-compose (RECOMENDADO)**

```powershell
# Levantar en modo desarrollo (con hot reload en puerto 5173)
docker-compose -f docker-compose.dev.yml up

# Para detener
docker-compose -f docker-compose.dev.yml down

# Reconstruir si cambiaste dependencias
docker-compose -f docker-compose.dev.yml up --build
```

### **Opción 2: Construir y correr manualmente**

```powershell
# Construir la imagen
docker build -f Dockerfile.dev -t softkify-frontend:dev .

# Correr con hot reload
docker run -v ${PWD}:/app -v /app/node_modules -p 5173:5173 -e VITE_HOST=0.0.0.0 softkify-frontend:dev npm run dev
```

---

## **Producción con Docker**

```powershell
# Opción 1: Con docker-compose
docker-compose up --build

# Opción 2: Manualmente
docker build -t softkify-frontend:prod .
docker run -p 3000:3000 softkify-frontend:prod

# Verificar que está corriendo
curl http://localhost:3000
```

---

## **Comandos útiles**

```powershell
# Ver logs en tiempo real
docker-compose logs -f softkify-frontend

# Ejecutar comando dentro del contenedor
docker-compose exec softkify-frontend npm run lint

# Ver contenedores corriendo
docker ps

# Eliminar contenedores y volúmenes
docker-compose down -v

# Reconstruir sin cachée
docker-compose build --no-cache

# Revisar tamaño de la imagen
docker images softkify-frontend
```

---

## **Conectar Frontend con Backend**

Si tu backend está en Docker en puerto 8080:

```powershell
# Linux/Mac
docker-compose up

# Windows PowerShell (reemplaza localhost con host.docker.internal)
# En archivo .env.docker o vite.config.ts:
VITE_API_URL=http://host.docker.internal:8080/api
```

---

## **Estructura de Archivos Docker**

```
softkify-fe/
├── Dockerfile              # Imagen de producción (multi-stage)
├── Dockerfile.dev          # Imagen de desarrollo
├── docker-compose.yml      # Compose para producción
├── docker-compose.dev.yml  # Compose para desarrollo
├── .dockerignore           # Archivos a ignorar
├── nginx.conf              # Configuración nginx (opcional)
└── .env.docker             # Variables de entorno
```

---

## **Troubleshooting**

**"docker: command not found"**
- Instala Docker Desktop
- Reinicia tu terminal después de instalar

**Puerto 3000/5173 en uso**
```powershell
# Cambiar puerto en docker-compose.yml
ports:
  - "3001:3000"  # Mapear a otro puerto
```

**Cambios de código no se reflejan**
- Asegúrate de usar `docker-compose.dev.yml`
- Verifica que la carpeta esté correctamente mapeada con `-v`

**Limpiar todo y empezar de cero**
```powershell
docker-compose down -v
docker system prune -a
docker-compose up --build
```

---

## **Información Técnica**

- **Base Image**: `node:20-alpine` (ligera, ~170MB solo la imagen base)
- **Build Tool**: Vite (rápido, moderno)
- **Server Producción**: `serve` (simple y efectivo)
- **Multi-stage Build**: Reduce el tamaño final de la imagen
- **Health Checks**: Incluido para monitoreo

**Tamaño aproximado de imágenes:**
- Development: ~600MB
- Production: ~400MB
