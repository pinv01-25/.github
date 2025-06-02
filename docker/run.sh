#!/bin/bash
set -e

chmod +x /usr/local/bin/run.sh /usr/local/bin/wait-for-it.sh

# Instalación de dependencias si existe requirements.txt
if [ -f requirements.txt ]; then
    echo "📦 Instalando dependencias Python..."
    pip install --no-cache-dir --upgrade pip --root-user-action=ignore
    pip install --no-cache-dir --root-user-action=ignore -r requirements.txt
fi

echo "🟡 Esperando servicios necesarios para ${SERVICE_NAME}..."
WAIT_FOR_IT_TIMEOUT=120

if [ "$SERVICE_NAME" = "storage" ]; then
  wait-for-it.sh postgres:5432 -t $WAIT_FOR_IT_TIMEOUT
elif [ "$SERVICE_NAME" = "sync" ]; then
  wait-for-it.sh postgres:5432 -t $WAIT_FOR_IT_TIMEOUT
elif [ "$SERVICE_NAME" = "control" ]; then
  wait-for-it.sh postgres:5432 -t $WAIT_FOR_IT_TIMEOUT
  wait-for-it.sh traffic-storage:8000 -t $WAIT_FOR_IT_TIMEOUT
  wait-for-it.sh traffic-sync:8002 -t $WAIT_FOR_IT_TIMEOUT
elif [ "$SERVICE_NAME" = "sim" ]; then
  wait-for-it.sh postgres:5432 -t $WAIT_FOR_IT_TIMEOUT
  wait-for-it.sh traffic-control:8003 -t $WAIT_FOR_IT_TIMEOUT
  wait-for-it.sh traffic-storage:8000 -t $WAIT_FOR_IT_TIMEOUT
  wait-for-it.sh traffic-sync:8002 -t $WAIT_FOR_IT_TIMEOUT
fi

echo "🚀 Iniciando servicio ${SERVICE_NAME} en el puerto ${SERVICE_PORT}..."
uvicorn api.server:app --port ${SERVICE_PORT} --host 0.0.0.0 --reload &

if [ "$SERVICE_NAME" = "sim" ]; then
    echo "🎮 Ejecutando simulación..."
    sleep 2
    python scripts/simulation/main.py
fi

tail -f /dev/null
