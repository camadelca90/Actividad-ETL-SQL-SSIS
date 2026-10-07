USE PersonasETL;
GO

CREATE OR ALTER PROCEDURE dbo.usp_ProcesarCursorPersonas
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM dbo.CursorValidos;
    DELETE FROM dbo.CursorRechazados;

    DECLARE
        @SourceRowId INT,
        @DocumentType NVARCHAR(50), @DocumentNumber NVARCHAR(50),
        @FirstName NVARCHAR(100), @MiddleName NVARCHAR(100),
        @LastName NVARCHAR(100), @SecondLastName NVARCHAR(100),
        @MonthlyIncome NVARCHAR(80), @MonthlyExpenses NVARCHAR(80),
        @TipoDocumento NVARCHAR(20), @NumeroDocumento NVARCHAR(50),
        @PrimerNombre NVARCHAR(100), @SegundoNombre NVARCHAR(100),
        @PrimerApellido NVARCHAR(100), @SegundoApellido NVARCHAR(100),
        @IngresoTexto NVARCHAR(80), @GastoTexto NVARCHAR(80),
        @Ingreso DECIMAL(18,2), @Gasto DECIMAL(18,2),
        @Motivo NVARCHAR(1000);

    -- Declaración del cursor sobre los 100 registros solicitados.
    DECLARE cur_personas CURSOR LOCAL FAST_FORWARD FOR
        SELECT SourceRowId, DocumentType, DocumentNumber,
               FirstName, MiddleName, LastName, SecondLastName,
               MonthlyIncome, MonthlyExpenses
        FROM dbo.StgPersonasCursor
        WHERE SourceRowId BETWEEN 1 AND 100
        ORDER BY SourceRowId;

    -- Apertura del cursor.
    OPEN cur_personas;

    -- Primera lectura.
    FETCH NEXT FROM cur_personas INTO
        @SourceRowId, @DocumentType, @DocumentNumber,
        @FirstName, @MiddleName, @LastName, @SecondLastName,
        @MonthlyIncome, @MonthlyExpenses;

    -- Recorrido registro por registro.
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Motivo = N'';

        SET @TipoDocumento = UPPER(LTRIM(RTRIM(@DocumentType)));
        SET @TipoDocumento = CASE
            WHEN @TipoDocumento IN (N'CC', N'C.C.', N'CEDULA', N'CÉDULA') THEN N'CC'
            WHEN @TipoDocumento IN (N'TI', N'T.I.', N'TARJETA DE IDENTIDAD') THEN N'TI'
            WHEN @TipoDocumento IN (N'CE', N'C.E.', N'CEDULA EXTRANJERIA', N'CÉDULA EXTRANJERÍA') THEN N'CE'
            WHEN @TipoDocumento IN (N'PA', N'PASAPORTE') THEN N'PA'
            ELSE @TipoDocumento END;

        SET @NumeroDocumento = NULLIF(LTRIM(RTRIM(@DocumentNumber)), N'');
        IF UPPER(ISNULL(@NumeroDocumento, N'')) IN (N'SIN-DATO', N'SIN DATO', N'NULL', N'N/A')
            SET @NumeroDocumento = NULL;

        SET @PrimerNombre = NULLIF(LTRIM(RTRIM(@FirstName)), N'');
        SET @SegundoNombre = NULLIF(LTRIM(RTRIM(@MiddleName)), N'');
        SET @PrimerApellido = NULLIF(LTRIM(RTRIM(@LastName)), N'');
        SET @SegundoApellido = NULLIF(LTRIM(RTRIM(@SecondLastName)), N'');

        -- Estandarización sencilla de escritura: primera letra mayúscula y resto minúscula.
        IF @PrimerNombre IS NOT NULL SET @PrimerNombre = UPPER(LEFT(@PrimerNombre,1)) + LOWER(SUBSTRING(@PrimerNombre,2,100));
        IF @SegundoNombre IS NOT NULL SET @SegundoNombre = UPPER(LEFT(@SegundoNombre,1)) + LOWER(SUBSTRING(@SegundoNombre,2,100));
        IF @PrimerApellido IS NOT NULL SET @PrimerApellido = UPPER(LEFT(@PrimerApellido,1)) + LOWER(SUBSTRING(@PrimerApellido,2,100));
        IF @SegundoApellido IS NOT NULL SET @SegundoApellido = UPPER(LEFT(@SegundoApellido,1)) + LOWER(SUBSTRING(@SegundoApellido,2,100));

        IF @NumeroDocumento IS NULL SET @Motivo += N'Documento faltante; ';
        IF @PrimerNombre IS NULL SET @Motivo += N'Primer nombre faltante; ';
        IF @PrimerApellido IS NULL SET @Motivo += N'Primer apellido faltante; ';

        SET @IngresoTexto = UPPER(LTRIM(RTRIM(ISNULL(@MonthlyIncome, N''))));
        SET @GastoTexto = UPPER(LTRIM(RTRIM(ISNULL(@MonthlyExpenses, N''))));
        SET @IngresoTexto = REPLACE(REPLACE(REPLACE(REPLACE(@IngresoTexto, N'COP', N''), N'$', N''), N' ', N''), NCHAR(160), N'');
        SET @GastoTexto = REPLACE(REPLACE(REPLACE(REPLACE(@GastoTexto, N'COP', N''), N'$', N''), N' ', N''), NCHAR(160), N'');

        -- Punto = miles y coma = decimal, según las reglas del dataset.
        SET @IngresoTexto = REPLACE(REPLACE(@IngresoTexto, N'.', N''), N',', N'.');
        SET @GastoTexto = REPLACE(REPLACE(@GastoTexto, N'.', N''), N',', N'.');
        SET @Ingreso = TRY_CONVERT(DECIMAL(18,2), NULLIF(@IngresoTexto, N''));
        SET @Gasto = TRY_CONVERT(DECIMAL(18,2), NULLIF(@GastoTexto, N''));

        IF NULLIF(@IngresoTexto, N'') IS NULL SET @Motivo += N'Ingreso mensual faltante; ';
        ELSE IF @Ingreso IS NULL SET @Motivo += N'Ingreso mensual no numérico; ';
        ELSE IF @Ingreso < 0 SET @Motivo += N'Ingreso mensual negativo; ';

        IF NULLIF(@GastoTexto, N'') IS NULL SET @Motivo += N'Gasto mensual faltante; ';
        ELSE IF @Gasto IS NULL SET @Motivo += N'Gasto mensual no numérico; ';
        ELSE IF @Gasto < 0 SET @Motivo += N'Gasto mensual negativo; ';

        IF @Motivo = N''
        BEGIN
            INSERT dbo.CursorValidos
                (SourceRowId, TipoDocumento, NumeroDocumento, PrimerNombre,
                 SegundoNombre, PrimerApellido, SegundoApellido,
                 IngresoMensual, GastoMensual, BalanceMensual)
            VALUES
                (@SourceRowId, @TipoDocumento, @NumeroDocumento, @PrimerNombre,
                 @SegundoNombre, @PrimerApellido, @SegundoApellido,
                 @Ingreso, @Gasto, @Ingreso - @Gasto);
        END
        ELSE
        BEGIN
            INSERT dbo.CursorRechazados
                (SourceRowId, MotivoRechazo, DocumentTypeOriginal,
                 DocumentNumberOriginal, FirstNameOriginal, LastNameOriginal,
                 MonthlyIncomeOriginal, MonthlyExpensesOriginal)
            VALUES
                (@SourceRowId, LEFT(@Motivo, LEN(@Motivo)-1), @DocumentType,
                 @DocumentNumber, @FirstName, @LastName,
                 @MonthlyIncome, @MonthlyExpenses);
        END;

        -- Lectura siguiente.
        FETCH NEXT FROM cur_personas INTO
            @SourceRowId, @DocumentType, @DocumentNumber,
            @FirstName, @MiddleName, @LastName, @SecondLastName,
            @MonthlyIncome, @MonthlyExpenses;
    END;

    -- Cierre y liberación del cursor.
    CLOSE cur_personas;
    DEALLOCATE cur_personas;

    SELECT
        (SELECT COUNT(*) FROM dbo.StgPersonasCursor WHERE SourceRowId BETWEEN 1 AND 100) AS Procesados,
        (SELECT COUNT(*) FROM dbo.CursorValidos) AS Aceptados,
        (SELECT COUNT(*) FROM dbo.CursorRechazados) AS Rechazados,
        (SELECT COUNT(*) FROM dbo.CursorValidos WHERE BalanceMensual < 0) AS BalancesNegativosValidos;

    SELECT TOP (20) * FROM dbo.CursorValidos ORDER BY SourceRowId;
    SELECT * FROM dbo.CursorRechazados ORDER BY SourceRowId;
END;
GO

EXEC dbo.usp_ProcesarCursorPersonas;
GO
