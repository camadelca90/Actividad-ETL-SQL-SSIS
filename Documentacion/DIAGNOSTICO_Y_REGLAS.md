# Diagnóstico inicial y reglas de tratamiento

## Diagnóstico del Excel original

El archivo contiene 1.000 filas de datos y 37 columnas. Todos los campos llegan desde Excel como texto para evitar pérdidas durante la extracción.

Hallazgos preliminares sobre los 1.000 registros:

| Hallazgo | Cantidad |
|---|---:|
| Documento vacío | 45 |
| Documento inválido incluyendo `SIN-DATO` | 68 |
| Primer nombre faltante | 22 |
| Primer apellido faltante | 0 |
| Fecha de nacimiento inválida | 45 |
| Fecha de encuesta inválida | 22 |
| Nacimiento posterior a encuesta | 23 |
| Edad reportada inconsistente | 69 |
| Ingreso no numérico | 44 |
| Ingreso negativo | 22 |
| Gasto faltante | 22 |
| Grupos de personas duplicadas | 50 |
| Grupos de observaciones duplicadas | 50 |
| Filas adicionales por duplicidad | 50 |

Las cantidades definitivas deben producirse mediante contadores de SSIS y guardarse en `etl.Ejecucion` y `etl.Incidencia`.

## Reglas de tratamiento

| Campo o grupo | Regla | Resultado |
|---|---|---|
| Textos | `TRIM`, mayúsculas para categorías y escritura uniforme para nombres | Corrección registrada |
| Documento | Tipo normalizado; número obligatorio; `SIM` + siete dígitos es válido | Rechazo si falta o no cumple |
| Contacto | Correo con estructura básica; teléfono de prueba que inicia en `000` es válido | Revisión si formato dudoso |
| Fechas | Barras en orden día/mes/año; conversión válida | Rechazo si fecha esencial es inválida |
| Edad | Comparar con diferencia entre nacimiento y encuesta, ajustada por cumpleaños | Revisión si no coincide |
| Geografía | Municipio debe pertenecer al departamento según códigos internos | Rechazo si no existe correspondencia |
| Ingresos y gastos | Quitar `COP`, `$`, espacios y miles; coma como decimal; no usar cero para desconocidos | Rechazo si falta, no es numérico o es negativo |
| Balance | Ingreso menos gasto | Balance negativo permitido |
| Hogar | Valores enteros no negativos y personas a cargo menores que tamaño del hogar | Revisión o rechazo según severidad |
| Empleo | Datos de ocupación y contrato coherentes con situación laboral | Revisión si hay contradicción |
| Persona duplicada | Tipo + número de documento | Conservar versión con `UpdatedAt` más reciente |
| Observación duplicada | Persona + fecha de encuesta | Conservar la versión con `UpdatedAt` más reciente; desempate por mayor `SourceRowId` |

## Clasificación

- **Válido:** cumple reglas obligatorias y puede cargarse.
- **Revisión:** conserva datos útiles, pero presenta una inconsistencia no crítica que debe revisarse.
- **Rechazado:** falta una clave, una fecha esencial o un importe requerido, o existe un valor inválido crítico.
- **Duplicado:** pierde frente al registro conservado según `UpdatedAt` y `SourceRowId`.
