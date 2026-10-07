USE PersonasDW;
GO

CREATE OR ALTER PROCEDURE dw.usp_CargarDW
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    INSERT dw.DimTiempo(TiempoKey,Fecha,Anio,Mes,NombreMes,Trimestre)
    SELECT DISTINCT CONVERT(int,CONVERT(char(8),v.FechaEncuesta,112)),v.FechaEncuesta,
           YEAR(v.FechaEncuesta),MONTH(v.FechaEncuesta),
           CHOOSE(MONTH(v.FechaEncuesta),N'ENERO',N'FEBRERO',N'MARZO',N'ABRIL',N'MAYO',N'JUNIO',
                  N'JULIO',N'AGOSTO',N'SEPTIEMBRE',N'OCTUBRE',N'NOVIEMBRE',N'DICIEMBRE'),
           DATEPART(QUARTER,v.FechaEncuesta)
    FROM PersonasETL.modelo.vw_DatosDepuradosDW v
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimTiempo d WHERE d.Fecha=v.FechaEncuesta);

    INSERT dw.DimPersona(IdPersonaOrigen,TipoDocumento,NumeroDocumento,FechaNacimiento)
    SELECT DISTINCT v.IdPersona,v.TipoDocumento,v.NumeroDocumento,v.FechaNacimiento
    FROM PersonasETL.modelo.vw_DatosDepuradosDW v
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimPersona d WHERE d.IdPersonaOrigen=v.IdPersona);

    INSERT dw.DimUbicacion(CodigoDepartamento,Departamento,CodigoMunicipio,Municipio)
    SELECT DISTINCT v.CodigoDepartamento,v.Departamento,v.CodigoMunicipio,v.Municipio
    FROM PersonasETL.modelo.vw_DatosDepuradosDW v
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimUbicacion d
                      WHERE d.CodigoDepartamento=v.CodigoDepartamento AND d.CodigoMunicipio=v.CodigoMunicipio);

    INSERT dw.DimEducacion(NivelEducativo)
    SELECT DISTINCT v.NivelEducativo FROM PersonasETL.modelo.vw_DatosDepuradosDW v
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimEducacion d WHERE d.NivelEducativo=v.NivelEducativo);

    INSERT dw.DimSituacionLaboral(SituacionLaboral)
    SELECT DISTINCT v.SituacionLaboral FROM PersonasETL.modelo.vw_DatosDepuradosDW v
    WHERE NOT EXISTS (SELECT 1 FROM dw.DimSituacionLaboral d WHERE d.SituacionLaboral=v.SituacionLaboral);

    INSERT dw.FactObservacion(IdObservacionOrigen,PersonaKey,TiempoKey,UbicacionKey,EducacionKey,
                              SituacionLaboralKey,IngresoMensual,GastoMensual,BalanceMensual,CantidadObservaciones)
    SELECT v.IdObservacion,p.PersonaKey,t.TiempoKey,u.UbicacionKey,e.EducacionKey,s.SituacionLaboralKey,
           v.IngresoMensual,v.GastoMensual,v.BalanceMensual,1
    FROM PersonasETL.modelo.vw_DatosDepuradosDW v
    JOIN dw.DimPersona p ON p.IdPersonaOrigen=v.IdPersona
    JOIN dw.DimTiempo t ON t.Fecha=v.FechaEncuesta
    JOIN dw.DimUbicacion u ON u.CodigoDepartamento=v.CodigoDepartamento AND u.CodigoMunicipio=v.CodigoMunicipio
    JOIN dw.DimEducacion e ON e.NivelEducativo=v.NivelEducativo
    JOIN dw.DimSituacionLaboral s ON s.SituacionLaboral=v.SituacionLaboral
    WHERE NOT EXISTS (SELECT 1 FROM dw.FactObservacion f WHERE f.IdObservacionOrigen=v.IdObservacion);

    SELECT
      (SELECT COUNT(*) FROM dw.DimTiempo) AS DimTiempo,
      (SELECT COUNT(*) FROM dw.DimPersona) AS DimPersona,
      (SELECT COUNT(*) FROM dw.DimUbicacion) AS DimUbicacion,
      (SELECT COUNT(*) FROM dw.DimEducacion) AS DimEducacion,
      (SELECT COUNT(*) FROM dw.DimSituacionLaboral) AS DimSituacionLaboral,
      (SELECT COUNT(*) FROM dw.FactObservacion) AS FactObservacion;
END;
GO

EXEC dw.usp_CargarDW;
GO
