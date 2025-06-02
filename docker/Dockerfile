FROM python:3.12-slim

WORKDIR /app

# Dependencias básicas + ipfs + sumo
RUN apt-get update && apt-get install -y \
    curl wget tar \
    netcat-openbsd \
    sumo sumo-tools sumo-doc \
 && wget https://dist.ipfs.tech/kubo/v0.35.0/kubo_v0.35.0_linux-amd64.tar.gz \
 && tar -xvzf kubo_v0.35.0_linux-amd64.tar.gz \
 && mv kubo/ipfs /usr/local/bin/ipfs \
 && chmod +x /usr/local/bin/ipfs \
 && ipfs init || true \
 && rm -rf kubo* \
 && apt-get clean && rm -rf /var/lib/apt/lists/*

# Copiar los scripts desde contexto build (docker/)
COPY run.sh /usr/local/bin/run.sh
COPY wait-for-it.sh /usr/local/bin/wait-for-it.sh
RUN chmod +x /usr/local/bin/run.sh /usr/local/bin/wait-for-it.sh

# CMD universal
ENV SUMO_HOME=/usr/share/sumo
CMD ["run.sh"]
