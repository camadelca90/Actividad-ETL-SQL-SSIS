# Correspondencia Excel a modelo relacional

| Columna Excel | Tabla destino | Atributo destino |
|---|---|---|
| SourceRowId | modelo.Observacion | SourceRowId |
| DocumentType | modelo.Persona | TipoDocumento |
| DocumentNumber | modelo.Persona | NumeroDocumento |
| FirstName | modelo.Persona | PrimerNombre |
| MiddleName | modelo.Persona | SegundoNombre |
| LastName | modelo.Persona | PrimerApellido |
| SecondLastName | modelo.Persona | SegundoApellido |
| BirthDate | modelo.Persona | FechaNacimiento |
| ReportedAge | modelo.Observacion | EdadReportada |
| Sex | modelo.Persona | Sexo |
| MaritalStatus | modelo.Persona | EstadoCivil |
| Email | modelo.Persona | Correo |
| Phone | modelo.Persona | Telefono |
| DepartmentCode | modelo.Departamento | Codigo |
| DepartmentName | modelo.Departamento | Nombre |
| MunicipalityCode | modelo.Municipio | Codigo |
| MunicipalityName | modelo.Municipio | Nombre |
| Zone | modelo.Observacion | Zona |
| Address | modelo.Persona | Direccion |
| HousingType | modelo.Observacion | TipoVivienda |
| SocioeconomicStratum | modelo.Observacion | Estrato |
| EducationLevel | modelo.NivelEducativo | Nombre |
| EmploymentStatus | modelo.SituacionLaboral | Nombre |
| OccupationCode | modelo.Ocupacion | Codigo |
| OccupationName | modelo.Ocupacion | Nombre |
| EmployerName | modelo.InformacionLaboral | Empleador |
| ContractType | modelo.InformacionLaboral | TipoContrato |
| EmploymentStartDate | modelo.InformacionLaboral | FechaInicioEmpleo |
| MonthlyIncome | modelo.Observacion | IngresoMensual |
| MonthlyExpenses | modelo.Observacion | GastoMensual |
| Calculado | modelo.Observacion | BalanceMensual |
| Dependents | modelo.Observacion | PersonasCargo |
| HouseholdSize | modelo.Observacion | TamanoHogar |
| HealthRegime | modelo.Observacion | RegimenSalud |
| Disability | modelo.Observacion | Discapacidad |
| SurveyDate | modelo.Observacion | FechaEncuesta |
| UpdatedAt | modelo.Observacion | FechaFuente |
| SourceChannel | modelo.Observacion | CanalOrigen |
