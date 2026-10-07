USE PersonasDW;
GO

IF SCHEMA_ID('dw') IS NULL EXEC('CREATE SCHEMA dw');
GO

CREATE TABLE dw.DimTiempo (
    TiempoKey INT NOT NULL PRIMARY KEY,
    Fecha DATE NOT NULL UNIQUE,
    Anio SMALLINT NOT NULL,
    Mes TINYINT NOT NULL,
    NombreMes NVARCHAR(20) NOT NULL,
    Trimestre TINYINT NOT NULL
);

CREATE TABLE dw.DimPersona (
    PersonaKey INT IDENTITY PRIMARY KEY,
    IdPersonaOrigen BIGINT NOT NULL UNIQUE,
    TipoDocumento NVARCHAR(20) NOT NULL,
    NumeroDocumento NVARCHAR(50) NOT NULL,
    FechaNacimiento DATE NOT NULL
);

CREATE TABLE dw.DimUbicacion (
    UbicacionKey INT IDENTITY PRIMARY KEY,
    CodigoDepartamento NVARCHAR(30) NOT NULL,
    Departamento NVARCHAR(100) NOT NULL,
    CodigoMunicipio NVARCHAR(30) NOT NULL,
    Municipio NVARCHAR(100) NOT NULL,
    CONSTRAINT UQ_DimUbicacion UNIQUE (CodigoDepartamento, CodigoMunicipio)
);

CREATE TABLE dw.DimEducacion (
    EducacionKey SMALLINT IDENTITY PRIMARY KEY,
    NivelEducativo NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dw.DimSituacionLaboral (
    SituacionLaboralKey SMALLINT IDENTITY PRIMARY KEY,
    SituacionLaboral NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dw.FactObservacion (
    ObservacionKey BIGINT IDENTITY PRIMARY KEY,
    IdObservacionOrigen BIGINT NOT NULL UNIQUE,
    PersonaKey INT NOT NULL,
    TiempoKey INT NOT NULL,
    UbicacionKey INT NOT NULL,
    EducacionKey SMALLINT NOT NULL,
    SituacionLaboralKey SMALLINT NOT NULL,
    IngresoMensual DECIMAL(18,2) NOT NULL,
    GastoMensual DECIMAL(18,2) NOT NULL,
    BalanceMensual DECIMAL(18,2) NOT NULL,
    CantidadObservaciones INT NOT NULL DEFAULT 1,
    FechaCarga DATETIME2(0) NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT UQ_Fact_Grano UNIQUE (PersonaKey, TiempoKey),
    CONSTRAINT FK_Fact_Persona FOREIGN KEY (PersonaKey) REFERENCES dw.DimPersona(PersonaKey),
    CONSTRAINT FK_Fact_Tiempo FOREIGN KEY (TiempoKey) REFERENCES dw.DimTiempo(TiempoKey),
    CONSTRAINT FK_Fact_Ubicacion FOREIGN KEY (UbicacionKey) REFERENCES dw.DimUbicacion(UbicacionKey),
    CONSTRAINT FK_Fact_Educacion FOREIGN KEY (EducacionKey) REFERENCES dw.DimEducacion(EducacionKey),
    CONSTRAINT FK_Fact_Laboral FOREIGN KEY (SituacionLaboralKey) REFERENCES dw.DimSituacionLaboral(SituacionLaboralKey)
);
GO
