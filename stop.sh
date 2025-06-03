#!/bin/bash
set -e

echo "🛑 Iniciando limpieza completa del proyecto..."

# Verificar permisos Docker
if ! docker ps >/dev/null 2>&1; then
    echo "⚠️ Usando sudo para Docker"
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD="docker"
fi

# Detener y eliminar servicios
if [ -f "docker-compose.yml" ]; then
    echo "📦 Deteniendo servicios Docker..."
    $DOCKER_CMD compose down -v --remove-orphans 2>/dev/null || true
    echo "✅ Servicios detenidos"
else
    echo "⏭️ No se encontró docker-compose.yml"
fi

# Eliminar imágenes del proyecto
echo "🖼️ Eliminando imágenes del proyecto..."
$DOCKER_CMD image rm github-traffic-storage github-traffic-sync github-traffic-control github-traffic-sim 2>/dev/null || true

# Limpiar sistema Docker
echo "🧹 Limpiando sistema Docker..."
$DOCKER_CMD system prune -af --volumes 2>/dev/null || true

# Eliminar archivo .env
if [ -f ".env" ]; then
    echo "📄 Eliminando archivo .env..."
    rm -f .env
    echo "✅ Archivo .env eliminado"
else
    echo "⏭️ No se encontró archivo .env"
fi

# Eliminar directorio services
if [ -d "services" ]; then
    echo "📁 Eliminando directorio services..."
    # Intentar sin sudo primero
    if rm -rf services/ 2>/dev/null; then
        echo "✅ Directorio services eliminado"
    else
        # Si falla, usar sudo (archivos creados por Docker)
        echo "🔐 Usando sudo para eliminar archivos de Docker..."
        sudo rm -rf services/
        echo "✅ Directorio services eliminado con sudo"
    fi
else
    echo "⏭️ No se encontró directorio services"
fi

# Mostrar estado final
echo ""
echo "🔍 Estado final del directorio:"
ls -la | grep -E '\.(env|yml)$|services' || echo "✅ No quedan archivos de configuración"

echo ""
echo "🎉 Limpieza completa finalizada!"
echo "📋 Se eliminó:"
echo "   ✓ Contenedores y volúmenes Docker"
echo "   ✓ Imágenes del proyecto"
echo "   ✓ Cache del sistema Docker"
echo "   ✓ Archivo .env"
echo "   ✓ Directorio services/"
echo ""
echo "🚀 Listo para ejecutar ./setup.sh y empezar de nuevo" 