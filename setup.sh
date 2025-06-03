#!/bin/bash
set -e

# Preguntar si será ejecutado en dispositivo IoT
echo "🤖 ¿Será ejecutado en un dispositivo IoT? (y/n): "
read -r iot_device

# Preguntar por la PRIVATE_KEY obligatoria
echo "🔑 Ingresa tu PRIVATE_KEY de MetaMask: "
read -r private_key

# Variables específicas según el entorno
if [[ $iot_device =~ ^[Yy]$ ]]; then
    echo "📟 Configurando para dispositivo IoT (usando IPFS local)..."
    repos=("storage" "sync" "control")
    iot_mode=true
else
    echo "💻 Configurando para entorno estándar (usando Pinata)..."
    # Preguntar por PINATA solo en entorno estándar
    echo "📌 Ingresa tu PINATA_JWT para IPFS: "
    read -r pinata_jwt
    echo "🌐 Ingresa tu PINATA_URL para IPFS: "
    read -r pinata_url
    repos=("sim" "storage" "sync" "control")
    iot_mode=false
fi

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

if [ "$iot_mode" = "true" ]; then
    echo "IOT_DEVICE=true" >> .env
    echo "SHOW_GUI=false" >> .env
    echo "# IoT usa IPFS local (sin Pinata)" >> .env
else
    echo "IOT_DEVICE=false" >> .env
    echo "SHOW_GUI=false" >> .env
    echo "PINATA_JWT=$pinata_jwt" >> .env
    echo "PINATA_URL=$pinata_url" >> .env
fi

mkdir -p services
cd services

for repo in "${repos[@]}"; do
  if [ ! -d "traffic-$repo" ]; then
    echo "📥 Clonando traffic-$repo..."
    
    # Para traffic-storage en IoT, usar rama jetson
    if [ "$iot_mode" = "true" ] && [[ $repo == "storage" ]]; then
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
