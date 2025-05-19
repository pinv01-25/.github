# PINV01-2025 — Organización de Módulos

El proyecto PINV01-25 un conjunto modular de microservicios diseñados para **detectar congestión vehicular**, **almacenar datos de manera transparente**, y **optimizar los tiempos de semáforos** utilizando simulación.

Este sistema está compuesto por 4 módulos principales, organizados en repositorios separados:

---

## Repositorios Principales

### [`traffic-sim`](https://github.com/pinv01-25/traffic-sim)

> **Simulador de tráfico** basado en SUMO + TraCI.

* Detecta congestión vehicular por tráfico en tiempo real.
* Calcula la densidad normalizada en los segmentos controlados por semáforos.
* Genera eventos de alta congestión y exporta datos en formato JSON.

### [`traffic-storage`](https://github.com/pinv01-25/traffic-storage)

> **API REST de almacenamiento de datos** y acceso transparente.

* Recibe metadatos de tráfico y optimización en JSON.
* Almacena la metadata en **IPFS** y guarda el `CID` asociado en **BlockDAG testnet**.
* Exposición de endpoints REST:

  * `POST /upload`
  * `POST /download`
  * `GET /healthcheck`
* Valida la estructura de los datos y asegura trazabilidad.

### [`traffic-sync`](https://github.com/pinv01-25/traffic-sync)

> **Motor de análisis y optimización de tráfico**.

* Recibe datos de tráfico almacenados.
* Clasifica la gravedad de la congestión (ninguna, leve, severa).
* Calcula tiempos óptimos de luz verde/roja por semáforo.
* Genera metadatos de optimización y los envía a `traffic-storage`.

### [`traffic-control`](https://github.com/pinv01-25/traffic-control)

> **Orquestador del sistema**.

* Coordina la comunicación entre los módulos `sim → storage → sync`.
* Escucha eventos de tráfico (alta densidad).
* Recupera datos y resultados desde `traffic-storage`.

---

##  Tecnologías Usadas

*  **SUMO + TraCI**: Simulación de tráfico
*  **FastAPI**: APIs REST
*  **IPFS**: Almacenamiento descentralizado de datos
*  **BlockDAG testnet**: Registro de `CIDs` y eventos verificables

---

##  Estructura de Datos

### Tipo `data`

```json
{
  "version": "1.0",
  "type": "data",
  "timestamp": "2025-04-24T08:15:00Z",
  "traffic_light_id": "TL_21",
  "controlled_edges": ["edge42", "edge43"],
  "metrics": {
    "vehicles_per_minute": 65,
    "avg_speed_kmh": 43.5,
    "avg_circulation_time_sec": 92,
    "density": 0.72
  },
  "vehicle_stats": {
    "motorcycle": 12,
    "car": 45,
    "bus": 2,
    "truck": 6
  }
}
```

### Tipo `optimization`

```json
{
  "version": "1.0",
  "type": "optimization",
  "timestamp": "2025-04-24T08:16:00Z",
  "traffic_light_id": "TL_21",
  "optimization": {
    "green_time_sec": 45,
    "red_time_sec": 30
  },
  "impact": {
    "original_congestion": 78,
    "optimized_congestion": 45,
    "original_category": "severe",
    "optimized_category": "mild"
  }
}
```

---

##  ¿Cómo empezar?

Cada módulo tiene su propio `README.md` con instrucciones para instalación, ejecución local, y pruebas.

### Recomendación para entorno de desarrollo local:

1. Clonar todos los repos en una carpeta común.
2. Usar entornos virtuales por módulo (`venv`).
3. Levantar los módulos de forma aislada.

---

## Autores
* Majo Duarte
* Kevin Galeano


