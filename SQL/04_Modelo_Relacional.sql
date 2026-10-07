USE PersonasETL;
GO

IF SCHEMA_ID('etl') IS NULL EXEC('CREATE SCHEMA etl');
IF SCHEMA_ID('modelo') IS NULL EXEC('CREATE SCHEMA modelo');
GO

CREATE TABLE etl.StgPersonasExcel (
    SourceRowId INT NOT NULL PRIMARY KEY,
    DocumentType NVARCHAR(50) NULL, DocumentNumber NVARCHAR(50) NULL,
    FirstName NVARCHAR(100) NULL, MiddleName NVARCHAR(100) NULL,
    LastName NVARCHAR(100) NULL, SecondLastName NVARCHAR(100) NULL,
    BirthDate NVARCHAR(50) NULL, ReportedAge NVARCHAR(20) NULL,
    Sex NVARCHAR(30) NULL, MaritalStatus NVARCHAR(50) NULL,
    Email NVARCHAR(150) NULL, Phone NVARCHAR(50) NULL,
    DepartmentCode NVARCHAR(30) NULL, DepartmentName NVARCHAR(100) NULL,
    MunicipalityCode NVARCHAR(30) NULL, MunicipalityName NVARCHAR(100) NULL,
    Zone NVARCHAR(30) NULL, Address NVARCHAR(200) NULL,
    HousingType NVARCHAR(50) NULL, SocioeconomicStratum NVARCHAR(20) NULL,
    EducationLevel NVARCHAR(100) NULL, EmploymentStatus NVARCHAR(100) NULL,
    OccupationCode NVARCHAR(30) NULL, OccupationName NVARCHAR(150) NULL,
    EmployerName NVARCHAR(150) NULL, ContractType NVARCHAR(80) NULL,
    EmploymentStartDate NVARCHAR(50) NULL, MonthlyIncome NVARCHAR(80) NULL,
    MonthlyExpenses NVARCHAR(80) NULL, Dependents NVARCHAR(20) NULL,
    HouseholdSize NVARCHAR(20) NULL, HealthRegime NVARCHAR(80) NULL,
    Disability NVARCHAR(30) NULL, SurveyDate NVARCHAR(50) NULL,
    UpdatedAt NVARCHAR(50) NULL, SourceChannel NVARCHAR(50) NULL,
    IdEjecucion UNIQUEIDENTIFIER NOT NULL,
    FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE etl.Ejecucion (
    IdEjecucion UNIQUEIDENTIFIER PRIMARY KEY,
    NombrePaquete NVARCHAR(150) NOT NULL,
    FechaInicio DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    FechaFin DATETIME2(0) NULL,
    Leidos INT NOT NULL DEFAULT 0,
    Aceptados INT NOT NULL DEFAULT 0,
    Revision INT NOT NULL DEFAULT 0,
    Rechazados INT NOT NULL DEFAULT 0,
    Duplicados INT NOT NULL DEFAULT 0,
    Estado NVARCHAR(30) NOT NULL DEFAULT N'EN_PROCESO'
);

CREATE TABLE etl.Incidencia (
    IdIncidencia BIGINT IDENTITY PRIMARY KEY,
    IdEjecucion UNIQUEIDENTIFIER NOT NULL,
    SourceRowId INT NOT NULL,
    Clasificacion NVARCHAR(20) NOT NULL CHECK (Clasificacion IN (N'CORRECCION',N'REVISION',N'RECHAZO',N'DUPLICADO')),
    Campo NVARCHAR(100) NULL,
    ValorOriginal NVARCHAR(4000) NULL,
    ValorTratado NVARCHAR(4000) NULL,
    Motivo NVARCHAR(1000) NOT NULL,
    FechaRegistro DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Incidencia_Ejecucion FOREIGN KEY (IdEjecucion) REFERENCES etl.Ejecucion(IdEjecucion)
);

CREATE TABLE modelo.Departamento (
    IdDepartamento INT IDENTITY PRIMARY KEY,
    Codigo NVARCHAR(30) NOT NULL UNIQUE,
    Nombre NVARCHAR(100) NOT NULL
);

CREATE TABLE modelo.Municipio (
    IdMunicipio INT IDENTITY PRIMARY KEY,
    IdDepartamento INT NOT NULL,
    Codigo NVARCHAR(30) NOT NULL,
    Nombre NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_Municipio UNIQUE (IdDepartamento, Codigo),
    CONSTRAINT FK_Municipio_Departamento FOREIGN KEY (IdDepartamento) REFERENCES modelo.Departamento(IdDepartamento)
);

CREATE TABLE modelo.NivelEducativo (
    IdNivelEducativo SMALLINT IDENTITY PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE modelo.SituacionLaboral (
    IdSituacionLaboral SMALLINT IDENTITY PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE modelo.Ocupacion (
    IdOcupacion INT IDENTITY PRIMARY KEY,
    Codigo NVARCHAR(30) NOT NULL UNIQUE,
    Nombre NVARCHAR(150) NOT NULL
);

CREATE TABLE modelo.Persona (
    IdPersona BIGINT IDENTITY PRIMARY KEY,
    TipoDocumento NVARCHAR(20) NOT NULL,
    NumeroDocumento NVARCHAR(50) NOT NULL,
    PrimerNombre NVARCHAR(100) NOT NULL,
    SegundoNombre NVARCHAR(100) NULL,
    PrimerApellido NVARCHAR(100) NOT NULL,
    SegundoApellido NVARCHAR(100) NULL,
    FechaNacimiento DATE NOT NULL,
    Sexo NVARCHAR(30) NULL,
    EstadoCivil NVARCHAR(50) NULL,
    Correo NVARCHAR(150) NULL,
    Telefono NVARCHAR(50) NULL,
    Direccion NVARCHAR(200) NULL,
    FechaCreacion DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    FechaActualizacion DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Persona_Documento UNIQUE (TipoDocumento, NumeroDocumento)
);

CREATE TABLE modelo.Observacion (
    IdObservacion BIGINT IDENTITY PRIMARY KEY,
    IdPersona BIGINT NOT NULL,
    FechaEncuesta DATE NOT NULL,
    IdMunicipio INT NOT NULL,
    IdNivelEducativo SMALLINT NOT NULL,
    IdSituacionLaboral SMALLINT NOT NULL,
    EdadReportada SMALLINT NULL,
    Zona NVARCHAR(30) NULL,
    TipoVivienda NVARCHAR(50) NULL,
    Estrato TINYINT NULL,
    IngresoMensual DECIMAL(18,2) NOT NULL,
    GastoMensual DECIMAL(18,2) NOT NULL,
    BalanceMensual AS (IngresoMensual-GastoMensual) PERSISTED,
    PersonasCargo SMALLINT NULL,
    TamanoHogar SMALLINT NULL,
    RegimenSalud NVARCHAR(80) NULL,
    Discapacidad NVARCHAR(30) NULL,
    CanalOrigen NVARCHAR(50) NULL,
    SourceRowId INT NOT NULL,
    FechaFuente DATETIME2(0) NULL,
    FechaCreacion DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Observacion UNIQUE (IdPersona, FechaEncuesta),
    CONSTRAINT FK_Observacion_Persona FOREIGN KEY (IdPersona) REFERENCES modelo.Persona(IdPersona),
    CONSTRAINT FK_Observacion_Municipio FOREIGN KEY (IdMunicipio) REFERENCES modelo.Municipio(IdMunicipio),
    CONSTRAINT FK_Observacion_Educacion FOREIGN KEY (IdNivelEducativo) REFERENCES modelo.NivelEducativo(IdNivelEducativo),
    CONSTRAINT FK_Observacion_Laboral FOREIGN KEY (IdSituacionLaboral) REFERENCES modelo.SituacionLaboral(IdSituacionLaboral),
    CONSTRAINT CK_Observacion_Importes CHECK (IngresoMensual >= 0 AND GastoMensual >= 0),
    CONSTRAINT CK_Observacion_Hogar CHECK (PersonasCargo IS NULL OR TamanoHogar IS NULL OR PersonasCargo < TamanoHogar)
);

CREATE TABLE modelo.InformacionLaboral (
    IdObservacion BIGINT PRIMARY KEY,
    IdOcupacion INT NULL,
    Empleador NVARCHAR(150) NULL,
    TipoContrato NVARCHAR(80) NULL,
    FechaInicioEmpleo DATE NULL,
    CONSTRAINT FK_InfoLaboral_Observacion FOREIGN KEY (IdObservacion) REFERENCES modelo.Observacion(IdObservacion),
    CONSTRAINT FK_InfoLaboral_Ocupacion FOREIGN KEY (IdOcupacion) REFERENCES modelo.Ocupacion(IdOcupacion)
);
GO

CREATE OR ALTER VIEW modelo.vw_DatosDepuradosDW
AS
SELECT o.IdObservacion, p.IdPersona, p.TipoDocumento, p.NumeroDocumento,
       p.FechaNacimiento, o.FechaEncuesta,
       d.Codigo AS CodigoDepartamento, d.Nombre AS Departamento,
       m.Codigo AS CodigoMunicipio, m.Nombre AS Municipio,
       ne.Nombre AS NivelEducativo, sl.Nombre AS SituacionLaboral,
       o.IngresoMensual, o.GastoMensual, o.BalanceMensual,
       o.SourceRowId
FROM modelo.Observacion o
JOIN modelo.Persona p ON p.IdPersona = o.IdPersona
JOIN modelo.Municipio m ON m.IdMunicipio = o.IdMunicipio
JOIN modelo.Departamento d ON d.IdDepartamento = m.IdDepartamento
JOIN modelo.NivelEducativo ne ON ne.IdNivelEducativo = o.IdNivelEducativo
JOIN modelo.SituacionLaboral sl ON sl.IdSituacionLaboral = o.IdSituacionLaboral;
GO
