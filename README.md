# Traffic Management System

Sistema de gestión de tráfico distribuido con soporte para dispositivos IoT y entornos estándar.

## 🚀 Inicio Rápido

### 1. Configuración Inicial

Ejecuta el script de configuración que te preguntará:

```bash
chmod +x setup.sh
./setup.sh
```

El script te pedirá:

- **🤖 ¿Será ejecutado en un dispositivo IoT? (y/n):**
  - **Sí (y)**: Configura para dispositivo IoT (sin traffic-sim, usando rama jetson para storage)
  - **No (n)**: Configura para entorno estándar (todos los servicios)
- **🔑 PRIVATE_KEY de MetaMask**: Clave privada obligatoria para blockchain
- **📌 PINATA_JWT**: Token JWT de Pinata para IPFS (solo entorno estándar)
- **🌐 PINATA_URL**: URL de Pinata para IPFS (solo entorno estándar)

### 2. Iniciar Servicios

Una vez completada la configuración, inicia los servicios:

```bash
chmod +x start.sh
./start.sh
```

El script:

- Construye e inicia servicios en orden correcto
- Muestra logs iniciales de cada servicio FastAPI
- Lista URLs disponibles para acceder a las APIs
- **Muestra logs en tiempo real** de todos los servicios
- Presiona `Ctrl+C` para salir del monitoreo de logs

### 3. Detener y Limpiar (Opcional)

Para limpiar completamente el proyecto:

```bash
chmod +x stop.sh
./stop.sh
```

Esto elimina:

- Todos los contenedores y volúmenes
- Imágenes Docker del proyecto
- Archivo `.env` y directorio `services/`
- Cache del sistema Docker

## 📋 Diferencias entre Entornos

### 🖥️ Entorno Estándar

- **Servicios**: traffic-sim, traffic-storage, traffic-sync, traffic-control, postgres
- **Dependencias**: Solo SUMO (sin IPFS)
- **Storage**: Pinata para IPFS distribuido
- **Rama**: main para todos los repositorios
- **Puerto sim**: 8001

### 📟 Dispositivo IoT

- **Servicios**: traffic-storage, traffic-sync, traffic-control, postgres (sin sim)
- **Dependencias**: Solo IPFS (sin SUMO para optimizar recursos)
- **Storage**: IPFS local (sin Pinata)
- **Rama**: jetson para traffic-storage, main para otros
- **Optimizado**: Modo ligero habilitado

## 🔧 Variables de Entorno

El script usa `.env.template` como base si existe, o crea las variables esenciales:

### Variables Obligatorias

```env
PRIVATE_KEY=tu_clave_privada_metamask
IOT_DEVICE=true/false
SHOW_GUI=false
```

### Variables Condicionales

```env
# Solo para entorno estándar (IOT_DEVICE=false)
PINATA_JWT=tu_pinata_jwt
PINATA_URL=tu_pinata_url

# IoT usa IPFS local (sin Pinata)
```

### Variables del Template

```env
DATABASE_URL=postgresql://trafficuser:trafficpass@postgres:5432/trafficdb
CONTROL_API_URL=http://traffic-control:8003
STORAGE_API_URL=http://traffic-storage:8000
SYNC_API_URL=http://traffic-sync:8002
CHAIN_ID=1043
RPC_URL=https://rpc.primordial.bdagscan.com
```

## 📁 Estructura de Servicios

```
services/
├── traffic-sim/      # Solo en entorno estándar
├── traffic-storage/  # Rama jetson en IoT, main en estándar
├── traffic-sync/
└── traffic-control/
```

## 🐳 Docker

### Orden de Inicio

El script `start.sh` inicia los servicios en el orden correcto:

**IoT**: postgres → storage + sync → control
**Estándar**: postgres → storage + sync → control → sim

### Build Arguments

- `IOT_DEVICE=true/false`: Controla qué dependencias instalar

### Perfiles

- **standard**: Incluye traffic-sim
- **Por defecto**: Excluye traffic-sim (modo IoT)

## 📊 Monitoreo

Para ver el estado de los servicios:

```bash
docker-compose ps
```

Para ver logs:

```bash
docker-compose logs -f [nombre-servicio]
```

## 🛠️ Scripts Disponibles

| Script     | Descripción           | Función                                            |
| ---------- | --------------------- | -------------------------------------------------- |
| `setup.sh` | Configuración inicial | Clona repositorios y crea `.env`                   |
| `start.sh` | Iniciar servicios     | Construye, ejecuta y monitorea logs en tiempo real |
| `stop.sh`  | Limpieza completa     | Elimina todo y prepara para reiniciar              |

### Flujo Completo

```bash
# 1. Configurar proyecto
./setup.sh

# 2. Iniciar servicios
./start.sh

# 3. Limpiar todo (cuando sea necesario)
./stop.sh
```

## 🔧 Comandos Útiles

```bash
# Detener servicios
docker-compose down

# Reconstruir servicios
docker-compose build --no-cache

# Limpiar volúmenes
docker-compose down -v
```

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
