FROM python:3.12-slim

WORKDIR /app

# Variables de entorno para configuración condicional
ARG EXECUTION_MODE=web
ENV EXECUTION_MODE=${EXECUTION_MODE}
ARG USE_IPFS=false
ENV USE_IPFS=${USE_IPFS}
ARG USE_SUMO=true
ENV USE_SUMO=${USE_SUMO}

# Dependencias básicas del sistema
RUN apt-get update && apt-get install -y \
    curl wget tar \
    netcat-openbsd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Dependencias básicas de Python
RUN pip install --no-cache-dir \
    fastapi==0.109.2 \
    uvicorn==0.27.1 \
    python-dotenv==1.0.1 \
    requests==2.31.0

# Instalar IPFS si es necesario (modo IoT o Local)
RUN if [ "$USE_IPFS" = "true" ]; then \
    wget https://dist.ipfs.tech/kubo/v0.35.0/kubo_v0.35.0_linux-amd64.tar.gz \
    && tar -xvzf kubo_v0.35.0_linux-amd64.tar.gz \
    && mv kubo/ipfs /usr/local/bin/ipfs \
    && chmod +x /usr/local/bin/ipfs \
    && ipfs init || true \
    && rm -rf kubo* \
    && echo "✅ IPFS instalado"; \
    else \
    echo "⏭️ Omitiendo instalación de IPFS"; \
    fi

# Instalar SUMO si es necesario (modo Web Service o Local)
RUN if [ "$USE_SUMO" = "true" ]; then \
    apt-get update && apt-get install -y \
    sumo sumo-tools sumo-doc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "✅ SUMO instalado"; \
    else \
    echo "⏭️ Omitiendo instalación de SUMO"; \
    fi

# Copiar los scripts desde contexto build (docker/)
COPY run.sh /usr/local/bin/run.sh
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/wait-for-it.sh

# Configurar SUMO_HOME solo si SUMO está instalado
RUN if [ "$USE_SUMO" = "true" ]; then \
    echo 'export SUMO_HOME=/usr/share/sumo' >> ~/.bashrc; \
    fi
ENV SUMO_HOME=/usr/share/sumo

# CMD universal
CMD ["run.sh"]
