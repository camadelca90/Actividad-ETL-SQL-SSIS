# Proyecto ETL Personas — importación y pruebas

Esta copia conserva el paquete construido en Visual Studio y agrega los archivos necesarios para completar y verificar el modelo relacional y el DW.

## Contenido principal

- `ETL_Personas/ETL_Excel_Relacional.dtsx`: paquete A existente, ampliado con la consolidación relacional.
- `ETL_Personas/ETL_Relacional_DW.dtsx`: paquete B para la carga idempotente del DW.
- `SQL/07_Completar_Modelo_Relacional.sql`: reglas, rechazos, duplicados, catálogos, observaciones y empleo.
- `SQL/08_Cargar_DW_Idempotente.sql`: dimensiones y tabla de hechos.
- `SQL/09_Verificacion_Final.sql`: conteos, cuatro consultas y prueba de segunda ejecución.
- `Datos/PersonasETLActividad4.xlsx`: copia intacta del archivo original.

## Orden recomendado en el equipo del estudiante

1. Extraer el ZIP en una carpeta nueva; conservar la carpeta anterior como respaldo.
2. Abrir `Actividad_ETL_Personas.sln`.
3. Si Visual Studio solicita actualizar el proyecto, aceptar y guardar.
4. Abrir `CM_Excel_Personas` y seleccionar `Datos/PersonasETLActividad4.xlsx` desde la carpeta extraída.
5. Probar `CM_SQL_PersonasETL` con servidor `(local)\SQLDEV`, autenticación de Windows y base `PersonasETL`.
6. En SSMS ejecutar `SQL/07_Completar_Modelo_Relacional.sql`. Este paso instala el procedimiento y realiza una primera consolidación.
7. Ejecutar `ETL_Excel_Relacional.dtsx`. En una segunda ejecución no debe aumentar la cantidad de personas ni de observaciones.
8. Si las tablas del DW aún no existen, ejecutar primero `SQL/05_Modelo_DW.sql`.
9. Ejecutar `SQL/08_Cargar_DW_Idempotente.sql` para instalar el cargador del DW.
10. Probar la conexión `CM_SQL_PersonasDW` del paquete B y ejecutar `ETL_Relacional_DW.dtsx` dos veces.
11. Ejecutar `SQL/09_Verificacion_Final.sql` y guardar capturas de todos los resultados.

## Evidencias mínimas

1. Flujo de control completo del paquete A.
2. Flujo de datos con Data Conversion, Derived Column, Conditional Split, Lookup, Sort, Row Count y OLE DB Destination.
3. Resultado más reciente de `etl.Ejecucion`.
4. Conteos de personas, observaciones, rechazados y duplicados.
5. Muestras de corrección, rechazo y duplicado en `etl.Incidencia`.
6. Paquete B ejecutado correctamente.
7. Conteos iguales entre `modelo.Observacion` y `dw.FactObservacion`.
8. Las cuatro consultas analíticas.
9. Segunda ejecución sin duplicados.

## Nota técnica

Los paquetes contienen rutas y conexiones locales. Es normal que Visual Studio solicite volver a seleccionar el Excel o confirmar el proveedor OLE DB. Esto no modifica el archivo original.
