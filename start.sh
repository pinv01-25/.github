#!/bin/bash
set -e

# Verificar si existe el archivo .env
if [ ! -f ".env" ]; then
    echo "❌ No se encontró el archivo .env. Ejecuta setup.sh primero."
    exit 1
fi

# Leer configuración IoT
source .env

echo "🚀 Iniciando servicios..."

# Verificar permisos Docker
if ! docker ps >/dev/null 2>&1; then
    echo "⚠️ Usando sudo para Docker (reinicia sesión para evitarlo)"
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD="docker"
fi

if [ "$IOT_DEVICE" = "true" ]; then
    echo "📟 Modo IoT detectado - Excluyendo traffic-sim"
    echo "🔧 Construyendo imágenes optimizadas para IoT..."
    $DOCKER_CMD compose build --build-arg IOT_DEVICE=true postgres traffic-storage traffic-sync traffic-control
    
    echo "📦 Iniciando servicios en orden..."
    $DOCKER_CMD compose up -d postgres
    echo "⏳ Esperando PostgreSQL..."
    sleep 10
    
    $DOCKER_CMD compose up -d traffic-storage traffic-sync
    echo "⏳ Esperando storage y sync..."
    sleep 5
    
    $DOCKER_CMD compose up -d traffic-control
    echo "✅ Servicios IoT iniciados."
    
    # Servicios para mostrar logs
    SERVICES="traffic-storage traffic-sync traffic-control"
    
else
    echo "💻 Modo estándar detectado - Incluyendo todos los servicios"
    echo "🔧 Construyendo imágenes con todas las dependencias..."
    $DOCKER_CMD compose build --build-arg IOT_DEVICE=false
    
    echo "📦 Iniciando servicios en orden..."
    $DOCKER_CMD compose up -d postgres
    echo "⏳ Esperando PostgreSQL..."
    sleep 10
    
    $DOCKER_CMD compose up -d traffic-storage traffic-sync
    echo "⏳ Esperando storage y sync..."
    sleep 5
    
    $DOCKER_CMD compose up -d traffic-control
    echo "⏳ Esperando control..."
    sleep 5
    
    $DOCKER_CMD compose up -d traffic-sim
    echo "✅ Todos los servicios iniciados."
    
    # Servicios para mostrar logs
    SERVICES="traffic-storage traffic-sync traffic-control traffic-sim"
fi

# Mostrar estado de los servicios
echo ""
echo "📊 Estado de los servicios:"
$DOCKER_CMD compose ps

# Esperar un momento para que los servicios se inicializen completamente
echo ""
echo "⏳ Esperando inicialización completa de servicios..."
sleep 15

# Mostrar logs iniciales de cada servicio
echo ""
echo "📋 Logs iniciales de servicios:"
for service in $SERVICES; do
    echo ""
    echo "🔍 === Logs de $service ==="
    $DOCKER_CMD compose logs $service | tail -5
done

echo ""
echo "✅ Todos los servicios están funcionando correctamente!"
echo "📡 URLs disponibles:"
echo "   - Storage: http://localhost:8000"
echo "   - Sync: http://localhost:8002"
echo "   - Control: http://localhost:8003"
if [ "$IOT_DEVICE" != "true" ]; then
    echo "   - Sim: http://localhost:8001"
fi

echo ""
echo "📺 Mostrando logs en tiempo real..."
echo "   (Presiona Ctrl+C para salir)"
echo ""

# Seguir logs en tiempo real
$DOCKER_CMD compose logs -f $SERVICES 