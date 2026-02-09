# Script para manejar Docker en Windows más fácilmente
# Uso: .\docker-helper.ps1 dev   (para desarrollo)
#      .\docker-helper.ps1 prod  (para producción)

param(
    [string]$command = "help"
)

function Show-Help {
    Write-Host "`n╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║       SOFTKIFY FRONTEND - DOCKER HELPER                    ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`nUsos disponibles:`n" -ForegroundColor Yellow
    Write-Host "  .\docker-helper.ps1 dev          Ejecutar en DESARROLLO (con hot reload)"
    Write-Host "  .\docker-helper.ps1 prod         Ejecutar en PRODUCCIÓN"
    Write-Host "  .\docker-helper.ps1 build        Construir imágenes"
    Write-Host "  .\docker-helper.ps1 stop         Detener contenedores"
    Write-Host "  .\docker-helper.ps1 logs         Ver logs en tiempo real"
    Write-Host "  .\docker-helper.ps1 clean        Limpiar todo (contenedores, volúmenes, imágenes)"
    Write-Host "  .\docker-helper.ps1 check        Verificar instalación de Docker`n"
}

function Check-Docker {
    Write-Host "`n[CHECK] Verificando Docker..." -ForegroundColor Cyan
    
    try {
        $dockerVersion = docker --version
        Write-Host "✓ Docker: $dockerVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Docker NO está instalado o no está en PATH" -ForegroundColor Red
        Write-Host "  Descargalo en: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
        exit 1
    }

    try {
        $composeVersion = docker-compose --version
        Write-Host "✓ Docker Compose: $composeVersion" -ForegroundColor Green
    } catch {
        Write-Host "⚠ Docker Compose NO encontrado (pero puedes usar 'docker compose')" -ForegroundColor Yellow
    }
}

function Dev {
    Write-Host "`n[DEV] Levantando en DESARROLLO con hot reload..." -ForegroundColor Green
    Check-Docker
    docker-compose -f docker-compose.dev.yml up
}

function Prod {
    Write-Host "`n[PROD] Levantando en PRODUCCIÓN..." -ForegroundColor Green
    Check-Docker
    docker-compose -f docker-compose.yml up --build
}

function Build {
    Write-Host "`n[BUILD] Construyendo imágenes..." -ForegroundColor Cyan
    Check-Docker
    Write-Host "`nBuilding development image..." -ForegroundColor Yellow
    docker build -f Dockerfile.dev -t softkify-frontend:dev .
    Write-Host "`nBuilding production image..." -ForegroundColor Yellow
    docker build -f Dockerfile -t softkify-frontend:prod .
    Write-Host "`n✓ Imágenes construidas exitosamente" -ForegroundColor Green
}

function Stop {
    Write-Host "`n[STOP] Deteniendo contenedores..." -ForegroundColor Yellow
    docker-compose -f docker-compose.dev.yml down 2>/dev/null
    docker-compose -f docker-compose.yml down 2>/dev/null
    Write-Host "✓ Contenedores detenidos" -ForegroundColor Green
}

function Logs {
    Write-Host "`n[LOGS] Mostrando logs en tiempo real..." -ForegroundColor Cyan
    docker-compose logs -f
}

function Clean {
    Write-Host "`n[CLEAN] ⚠ Esto eliminará contenedores, volúmenes e imágenes..." -ForegroundColor Red
    $response = Read-Host "¿Estás seguro? (s/n)"
    
    if ($response -eq "s") {
        Write-Host "Deteniendo contenedores..." -ForegroundColor Yellow
        docker-compose down -v 2>/dev/null
        
        Write-Host "Eliminando imágenes..." -ForegroundColor Yellow
        docker rmi softkify-frontend:dev 2>/dev/null
        docker rmi softkify-frontend:prod 2>/dev/null
        
        Write-Host "Limpiando sistema Docker..." -ForegroundColor Yellow
        docker system prune -a --volumes -f
        
        Write-Host "`n✓ Sistema limpiado completamente" -ForegroundColor Green
    } else {
        Write-Host "Operación cancelada" -ForegroundColor Yellow
    }
}

# Router de comandos
switch ($command.ToLower()) {
    "dev"   { Dev }
    "prod"  { Prod }
    "build" { Build }
    "stop"  { Stop }
    "logs"  { Logs }
    "clean" { Clean }
    "check" { Check-Docker }
    default { Show-Help }
}
