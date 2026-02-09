# Build Stage - Compilar la aplicación
FROM node:20-alpine AS builder

WORKDIR /app

# Copiar archivos de dependencias
COPY package*.json ./

# Instalar dependencias
RUN npm ci

# Copiar código fuente
COPY . .

# Construir la aplicación
RUN npm run build

# Production Stage - Servir la aplicación
FROM node:20-alpine

WORKDIR /app

# Instalar serve para servir archivos estáticos
RUN npm install -g serve

# Copiar archivos compilados desde el builder
COPY --from=builder /app/dist ./dist

# Copiar package.json
COPY package.json ./

# Exponer puerto (Vite usa 5173 por defecto, pero para producción usamos 3000)
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000', (r) => {if (r.statusCode !== 200) throw new Error(r.statusCode)})"

# Comando para servir la aplicación
CMD ["serve", "-s", "dist", "-l", "3000"]
