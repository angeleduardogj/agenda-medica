-- Agendar cita
CREATE OR ALTER PROCEDURE dbo.sp_trx_citas_agendar
    @medico_id INT,
    @paciente_id INT,
    @fecha DATE,
    @hora_inicio TIME(0),
    @motivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    SET DATEFIRST 1;

    DECLARE @duracion_minutos INT;
    DECLARE @fecha_hora_inicio DATETIME2;
    DECLARE @fecha_hora_fin DATETIME2;
    DECLARE @dia_semana INT;
    DECLARE @hora_consulta_inicio TIME(0);
    DECLARE @hora_consulta_fin TIME(0);
    DECLARE @cancelaciones_30_dias INT;
    DECLARE @alerta_cancelaciones BIT;
    DECLARE @especialidad_nombre NVARCHAR(100);

    SELECT
        @duracion_minutos = e.duracion_minutos,
        @especialidad_nombre = e.nombre
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.id = @medico_id
      AND m.activo = 1;

    IF @duracion_minutos IS NULL
    BEGIN
        RAISERROR('El médico no existe o está inactivo.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.mst_pacientes WHERE id = @paciente_id AND activo = 1)
    BEGIN
        RAISERROR('El paciente no existe o está inactivo.', 16, 1);
        RETURN;
    END

    -- Regla 2: Duración por especialidad
    SET @fecha_hora_inicio = DATEADD(SECOND, DATEDIFF(SECOND, CAST('00:00:00' AS TIME), @hora_inicio), CAST(@fecha AS DATETIME2));
    SET @fecha_hora_fin = DATEADD(MINUTE, @duracion_minutos, @fecha_hora_inicio);

    -- Regla 4: Sin citas en el pasado
    IF @fecha_hora_inicio <= SYSDATETIME()
    BEGIN
        RAISERROR('No se pueden agendar citas en fechas u horas pasadas.', 16, 1);
        RETURN;
    END

    -- Regla 3: Respetar horario del médico
    SET @dia_semana = DATEPART(WEEKDAY, @fecha);

    SELECT
        @hora_consulta_inicio = h.hora_inicio,
        @hora_consulta_fin = h.hora_fin
    FROM dbo.mst_horarios_medico h
    WHERE h.medico = @medico_id
      AND h.dia_semana = @dia_semana;

    IF @hora_consulta_inicio IS NULL OR @hora_consulta_fin IS NULL
    BEGIN
        RAISERROR('El médico no tiene horario de consulta configurado para ese día.', 16, 1);
        RETURN;
    END

    IF @hora_inicio < @hora_consulta_inicio OR CAST(@fecha_hora_fin AS TIME) > @hora_consulta_fin
    BEGIN
        RAISERROR('La cita solicitada está fuera del horario de consulta del médico.', 16, 1);
        RETURN;
    END

    -- Regla 1: Sin citas simultáneas del mismo médico
    IF EXISTS (
        SELECT 1
        FROM dbo.trx_citas c
        WHERE c.medico = @medico_id
          AND c.estado = 'Programada'
          AND c.fecha_hora_inicio < @fecha_hora_fin
          AND c.fecha_hora_fin > @fecha_hora_inicio
    )
    BEGIN
        RAISERROR('El médico ya tiene una cita en ese horario. Use sp_trx_citas_sugerir_horarios para ver opciones disponibles.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.trx_citas (medico, paciente, fecha_hora_inicio, fecha_hora_fin, motivo, estado)
    VALUES (@medico_id, @paciente_id, @fecha_hora_inicio, @fecha_hora_fin, @motivo, 'Programada');

    -- Regla 5: Alerta de cancelaciones (no bloquea)
    SELECT @cancelaciones_30_dias = COUNT(1)
    FROM dbo.trx_citas c
    WHERE c.paciente = @paciente_id
      AND c.estado = 'Cancelada'
      AND c.fecha_cancelacion >= DATEADD(DAY, -30, SYSDATETIME());

    SET @alerta_cancelaciones = CASE WHEN @cancelaciones_30_dias >= 3 THEN 1 ELSE 0 END;

    SELECT
        c.id AS Id,
        c.medico AS MedicoId,
        c.paciente AS PacienteId,
        c.fecha_hora_inicio AS FechaHoraInicio,
        c.fecha_hora_fin AS FechaHoraFin,
        c.motivo AS Motivo,
        c.estado AS Estado,
        c.motivo_cancelacion AS MotivoCancelacion,
        c.fecha_cancelacion AS FechaCancelacion,
        c.fecha_creacion AS FechaCreacion,
        @especialidad_nombre AS EspecialidadNombre,
        @duracion_minutos AS DuracionMinutos,
        @alerta_cancelaciones AS AlertaCancelaciones,
        @cancelaciones_30_dias AS CancelacionesUltimos30Dias
    FROM dbo.trx_citas c
    WHERE c.id = SCOPE_IDENTITY();
END;
GO

-- Cancelar cita
CREATE OR ALTER PROCEDURE dbo.sp_trx_citas_cancelar
    @cita_id INT,
    @motivo_cancelacion NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.trx_citas WHERE id = @cita_id)
    BEGIN
        RAISERROR('La cita no existe.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.trx_citas WHERE id = @cita_id AND estado = 'Cancelada')
    BEGIN
        RAISERROR('La cita ya se encuentra cancelada.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.trx_citas WHERE id = @cita_id AND estado = 'Completada')
    BEGIN
        RAISERROR('No se puede cancelar una cita completada.', 16, 1);
        RETURN;
    END

    UPDATE dbo.trx_citas
    SET
        estado = 'Cancelada',
        motivo_cancelacion = @motivo_cancelacion,
        fecha_cancelacion = SYSDATETIME()
    WHERE id = @cita_id;

    SELECT
        c.id AS Id,
        c.medico AS MedicoId,
        c.paciente AS PacienteId,
        c.fecha_hora_inicio AS FechaHoraInicio,
        c.fecha_hora_fin AS FechaHoraFin,
        c.motivo AS Motivo,
        c.estado AS Estado,
        c.motivo_cancelacion AS MotivoCancelacion,
        c.fecha_cancelacion AS FechaCancelacion,
        c.fecha_creacion AS FechaCreacion,
        e.nombre AS EspecialidadNombre,
        e.duracion_minutos AS DuracionMinutos
    FROM dbo.trx_citas c
    INNER JOIN dbo.mst_medicos m ON m.id = c.medico
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE c.id = @cita_id;
END;
GO

-- Consultar citas
CREATE OR ALTER PROCEDURE dbo.sp_trx_citas_consultar
    @medico_id INT = NULL,
    @paciente_id INT = NULL,
    @fecha_desde DATETIME2 = NULL,
    @fecha_hasta DATETIME2 = NULL,
    @estado NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        c.id AS Id,
        c.medico AS MedicoId,
        CONCAT(m.nombre, ' ', m.apellido_paterno, COALESCE(' ' + m.apellido_materno, '')) AS MedicoNombre,
        c.paciente AS PacienteId,
        CONCAT(p.nombre, ' ', p.apellido_paterno, COALESCE(' ' + p.apellido_materno, '')) AS PacienteNombre,
        c.fecha_hora_inicio AS FechaHoraInicio,
        c.fecha_hora_fin AS FechaHoraFin,
        c.motivo AS Motivo,
        c.estado AS Estado,
        c.motivo_cancelacion AS MotivoCancelacion,
        c.fecha_cancelacion AS FechaCancelacion,
        c.fecha_creacion AS FechaCreacion,
        e.nombre AS EspecialidadNombre,
        e.duracion_minutos AS DuracionMinutos
    FROM dbo.trx_citas c
    INNER JOIN dbo.mst_medicos m ON m.id = c.medico
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    INNER JOIN dbo.mst_pacientes p ON p.id = c.paciente
    WHERE (@medico_id IS NULL OR c.medico = @medico_id)
      AND (@paciente_id IS NULL OR c.paciente = @paciente_id)
      AND (@fecha_desde IS NULL OR c.fecha_hora_inicio >= @fecha_desde)
      AND (@fecha_hasta IS NULL OR c.fecha_hora_inicio <= @fecha_hasta)
      AND (@estado IS NULL OR c.estado = @estado)
    ORDER BY c.fecha_hora_inicio DESC;
END;
GO

-- Regla 6: Sugerir horarios alternativos
CREATE OR ALTER PROCEDURE dbo.sp_trx_citas_sugerir_horarios
    @medico_id INT,
    @fecha DATE,
    @hora_inicio_deseada TIME(0),
    @cantidad INT = 3
AS
BEGIN
    SET NOCOUNT ON;
    SET DATEFIRST 1;

    DECLARE @duracion_minutos INT;
    DECLARE @especialidad_nombre NVARCHAR(100);
    DECLARE @dia_semana INT;
    DECLARE @hora_consulta_inicio TIME(0);
    DECLARE @hora_consulta_fin TIME(0);
    DECLARE @inicio_ventana DATETIME2;
    DECLARE @fin_ventana DATETIME2;
    DECLARE @fecha_hora_deseada DATETIME2;

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @cantidad = 3;

    SELECT
        @duracion_minutos = e.duracion_minutos,
        @especialidad_nombre = e.nombre
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.id = @medico_id
      AND m.activo = 1;

    IF @duracion_minutos IS NULL
    BEGIN
        RAISERROR('El médico no existe o está inactivo.', 16, 1);
        RETURN;
    END

    SET @dia_semana = DATEPART(WEEKDAY, @fecha);

    SELECT
        @hora_consulta_inicio = h.hora_inicio,
        @hora_consulta_fin = h.hora_fin
    FROM dbo.mst_horarios_medico h
    WHERE h.medico = @medico_id
      AND h.dia_semana = @dia_semana;

    IF @hora_consulta_inicio IS NULL OR @hora_consulta_fin IS NULL
    BEGIN
        RAISERROR('El médico no tiene horario de consulta configurado para ese día.', 16, 1);
        RETURN;
    END

    SET @inicio_ventana = DATEADD(SECOND, DATEDIFF(SECOND, CAST('00:00:00' AS TIME), @hora_consulta_inicio), CAST(@fecha AS DATETIME2));
    SET @fin_ventana = DATEADD(SECOND, DATEDIFF(SECOND, CAST('00:00:00' AS TIME), @hora_consulta_fin), CAST(@fecha AS DATETIME2));
    SET @fecha_hora_deseada = DATEADD(SECOND, DATEDIFF(SECOND, CAST('00:00:00' AS TIME), @hora_inicio_deseada), CAST(@fecha AS DATETIME2));

    ;WITH slots AS (
        SELECT @inicio_ventana AS FechaHoraInicio
        UNION ALL
        SELECT DATEADD(MINUTE, @duracion_minutos, s.FechaHoraInicio)
        FROM slots s
        WHERE DATEADD(MINUTE, @duracion_minutos, s.FechaHoraInicio) <= DATEADD(MINUTE, -@duracion_minutos, @fin_ventana)
    ),
    disponibles AS (
        SELECT
            s.FechaHoraInicio,
            DATEADD(MINUTE, @duracion_minutos, s.FechaHoraInicio) AS FechaHoraFin
        FROM slots s
        WHERE s.FechaHoraInicio >= SYSDATETIME()
          AND NOT EXISTS (
              SELECT 1
              FROM dbo.trx_citas c
              WHERE c.medico = @medico_id
                AND c.estado = 'Programada'
                AND c.fecha_hora_inicio < DATEADD(MINUTE, @duracion_minutos, s.FechaHoraInicio)
                AND c.fecha_hora_fin > s.FechaHoraInicio
          )
    )
    SELECT TOP (@cantidad)
        @medico_id AS MedicoId,
        FechaHoraInicio,
        FechaHoraFin,
        @especialidad_nombre AS EspecialidadNombre,
        @duracion_minutos AS DuracionMinutos,
        ABS(DATEDIFF(MINUTE, @fecha_hora_deseada, FechaHoraInicio)) AS DiferenciaMinutosContraSolicitado
    FROM disponibles
    ORDER BY
        ABS(DATEDIFF(MINUTE, @fecha_hora_deseada, FechaHoraInicio)),
        FechaHoraInicio
    OPTION (MAXRECURSION 32767);
END;
GO
