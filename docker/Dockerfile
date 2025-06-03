FROM python:3.12-slim

WORKDIR /app

# Variables de entorno para configuración condicional
ARG IOT_DEVICE=false
ENV IOT_DEVICE=${IOT_DEVICE}

# Dependencias básicas
RUN apt-get update && apt-get install -y \
    curl wget tar \
    netcat-openbsd \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Instalar IPFS solo para dispositivos IoT
RUN if [ "$IOT_DEVICE" = "true" ]; then \
    wget https://dist.ipfs.tech/kubo/v0.35.0/kubo_v0.35.0_linux-amd64.tar.gz \
    && tar -xvzf kubo_v0.35.0_linux-amd64.tar.gz \
    && mv kubo/ipfs /usr/local/bin/ipfs \
    && chmod +x /usr/local/bin/ipfs \
    && ipfs init || true \
    && rm -rf kubo* \
    && echo "✅ IPFS instalado para dispositivo IoT"; \
    else \
    echo "⏭️ Omitiendo IPFS para entorno estándar"; \
    fi

# Instalar SUMO solo para entorno estándar (NO IoT)
RUN if [ "$IOT_DEVICE" != "true" ]; then \
    apt-get update && apt-get install -y \
    sumo sumo-tools sumo-doc \
    && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && echo "✅ SUMO instalado para entorno estándar"; \
    else \
    echo "⏭️ Omitiendo SUMO para dispositivo IoT"; \
    fi

# Copiar los scripts desde contexto build (docker/)
COPY run.sh /usr/local/bin/run.sh
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/wait-for-it.sh

# Configurar SUMO_HOME solo si SUMO está instalado
RUN if [ "$IOT_DEVICE" != "true" ]; then \
    echo 'export SUMO_HOME=/usr/share/sumo' >> ~/.bashrc; \
    fi
ENV SUMO_HOME=/usr/share/sumo

# CMD universal
CMD ["run.sh"]
