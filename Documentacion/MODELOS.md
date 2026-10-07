# Modelos de datos

## Modelo relacional

```mermaid
erDiagram
    DEPARTAMENTO ||--o{ MUNICIPIO : contiene
    MUNICIPIO ||--o{ OBSERVACION : ubica
    PERSONA ||--o{ OBSERVACION : registra
    NIVEL_EDUCATIVO ||--o{ OBSERVACION : clasifica
    SITUACION_LABORAL ||--o{ OBSERVACION : clasifica
    OBSERVACION ||--o| INFORMACION_LABORAL : detalla
    OCUPACION ||--o{ INFORMACION_LABORAL : identifica
```

La persona se identifica de forma única por tipo y número de documento. La observación se identifica por persona y fecha de encuesta. Los catálogos y la ubicación se separan para conservar la normalización.

## Modelo multidimensional

```mermaid
erDiagram
    DIM_PERSONA ||--o{ FACT_OBSERVACION : persona
    DIM_TIEMPO ||--o{ FACT_OBSERVACION : fecha
    DIM_UBICACION ||--o{ FACT_OBSERVACION : lugar
    DIM_EDUCACION ||--o{ FACT_OBSERVACION : educacion
    DIM_SITUACION_LABORAL ||--o{ FACT_OBSERVACION : empleo
```

La granularidad de `FactObservacion` es una observación por persona y fecha de encuesta. Las dimensiones usan claves sustitutas y la tabla de hechos conserva el identificador de origen para controlar la idempotencia.
