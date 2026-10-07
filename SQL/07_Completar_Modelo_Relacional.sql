USE PersonasETL;
GO

CREATE OR ALTER PROCEDURE etl.usp_ConsolidarModeloRelacional
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @IdEjecucion UNIQUEIDENTIFIER = NEWID();
    INSERT etl.Ejecucion(IdEjecucion, NombrePaquete, Leidos, Estado)
    SELECT @IdEjecucion, N'ETL_Excel_Relacional', COUNT(*), N'EN_PROCESO'
    FROM etl.StgPersonasExcel;

    DROP TABLE IF EXISTS #Base;
    SELECT
        s.SourceRowId,
        UPPER(LTRIM(RTRIM(s.DocumentType))) AS TipoDocumento,
        UPPER(LTRIM(RTRIM(s.DocumentNumber))) AS NumeroDocumento,
        UPPER(LTRIM(RTRIM(s.FirstName))) AS PrimerNombre,
        NULLIF(UPPER(LTRIM(RTRIM(s.MiddleName))),N'') AS SegundoNombre,
        UPPER(LTRIM(RTRIM(s.LastName))) AS PrimerApellido,
        NULLIF(UPPER(LTRIM(RTRIM(s.SecondLastName))),N'') AS SegundoApellido,
        COALESCE(TRY_CONVERT(date,s.BirthDate,103),TRY_CONVERT(date,s.BirthDate,23)) AS FechaNacimiento,
        TRY_CONVERT(smallint,s.ReportedAge) AS EdadReportada,
        UPPER(LTRIM(RTRIM(s.Sex))) AS Sexo,
        UPPER(LTRIM(RTRIM(s.MaritalStatus))) AS EstadoCivil,
        LOWER(LTRIM(RTRIM(s.Email))) AS Correo,
        LTRIM(RTRIM(s.Phone)) AS Telefono,
        UPPER(LTRIM(RTRIM(s.DepartmentCode))) AS CodigoDepartamento,
        UPPER(LTRIM(RTRIM(s.DepartmentName))) AS Departamento,
        UPPER(LTRIM(RTRIM(s.MunicipalityCode))) AS CodigoMunicipio,
        UPPER(LTRIM(RTRIM(s.MunicipalityName))) AS Municipio,
        UPPER(LTRIM(RTRIM(s.Zone))) AS Zona,
        LTRIM(RTRIM(s.Address)) AS Direccion,
        UPPER(LTRIM(RTRIM(s.HousingType))) AS TipoVivienda,
        TRY_CONVERT(tinyint,s.SocioeconomicStratum) AS Estrato,
        UPPER(LTRIM(RTRIM(s.EducationLevel))) AS NivelEducativo,
        UPPER(LTRIM(RTRIM(s.EmploymentStatus))) AS SituacionLaboral,
        NULLIF(UPPER(LTRIM(RTRIM(s.OccupationCode))),N'') AS CodigoOcupacion,
        NULLIF(UPPER(LTRIM(RTRIM(s.OccupationName))),N'') AS Ocupacion,
        NULLIF(LTRIM(RTRIM(s.EmployerName)),N'') AS Empleador,
        NULLIF(UPPER(LTRIM(RTRIM(s.ContractType))),N'') AS TipoContrato,
        COALESCE(TRY_CONVERT(date,s.EmploymentStartDate,103),TRY_CONVERT(date,s.EmploymentStartDate,23)) AS FechaInicioEmpleo,
        TRY_CONVERT(decimal(18,2),
            CASE WHEN CHARINDEX(',',s.MonthlyIncome)>0
                 THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(s.MonthlyIncome),N'COP',N''),N'$',N''),N' ',N''),N'.',N''),N',',N'.')
                 ELSE REPLACE(REPLACE(REPLACE(REPLACE(UPPER(s.MonthlyIncome),N'COP',N''),N'$',N''),N' ',N''),N',',N'') END) AS IngresoMensual,
        TRY_CONVERT(decimal(18,2),
            CASE WHEN CHARINDEX(',',s.MonthlyExpenses)>0
                 THEN REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(UPPER(s.MonthlyExpenses),N'COP',N''),N'$',N''),N' ',N''),N'.',N''),N',',N'.')
                 ELSE REPLACE(REPLACE(REPLACE(REPLACE(UPPER(s.MonthlyExpenses),N'COP',N''),N'$',N''),N' ',N''),N',',N'') END) AS GastoMensual,
        TRY_CONVERT(smallint,s.Dependents) AS PersonasCargo,
        TRY_CONVERT(smallint,s.HouseholdSize) AS TamanoHogar,
        UPPER(LTRIM(RTRIM(s.HealthRegime))) AS RegimenSalud,
        UPPER(LTRIM(RTRIM(s.Disability))) AS Discapacidad,
        COALESCE(TRY_CONVERT(date,s.SurveyDate,103),TRY_CONVERT(date,s.SurveyDate,23)) AS FechaEncuesta,
        COALESCE(TRY_CONVERT(datetime2(0),s.UpdatedAt,120),TRY_CONVERT(datetime2(0),s.UpdatedAt,103)) AS FechaFuente,
        UPPER(LTRIM(RTRIM(s.SourceChannel))) AS CanalOrigen
    INTO #Base
    FROM etl.StgPersonasExcel s;

    INSERT modelo.Departamento(Codigo,Nombre)
    SELECT b.CodigoDepartamento,MAX(b.Departamento) FROM #Base b
    WHERE NULLIF(b.CodigoDepartamento,N'') IS NOT NULL AND NULLIF(b.Departamento,N'') IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM modelo.Departamento x WHERE x.Codigo=b.CodigoDepartamento)
    GROUP BY b.CodigoDepartamento;

    INSERT modelo.Municipio(IdDepartamento,Codigo,Nombre)
    SELECT d.IdDepartamento,b.CodigoMunicipio,MAX(b.Municipio)
    FROM #Base b JOIN modelo.Departamento d ON d.Codigo=b.CodigoDepartamento
    WHERE NULLIF(b.CodigoMunicipio,N'') IS NOT NULL AND NULLIF(b.Municipio,N'') IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM modelo.Municipio x
                      WHERE x.IdDepartamento=d.IdDepartamento AND x.Codigo=b.CodigoMunicipio)
    GROUP BY d.IdDepartamento,b.CodigoMunicipio;

    INSERT modelo.NivelEducativo(Nombre)
    SELECT DISTINCT b.NivelEducativo FROM #Base b
    WHERE NULLIF(b.NivelEducativo,N'') IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM modelo.NivelEducativo x WHERE x.Nombre=b.NivelEducativo);

    INSERT modelo.SituacionLaboral(Nombre)
    SELECT DISTINCT b.SituacionLaboral FROM #Base b
    WHERE NULLIF(b.SituacionLaboral,N'') IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM modelo.SituacionLaboral x WHERE x.Nombre=b.SituacionLaboral);

    INSERT modelo.Ocupacion(Codigo,Nombre)
    SELECT b.CodigoOcupacion,MAX(b.Ocupacion) FROM #Base b
    WHERE b.CodigoOcupacion IS NOT NULL AND b.Ocupacion IS NOT NULL
      AND NOT EXISTS (SELECT 1 FROM modelo.Ocupacion x WHERE x.Codigo=b.CodigoOcupacion)
    GROUP BY b.CodigoOcupacion;

    INSERT modelo.Persona(TipoDocumento,NumeroDocumento,PrimerNombre,SegundoNombre,PrimerApellido,SegundoApellido,
                          FechaNacimiento,Sexo,EstadoCivil,Correo,Telefono,Direccion)
    SELECT TipoDocumento,NumeroDocumento,PrimerNombre,SegundoNombre,PrimerApellido,SegundoApellido,
           FechaNacimiento,Sexo,EstadoCivil,Correo,Telefono,Direccion
    FROM (
        SELECT b.*,ROW_NUMBER() OVER(PARTITION BY TipoDocumento,NumeroDocumento
                                    ORDER BY FechaFuente DESC,SourceRowId DESC) rn
        FROM #Base b
        WHERE NULLIF(TipoDocumento,N'') IS NOT NULL AND NULLIF(NumeroDocumento,N'') IS NOT NULL
          AND NULLIF(PrimerNombre,N'') IS NOT NULL AND NULLIF(PrimerApellido,N'') IS NOT NULL
          AND FechaNacimiento IS NOT NULL
    ) x
    WHERE rn=1 AND NOT EXISTS (
        SELECT 1 FROM modelo.Persona p
        WHERE p.TipoDocumento=x.TipoDocumento AND p.NumeroDocumento=x.NumeroDocumento);

    DROP TABLE IF EXISTS #Evaluada;
    SELECT b.*,p.IdPersona,m.IdMunicipio,ne.IdNivelEducativo,sl.IdSituacionLaboral,
           CASE
             WHEN NULLIF(b.TipoDocumento,N'') IS NULL OR NULLIF(b.NumeroDocumento,N'') IS NULL THEN N'Documento faltante'
             WHEN NULLIF(b.PrimerNombre,N'') IS NULL OR NULLIF(b.PrimerApellido,N'') IS NULL THEN N'Nombre o apellido obligatorio faltante'
             WHEN b.FechaNacimiento IS NULL OR b.FechaEncuesta IS NULL THEN N'Fecha inválida o faltante'
             WHEN b.FechaEncuesta < b.FechaNacimiento THEN N'Encuesta anterior al nacimiento'
             WHEN b.EdadReportada IS NOT NULL AND ABS(b.EdadReportada-DATEDIFF(YEAR,b.FechaNacimiento,b.FechaEncuesta))>1 THEN N'Edad inconsistente con nacimiento y encuesta'
             WHEN b.IngresoMensual IS NULL OR b.GastoMensual IS NULL THEN N'Ingreso o gasto faltante/no numérico'
             WHEN b.IngresoMensual<0 OR b.GastoMensual<0 THEN N'Ingreso o gasto negativo'
             WHEN b.PersonasCargo IS NULL OR b.TamanoHogar IS NULL OR b.PersonasCargo<0 OR b.TamanoHogar<=0 THEN N'Datos del hogar inválidos'
             WHEN b.PersonasCargo>=b.TamanoHogar THEN N'Personas a cargo incompatibles con tamaño del hogar'
             WHEN p.IdPersona IS NULL THEN N'Persona no disponible'
             WHEN m.IdMunicipio IS NULL THEN N'Municipio y departamento inconsistentes'
             WHEN ne.IdNivelEducativo IS NULL OR sl.IdSituacionLaboral IS NULL THEN N'Categoría no reconocida'
             WHEN b.SituacionLaboral IN(N'EMPLEADO',N'INDEPENDIENTE') AND b.FechaInicioEmpleo>b.FechaEncuesta THEN N'Inicio laboral posterior a encuesta'
             ELSE NULL END AS MotivoRechazo,
           ROW_NUMBER() OVER(PARTITION BY p.IdPersona,b.FechaEncuesta ORDER BY b.FechaFuente DESC,b.SourceRowId DESC) AS rnObservacion
    INTO #Evaluada
    FROM #Base b
    LEFT JOIN modelo.Persona p ON p.TipoDocumento=b.TipoDocumento AND p.NumeroDocumento=b.NumeroDocumento
    LEFT JOIN modelo.Departamento d ON d.Codigo=b.CodigoDepartamento
    LEFT JOIN modelo.Municipio m ON m.IdDepartamento=d.IdDepartamento AND m.Codigo=b.CodigoMunicipio
    LEFT JOIN modelo.NivelEducativo ne ON ne.Nombre=b.NivelEducativo
    LEFT JOIN modelo.SituacionLaboral sl ON sl.Nombre=b.SituacionLaboral;

    INSERT etl.Incidencia(IdEjecucion,SourceRowId,Clasificacion,Campo,ValorOriginal,ValorTratado,Motivo)
    SELECT @IdEjecucion,SourceRowId,N'RECHAZO',NULL,NULL,NULL,MotivoRechazo
    FROM #Evaluada WHERE MotivoRechazo IS NOT NULL;

    INSERT etl.Incidencia(IdEjecucion,SourceRowId,Clasificacion,Campo,ValorOriginal,ValorTratado,Motivo)
    SELECT @IdEjecucion,SourceRowId,N'DUPLICADO',N'PersonaFechaEncuesta',NULL,NULL,
           N'Se conservó la versión con UpdatedAt más reciente; en empate, el mayor SourceRowId.'
    FROM #Evaluada WHERE MotivoRechazo IS NULL AND rnObservacion>1;

    INSERT modelo.Observacion(IdPersona,FechaEncuesta,IdMunicipio,IdNivelEducativo,IdSituacionLaboral,
                              EdadReportada,Zona,TipoVivienda,Estrato,IngresoMensual,GastoMensual,
                              PersonasCargo,TamanoHogar,RegimenSalud,Discapacidad,CanalOrigen,SourceRowId,FechaFuente)
    SELECT e.IdPersona,e.FechaEncuesta,e.IdMunicipio,e.IdNivelEducativo,e.IdSituacionLaboral,
           e.EdadReportada,e.Zona,e.TipoVivienda,e.Estrato,e.IngresoMensual,e.GastoMensual,
           e.PersonasCargo,e.TamanoHogar,e.RegimenSalud,e.Discapacidad,e.CanalOrigen,e.SourceRowId,e.FechaFuente
    FROM #Evaluada e
    WHERE e.MotivoRechazo IS NULL AND e.rnObservacion=1
      AND NOT EXISTS (SELECT 1 FROM modelo.Observacion o
                      WHERE o.IdPersona=e.IdPersona AND o.FechaEncuesta=e.FechaEncuesta);

    INSERT modelo.InformacionLaboral(IdObservacion,IdOcupacion,Empleador,TipoContrato,FechaInicioEmpleo)
    SELECT o.IdObservacion,oc.IdOcupacion,e.Empleador,e.TipoContrato,e.FechaInicioEmpleo
    FROM #Evaluada e
    JOIN modelo.Observacion o ON o.IdPersona=e.IdPersona AND o.FechaEncuesta=e.FechaEncuesta
    LEFT JOIN modelo.Ocupacion oc ON oc.Codigo=e.CodigoOcupacion
    WHERE e.MotivoRechazo IS NULL AND e.rnObservacion=1
      AND (e.CodigoOcupacion IS NOT NULL OR e.Empleador IS NOT NULL OR e.TipoContrato IS NOT NULL OR e.FechaInicioEmpleo IS NOT NULL)
      AND NOT EXISTS (SELECT 1 FROM modelo.InformacionLaboral il WHERE il.IdObservacion=o.IdObservacion);

    UPDATE etl.Ejecucion
    SET FechaFin=SYSDATETIME(),
        Aceptados=(SELECT COUNT(*) FROM #Evaluada WHERE MotivoRechazo IS NULL AND rnObservacion=1),
        Rechazados=(SELECT COUNT(*) FROM #Evaluada WHERE MotivoRechazo IS NOT NULL),
        Duplicados=(SELECT COUNT(*) FROM #Evaluada WHERE MotivoRechazo IS NULL AND rnObservacion>1),
        Estado=N'CORRECTO'
    WHERE IdEjecucion=@IdEjecucion;

    SELECT * FROM etl.Ejecucion WHERE IdEjecucion=@IdEjecucion;
END;
GO

EXEC etl.usp_ConsolidarModeloRelacional;
GO
