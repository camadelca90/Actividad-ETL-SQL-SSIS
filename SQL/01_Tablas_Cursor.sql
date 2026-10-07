USE PersonasETL;
GO

IF OBJECT_ID('dbo.CursorRechazados', 'U') IS NOT NULL DROP TABLE dbo.CursorRechazados;
IF OBJECT_ID('dbo.CursorValidos', 'U') IS NOT NULL DROP TABLE dbo.CursorValidos;
IF OBJECT_ID('dbo.StgPersonasCursor', 'U') IS NOT NULL DROP TABLE dbo.StgPersonasCursor;
GO

CREATE TABLE dbo.StgPersonasCursor (
    SourceRowId        INT            NOT NULL PRIMARY KEY,
    DocumentType       NVARCHAR(50)   NULL,
    DocumentNumber     NVARCHAR(50)   NULL,
    FirstName          NVARCHAR(100)  NULL,
    MiddleName         NVARCHAR(100)  NULL,
    LastName           NVARCHAR(100)  NULL,
    SecondLastName     NVARCHAR(100)  NULL,
    BirthDate          NVARCHAR(50)   NULL,
    ReportedAge        NVARCHAR(20)   NULL,
    Sex                NVARCHAR(30)   NULL,
    MaritalStatus      NVARCHAR(50)   NULL,
    Email              NVARCHAR(150)  NULL,
    Phone              NVARCHAR(50)   NULL,
    DepartmentCode     NVARCHAR(30)   NULL,
    DepartmentName     NVARCHAR(100)  NULL,
    MunicipalityCode   NVARCHAR(30)   NULL,
    MunicipalityName   NVARCHAR(100)  NULL,
    Zone                NVARCHAR(30)   NULL,
    Address             NVARCHAR(200)  NULL,
    HousingType         NVARCHAR(50)   NULL,
    SocioeconomicStratum NVARCHAR(20) NULL,
    EducationLevel      NVARCHAR(100)  NULL,
    EmploymentStatus    NVARCHAR(100)  NULL,
    OccupationCode      NVARCHAR(30)   NULL,
    OccupationName      NVARCHAR(150)  NULL,
    EmployerName        NVARCHAR(150)  NULL,
    ContractType        NVARCHAR(80)   NULL,
    EmploymentStartDate NVARCHAR(50)  NULL,
    MonthlyIncome       NVARCHAR(80)   NULL,
    MonthlyExpenses     NVARCHAR(80)   NULL,
    Dependents          NVARCHAR(20)   NULL,
    HouseholdSize       NVARCHAR(20)   NULL,
    HealthRegime        NVARCHAR(80)   NULL,
    Disability          NVARCHAR(30)   NULL,
    SurveyDate          NVARCHAR(50)   NULL,
    UpdatedAt           NVARCHAR(50)   NULL,
    SourceChannel       NVARCHAR(50)   NULL,
    FechaCarga          DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.CursorValidos (
    SourceRowId       INT PRIMARY KEY,
    TipoDocumento     NVARCHAR(20) NOT NULL,
    NumeroDocumento   NVARCHAR(50) NOT NULL,
    PrimerNombre      NVARCHAR(100) NOT NULL,
    SegundoNombre     NVARCHAR(100) NULL,
    PrimerApellido    NVARCHAR(100) NOT NULL,
    SegundoApellido   NVARCHAR(100) NULL,
    IngresoMensual    DECIMAL(18,2) NOT NULL,
    GastoMensual      DECIMAL(18,2) NOT NULL,
    BalanceMensual    DECIMAL(18,2) NOT NULL,
    FechaProceso      DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);

CREATE TABLE dbo.CursorRechazados (
    IdRechazo         INT IDENTITY(1,1) PRIMARY KEY,
    SourceRowId       INT NOT NULL,
    MotivoRechazo     NVARCHAR(1000) NOT NULL,
    DocumentTypeOriginal NVARCHAR(50) NULL,
    DocumentNumberOriginal NVARCHAR(50) NULL,
    FirstNameOriginal NVARCHAR(100) NULL,
    LastNameOriginal  NVARCHAR(100) NULL,
    MonthlyIncomeOriginal NVARCHAR(80) NULL,
    MonthlyExpensesOriginal NVARCHAR(80) NULL,
    FechaProceso      DATETIME2(0) NOT NULL DEFAULT SYSDATETIME()
);
GO
