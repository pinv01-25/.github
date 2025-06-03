#!/bin/bash
set -e

# Verificar si existe el archivo .env
if [ ! -f ".env" ]; then
    echo "❌ No se encontró el archivo .env. Ejecuta setup.sh primero."
    exit 1
fi

# Leer configuración del modo de ejecución
source .env

echo "🚀 Iniciando servicios..."

# Verificar permisos Docker
if ! docker ps >/dev/null 2>&1; then
    echo "⚠️ Usando sudo para Docker (reinicia sesión para evitarlo)"
    DOCKER_CMD="sudo docker"
else
    DOCKER_CMD="docker"
fi

# Configurar servicios según el modo de ejecución
case $EXECUTION_MODE in
    "iot")
        echo "📟 Modo IoT detectado - Excluyendo traffic-sim"
        echo "🔧 Construyendo imágenes optimizadas para IoT..."
        $DOCKER_CMD compose build \
            --build-arg EXECUTION_MODE=iot \
            --build-arg USE_IPFS=true \
            --build-arg USE_SUMO=false \
            postgres traffic-storage traffic-sync traffic-control
        SERVICES="traffic-storage traffic-sync traffic-control"
        ;;
    "web")
        echo "🌐 Modo Web Service detectado"
        echo "🔧 Construyendo imágenes para servicio web..."
        $DOCKER_CMD compose build \
            --build-arg EXECUTION_MODE=web \
            --build-arg USE_IPFS=false \
            --build-arg USE_SUMO=true
        SERVICES="traffic-storage traffic-sync traffic-control traffic-sim"
        ;;
    "local")
        echo "💻 Modo Local detectado"
        echo "🔧 Construyendo imágenes para entorno local..."
        $DOCKER_CMD compose build \
            --build-arg EXECUTION_MODE=local \
            --build-arg USE_IPFS=true \
            --build-arg USE_SUMO=true
        SERVICES="traffic-storage traffic-sync traffic-control traffic-sim"
        ;;
    *)
        echo "❌ Modo de ejecución no válido en .env"
        exit 1
        ;;
esac

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

if [ "$EXECUTION_MODE" != "iot" ]; then
    $DOCKER_CMD compose up -d traffic-sim
    echo "⏳ Esperando simulador..."
    sleep 5
fi

echo "✅ Servicios iniciados según modo $EXECUTION_MODE."

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
if [ "$EXECUTION_MODE" != "iot" ]; then
    echo "   - Sim: http://localhost:8001"
fi

echo ""
echo "📺 Mostrando logs en tiempo real..."
echo "   (Presiona Ctrl+C para salir)"
echo ""

# Seguir logs en tiempo real
$DOCKER_CMD compose logs -f $SERVICES 