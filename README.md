# PINV01-25 Infrastructure — Docker Environment Setup

Este repositorio `.github` contiene la infraestructura central para levantar el sistema completo de microservicios PINV01-25 con Docker Compose. Abarca la configuración base, inicialización de servicios, scripts de arranque y entorno de red.

---

## 📁 Estructura del Repositorio

```
pinv01-25-.github/
├── docker-compose.yml        # Orquestador principal
├── .env.template             # Plantilla de variables de entorno
├── setup.sh                  # Script para clonar los servicios
├── docker/                   # Recursos comunes para los contenedores
│   ├── Dockerfile
│   ├── run.sh
│   └── wait-for-it.sh
├── postgres/
│   └── init.sql              # Inicialización del esquema
└── services/                 # Se llena al ejecutar setup.sh
    ├── traffic-sim/
    ├── traffic-storage/
    ├── traffic-sync/
    └── traffic-control/
```

---

## ⚙️ Requisitos

- Docker y Docker Compose
- Git
- Wallet MetaMask con red BlockDAG Testnet configurada
- Fondos de faucet: [https://primordial.bdagscan.com/faucet](https://primordial.bdagscan.com/faucet)

---

## 🚀 Despliegue del Sistema

### 1. Clonar Repositorios

Clona el repositorio principal

```bash
git clone https://github.com/pinv01-25/.github.git
```

Ejecuta el script de inicialización para clonar todos los submódulos necesarios:

```bash
chmod +x setup.sh
./setup.sh
```

Esto clona los cuatro servicios dentro del directorio `services/`.

### 2. Configurar Entorno

```bash
cp .env.template .env
nano .env  # Inserta tu PRIVATE_KEY de MetaMask
```

Valores clave:

```env
PRIVATE_KEY=clave_privada
CHAIN_ID=1043
RPC_URL=https://rpc.primordial.bdagscan.com
```

### 3. Levantar Microservicios

```bash
docker compose up --build
```

Servicios expuestos localmente:

| Servicio        | Puerto |
| --------------- | ------ |
| postgres        | 5433   |
| traffic-storage | 8000   |
| traffic-sim     | 8001   |
| traffic-sync    | 8002   |
| traffic-control | 8003   |

### 4. Detener el Stack

```bash
docker compose down -v
```

---

## 🐳 Detalles Técnicos de Docker

- Cada servicio se construye desde `docker/Dockerfile`
- `run.sh` actúa como entrypoint universal
- `wait-for-it.sh` asegura la disponibilidad de dependencias
- La base de datos `postgres` se inicia con `postgres/init.sql`
- Variables como `SERVICE_NAME` y `SERVICE_PORT` son inyectadas por `docker-compose.yml`

---

## 🔐 Variables de Entorno

El archivo `.env` controla rutas internas y credenciales:

```env
DATABASE_URL=postgresql://trafficuser:trafficpass@postgres:5432/trafficdb
CONTROL_API_URL=http://traffic-control:8003
STORAGE_API_URL=http://traffic-storage:8000
SYNC_API_URL=http://traffic-sync:8002
PRIVATE_KEY=...        # ⚠️ Obligatoria
```

---

## 🛠️ Comportamiento de `run.sh`

El script `run.sh` dentro del contenedor:

- Instala dependencias desde `requirements.txt`
- Lanza `uvicorn` en el puerto asignado
- Espera dependencias críticas según el rol del servicio
- Lanza simulaciones automáticamente si el servicio es `traffic-sim`

---

## 📝 Licencia

MIT License © 2025 PINV01-25 BlockDAG
