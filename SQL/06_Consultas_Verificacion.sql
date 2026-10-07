-- CURSOR: resumen y evidencia de rechazados.
USE PersonasETL;
GO
SELECT
    (SELECT COUNT(*) FROM dbo.StgPersonasCursor WHERE SourceRowId BETWEEN 1 AND 100) AS Procesados,
    (SELECT COUNT(*) FROM dbo.CursorValidos) AS Aceptados,
    (SELECT COUNT(*) FROM dbo.CursorRechazados) AS Rechazados,
    (SELECT COUNT(*) FROM dbo.CursorValidos WHERE BalanceMensual < 0) AS BalanceNegativoValido;
SELECT * FROM dbo.CursorRechazados ORDER BY SourceRowId;

-- MODELO RELACIONAL: conteos y duplicados (deben ser cero).
SELECT (SELECT COUNT(*) FROM modelo.Persona) Personas,
       (SELECT COUNT(*) FROM modelo.Observacion) Observaciones,
       (SELECT COUNT(*) FROM etl.Incidencia WHERE Clasificacion=N'RECHAZO') Rechazados,
       (SELECT COUNT(*) FROM etl.Incidencia WHERE Clasificacion=N'DUPLICADO') Duplicados;
SELECT TipoDocumento, NumeroDocumento, COUNT(*) Cantidad
FROM modelo.Persona GROUP BY TipoDocumento, NumeroDocumento HAVING COUNT(*) > 1;
SELECT IdPersona, FechaEncuesta, COUNT(*) Cantidad
FROM modelo.Observacion GROUP BY IdPersona, FechaEncuesta HAVING COUNT(*) > 1;
GO

USE PersonasDW;
GO
-- 1. Personas distintas por municipio.
SELECT u.Departamento, u.Municipio,
       COUNT(DISTINCT f.PersonaKey) AS PersonasDistintas
FROM dw.FactObservacion f
JOIN dw.DimUbicacion u ON u.UbicacionKey=f.UbicacionKey
GROUP BY u.Departamento, u.Municipio
ORDER BY u.Departamento, u.Municipio;

-- 2. Ingreso promedio por nivel educativo.
SELECT e.NivelEducativo, AVG(f.IngresoMensual) AS IngresoPromedio
FROM dw.FactObservacion f
JOIN dw.DimEducacion e ON e.EducacionKey=f.EducacionKey
GROUP BY e.NivelEducativo ORDER BY e.NivelEducativo;

-- 3. Balance promedio por situación laboral.
SELECT s.SituacionLaboral, AVG(f.BalanceMensual) AS BalancePromedio
FROM dw.FactObservacion f
JOIN dw.DimSituacionLaboral s ON s.SituacionLaboralKey=f.SituacionLaboralKey
GROUP BY s.SituacionLaboral ORDER BY s.SituacionLaboral;

-- 4. Cantidad de observaciones por año y mes.
SELECT t.Anio, t.Mes, t.NombreMes, SUM(f.CantidadObservaciones) AS Observaciones
FROM dw.FactObservacion f
JOIN dw.DimTiempo t ON t.TiempoKey=f.TiempoKey
GROUP BY t.Anio, t.Mes, t.NombreMes ORDER BY t.Anio, t.Mes;

-- Control de segunda ejecución: no deben aparecer duplicados.
SELECT IdObservacionOrigen, COUNT(*) Cantidad
FROM dw.FactObservacion GROUP BY IdObservacionOrigen HAVING COUNT(*) > 1;
SELECT PersonaKey, TiempoKey, COUNT(*) Cantidad
FROM dw.FactObservacion GROUP BY PersonaKey, TiempoKey HAVING COUNT(*) > 1;
GO
