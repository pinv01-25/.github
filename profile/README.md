# PINV01-2025 — Organización de Módulos

El proyecto PINV01-25 un conjunto modular de microservicios diseñados para **detectar congestión vehicular**, **almacenar datos de manera transparente**, y **optimizar los tiempos de semáforos** utilizando simulación.

Este sistema está compuesto por 4 módulos principales, organizados en repositorios separados:

---

## Repositorios Principales

### [`traffic-sim`](https://github.com/pinv01-25/traffic-sim)

> **Simulador de tráfico** basado en SUMO + TraCI.

- Detecta congestión vehicular por tráfico en tiempo real.
- Calcula la densidad normalizada en los segmentos controlados por semáforos.
- Genera eventos de alta congestión y exporta datos en formato JSON.

### [`traffic-storage`](https://github.com/pinv01-25/traffic-storage)

> **API REST de almacenamiento de datos** y acceso transparente.

- Recibe metadatos de tráfico y optimización en JSON (formato unificado 2.0).
- **Soporte para lotes**: Maneja tanto sensores individuales como lotes de 1-10 sensores.
- Almacena la metadata en **IPFS** y guarda el `CID` asociado en **BlockDAG testnet**.
- **Timestamps Unix**: Requiere timestamps en formato Unix (int) para compatibilidad con BlockDAG.
- Exposición de endpoints REST:

  - `POST /upload` - Sube datos (sensores individuales o lotes)
  - `POST /download` - Descarga datos
  - `GET /healthcheck` - Verificación de estado

- Valida la estructura de los datos y asegura trazabilidad.

### [`traffic-sync`](https://github.com/pinv01-25/traffic-sync)

> **Motor de análisis y optimización de tráfico**.

- Recibe datos de tráfico almacenados (formato unificado 2.0).
- **Procesamiento en lotes**: Maneja lotes de 1-10 sensores en una sola petición.
- **Fuzzy Logic**: Sistema de inferencia Mamdani para clasificar congestión.
- **Clustering**: Agrupación jerárquica de sensores por patrones de congestión.
- **PSO**: Optimización por enjambre de partículas para tiempos de semáforos.
- **Frontend web**: Dashboard interactivo para análisis y visualización.
- Clasifica la gravedad de la congestión (ninguna, leve, severa).
- Calcula tiempos óptimos de luz verde/roja por semáforo.
- Genera metadatos de optimización y los envía a `traffic-storage`.

### [`traffic-control`](https://github.com/pinv01-25/traffic-control)

> **Orquestador del sistema**.

- Coordina la comunicación entre los módulos `sim → storage → sync`.
- **Procesamiento unificado**: Maneja tanto sensores individuales como lotes de 1-10 sensores.
- **Base de datos PostgreSQL**: Almacena metadatos y registros de procesamiento.
- **Validación robusta**: Verifica estructura de datos, timestamps y límites.
- **Endpoints de metadatos**: Gestión completa de metadatos por semáforo, tipo y estadísticas.
- Escucha eventos de tráfico (alta densidad).
- Recupera datos y resultados desde `traffic-storage`.

---

## Tecnologías Usadas

- **SUMO + TraCI**: Simulación de tráfico
- **FastAPI**: APIs REST
- **PostgreSQL**: Base de datos para metadatos
- **IPFS**: Almacenamiento descentralizado de datos
- **BlockDAG testnet**: Registro de `CIDs` y eventos verificables

---

## Estructura de Datos

### Formato Unificado 2.0 - Lote de Sensores

```json
{
  "version": "2.0",
  "type": "data",
  "timestamp": "2025-07-14T00:33:55Z",
  "traffic_light_id": "03",
  "sensors": [
    {
      "traffic_light_id": "03",
      "controlled_edges": ["edge05", "edge01", "edge14"],
      "metrics": {
        "vehicles_per_minute": 34,
        "avg_speed_kmh": 34.6,
        "avg_circulation_time_sec": 20,
        "density": 0.49
      },
      "vehicle_stats": {
        "motorcycle": 25,
        "car": 44,
        "bus": 4,
        "truck": 10
      }
    },
    {
      "traffic_light_id": "07",
      "controlled_edges": ["edge12", "edge08", "edge03"],
      "metrics": {
        "vehicles_per_minute": 28,
        "avg_speed_kmh": 42.1,
        "avg_circulation_time_sec": 18,
        "density": 0.31
      },
      "vehicle_stats": {
        "motorcycle": 18,
        "car": 52,
        "bus": 2,
        "truck": 8
      }
    }
  ]
}
```

### Formato Unificado 2.0 - Optimización

```json
{
  "version": "2.0",
  "type": "optimization",
  "timestamp": "2025-07-14T00:33:55Z",
  "traffic_light_id": "03",
  "optimizations": [
    {
      "version": "2.0",
      "type": "optimization",
      "timestamp": "2025-07-14T00:33:55Z",
      "traffic_light_id": "03",
      "cluster_sensors": ["03", "07"],
      "optimization": {
        "green_time_sec": 14,
        "red_time_sec": 75
      },
      "impact": {
        "original_congestion": 4,
        "optimized_congestion": 1,
        "original_category": "mild",
        "optimized_category": "none"
      }
    }
  ]
}
```

### Características del Formato 2.0

- **Versión**: Siempre "2.0" para compatibilidad
- **Timestamps**: Formato ISO string (traffic-sim, traffic-sync) o Unix int (traffic-storage)
- **Lotes**: Soporte para 1-10 sensores por lote
- **Clustering**: Información de agrupación de sensores en optimizaciones
- **Retrocompatibilidad**: Compatible con sensores individuales

---

## ¿Cómo empezar?

Cada módulo tiene su propio `README.md` con instrucciones para instalación, ejecución local, y pruebas.

### Recomendación para entorno de desarrollo local:

1. Clonar todos los repos en una carpeta común.
2. Usar entornos virtuales por módulo (`venv`).
3. Levantar los módulos de forma aislada.
4. **Configurar PostgreSQL** para traffic-control.
5. **Configurar IPFS** para traffic-storage.

## Despliegue del Sistema con Docker

Este proyecto incluye un entorno completo de microservicios orquestado mediante **Docker Compose**. A continuación se detallan las instrucciones técnicas para clonar, configurar y levantar el stack de servicios.

---

### 1. Prerrequisitos

- [Docker](https://www.docker.com/get-started/)
- [Git](https://git-scm.com/)

---

### 2. Clonado de Módulos

Clona el repositorio principal

```bash
git clone https://github.com/pinv01-25/.github.git
```

Ejecuta el script de inicialización para clonar todos los submódulos necesarios:

```bash
chmod +x setup.sh
./setup.sh
```

Esto clonará los siguientes servicios dentro del directorio `services/`:

- `traffic-control`
- `traffic-sim`
- `traffic-storage`
- `traffic-sync`

---

### 3. Configuración del Entorno

Crea el archivo `.env` basado en la plantilla proporcionada:

```bash
cp .env.template .env
```

Edita solo la siguiente variable:

- `PRIVATE_KEY`: clave privada de tu wallet **MetaMask** configurada para la red **BlockDAG Testnet**.

Antes de continuar:

- Agrega manualmente la red **BlockDAG Testnet** a MetaMask.
- Usa la faucet para obtener fondos: [https://primordial.bdagscan.com/faucet](https://primordial.bdagscan.com/faucet)

---

### 4. Construcción y Despliegue del Stack

Construye y levanta todos los servicios usando Docker Compose:

```bash
docker compose up --build
```

Esto iniciará los siguientes servicios expuestos en los puertos locales:

| Servicio          | Puerto |
| ----------------- | ------ |
| `postgres`        | 5433   |
| `traffic-storage` | 8000   |
| `traffic-sim`     | 8001   |
| `traffic-sync`    | 8002   |
| `traffic-control` | 8003   |

---

### 5. Detener Contenedores

Para detener y eliminar todos los contenedores, volúmenes y redes:

```bash
docker compose down -v
```

---

### 6. Notas Adicionales

- Los servicios se inician automáticamente con `uvicorn`.
- `traffic-sim` ejecuta `scripts/simulation/main.py` al iniciarse.
- Asegúrate de que los puertos 8000-8003 y 5433 estén libres en tu sistema.

---

## Autores

- Majo Duarte
- Kevin Galeano
