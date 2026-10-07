USE PersonasETL;
GO

SELECT TOP (1) * FROM etl.Ejecucion ORDER BY FechaInicio DESC;

SELECT
 (SELECT COUNT(*) FROM etl.StgPersonasExcel) AS RegistrosStaging,
 (SELECT COUNT(*) FROM modelo.Persona) AS Personas,
 (SELECT COUNT(*) FROM modelo.Observacion) AS Observaciones,
 (SELECT COUNT(*) FROM modelo.InformacionLaboral) AS RegistrosLaborales,
 (SELECT COUNT(*) FROM etl.Incidencia WHERE Clasificacion=N'RECHAZO') AS Rechazados,
 (SELECT COUNT(*) FROM etl.Incidencia WHERE Clasificacion=N'DUPLICADO') AS Duplicados;

SELECT TipoDocumento,NumeroDocumento,COUNT(*) Cantidad
FROM modelo.Persona GROUP BY TipoDocumento,NumeroDocumento HAVING COUNT(*)>1;

SELECT IdPersona,FechaEncuesta,COUNT(*) Cantidad
FROM modelo.Observacion GROUP BY IdPersona,FechaEncuesta HAVING COUNT(*)>1;
GO

USE PersonasDW;
GO

SELECT u.Departamento,u.Municipio,COUNT(DISTINCT f.PersonaKey) PersonasDistintas
FROM dw.FactObservacion f JOIN dw.DimUbicacion u ON u.UbicacionKey=f.UbicacionKey
GROUP BY u.Departamento,u.Municipio ORDER BY u.Departamento,u.Municipio;

SELECT e.NivelEducativo,AVG(f.IngresoMensual) IngresoPromedio
FROM dw.FactObservacion f JOIN dw.DimEducacion e ON e.EducacionKey=f.EducacionKey
GROUP BY e.NivelEducativo ORDER BY e.NivelEducativo;

SELECT s.SituacionLaboral,AVG(f.BalanceMensual) BalancePromedio
FROM dw.FactObservacion f JOIN dw.DimSituacionLaboral s ON s.SituacionLaboralKey=f.SituacionLaboralKey
GROUP BY s.SituacionLaboral ORDER BY s.SituacionLaboral;

SELECT t.Anio,t.Mes,t.NombreMes,SUM(f.CantidadObservaciones) Observaciones
FROM dw.FactObservacion f JOIN dw.DimTiempo t ON t.TiempoKey=f.TiempoKey
GROUP BY t.Anio,t.Mes,t.NombreMes ORDER BY t.Anio,t.Mes;

SELECT
 (SELECT COUNT(*) FROM PersonasETL.modelo.Observacion) AS ObservacionesRelacional,
 (SELECT COUNT(*) FROM dw.FactObservacion) AS ObservacionesDW,
 (SELECT COUNT(*) FROM dw.FactObservacion) AS FilasAntesSegundaEjecucion;

EXEC dw.usp_CargarDW;

SELECT COUNT(*) AS FilasDespuesSegundaEjecucion FROM dw.FactObservacion;
SELECT IdObservacionOrigen,COUNT(*) Cantidad
FROM dw.FactObservacion GROUP BY IdObservacionOrigen HAVING COUNT(*)>1;
GO
