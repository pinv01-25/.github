#!/bin/bash
set -e

# Mostrar menú de opciones
echo "🔧 Selecciona el modo de ejecución:"
echo "1. IoT (sin SUMO, con IPFS local, sin Pinata)"
echo "2. Web Service (con SUMO, sin IPFS, con Pinata)"
echo "3. Local (con SUMO, con IPFS local, sin Pinata)"
echo "Ingresa tu opción (1-3): "
read -r mode_option

# Validar la opción
if [[ ! $mode_option =~ ^[1-3]$ ]]; then
    echo "❌ Opción inválida. Debe ser 1, 2 o 3."
    exit 1
fi

# Preguntar por la PRIVATE_KEY obligatoria
echo "🔑 Ingresa tu PRIVATE_KEY de MetaMask: "
read -r private_key

# Variables específicas según el modo seleccionado
case $mode_option in
    1)
        echo "📟 Configurando para dispositivo IoT..."
        repos=("storage" "sync" "control")
        mode="iot"
        use_ipfs=true
        use_pinata=false
        use_sumo=false
        ;;
    2)
        echo "🌐 Configurando para Web Service..."
        repos=("sim" "storage" "sync" "control")
        mode="web"
        use_ipfs=false
        use_pinata=true
        use_sumo=true
        # Preguntar por credenciales de Pinata
        echo "📌 Ingresa tu PINATA_JWT para IPFS: "
        read -r pinata_jwt
        echo "🌐 Ingresa tu PINATA_URL para IPFS: "
        read -r pinata_url
        ;;
    3)
        echo "💻 Configurando para modo Local..."
        repos=("sim" "storage" "sync" "control")
        mode="local"
        use_ipfs=true
        use_pinata=false
        use_sumo=true
        ;;
esac

# Crear archivo .env basado en template si existe, o crear uno básico
if [ -f ".env.template" ]; then
    echo "📄 Usando .env.template como base..."
    cp .env.template .env
else
    echo "📄 Creando .env básico..."
    cat > .env << EOF
# Base de datos
DATABASE_URL=postgresql://trafficuser:trafficpass@postgres:5432/trafficdb

# URLs de servicios
CONTROL_API_URL=http://traffic-control:8003
STORAGE_API_URL=http://traffic-storage:8000
SYNC_API_URL=http://traffic-sync:8002

# Blockchain
CHAIN_ID=1043
RPC_URL=https://rpc.primordial.bdagscan.com
EOF
fi

# Agregar configuraciones específicas
echo "" >> .env
echo "# Configuración específica" >> .env
echo "PRIVATE_KEY=$private_key" >> .env
echo "EXECUTION_MODE=$mode" >> .env
echo "USE_IPFS=$use_ipfs" >> .env
echo "USE_SUMO=$use_sumo" >> .env

# Configurar GUI y Pinata según el modo
echo "SHOW_GUI=false" >> .env
if [ "$use_pinata" = "true" ]; then
    echo "USE_PINATA=true" >> .env
    echo "PINATA_JWT=$pinata_jwt" >> .env
    echo "PINATA_URL=$pinata_url" >> .env
else
    echo "USE_PINATA=false" >> .env
fi

mkdir -p services
cd services

for repo in "${repos[@]}"; do
  if [ ! -d "traffic-$repo" ]; then
    echo "📥 Clonando traffic-$repo..."
    
    # Solo usar rama jetson para storage cuando se usa IPFS local
    if [ "$repo" = "storage" ] && [ "$use_ipfs" = "true" ]; then
        git clone -b jetson https://github.com/pinv01-25/traffic-$repo.git traffic-$repo
        echo "🦾 Usando rama jetson para traffic-storage"
    else
        git clone https://github.com/pinv01-25/traffic-$repo.git traffic-$repo
    fi
  else
    echo "🔁 traffic-$repo ya está presente, omitiendo..."
  fi
done

cd ..
echo "✅ Repositorios clonados."
echo "📄 Archivo .env configurado."
