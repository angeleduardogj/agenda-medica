-- Obtener médicos activos
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_obtenertodos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id                  AS Id,
        m.nombre              AS Nombre,
        m.apellido_paterno    AS ApellidoPaterno,
        m.apellido_materno    AS ApellidoMaterno,
        m.especialidad        AS EspecialidadId,
        e.nombre              AS EspecialidadNombre,
        e.duracion_minutos    AS DuracionMinutos,
        m.telefono            AS Telefono,
        m.email               AS Email,
        m.activo              AS Activo,
        m.fecha_creacion      AS FechaCreacion
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.activo = 1
    ORDER BY m.apellido_paterno, m.nombre;
END;
GO
-- Obtener médico por id
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_obtenerporid
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id                  AS Id,
        m.nombre              AS Nombre,
        m.apellido_paterno    AS ApellidoPaterno,
        m.apellido_materno    AS ApellidoMaterno,
        m.especialidad        AS EspecialidadId,
        e.nombre              AS EspecialidadNombre,
        e.duracion_minutos    AS DuracionMinutos,
        m.telefono            AS Telefono,
        m.email               AS Email,
        m.activo              AS Activo,
        m.fecha_creacion      AS FechaCreacion
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.id = @id;
END;
GO


-- Obtener horarios disponibles de médico
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_obtenerhorarios
    @medico_id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id          AS Id,
        dia_semana  AS DiaSemana,
        hora_inicio AS HoraInicio,
        hora_fin    AS HoraFin
    FROM dbo.mst_horarios_medico
    WHERE medico = @medico_id
    ORDER BY dia_semana;
END;
GO

-- Crear médico
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_crear
    @nombre           NVARCHAR(150),
    @apellido_paterno NVARCHAR(150),
    @apellido_materno NVARCHAR(150) = NULL,
    @especialidad     INT,
    @telefono         NVARCHAR(20)  = NULL,
    @email            NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.cat_especialidades WHERE id = @especialidad)
    BEGIN
        RAISERROR('La especialidad indicada no existe.', 16, 1);
        RETURN;
    END

    INSERT INTO dbo.mst_medicos (nombre, apellido_paterno, apellido_materno, especialidad, telefono, email)
    VALUES (@nombre, @apellido_paterno, @apellido_materno, @especialidad, @telefono, @email);

    DECLARE @nuevo_id INT = CAST(SCOPE_IDENTITY() AS INT);

    SELECT
        m.id                  AS Id,
        m.nombre              AS Nombre,
        m.apellido_paterno    AS ApellidoPaterno,
        m.apellido_materno    AS ApellidoMaterno,
        m.especialidad        AS EspecialidadId,
        e.nombre              AS EspecialidadNombre,
        e.duracion_minutos    AS DuracionMinutos,
        m.telefono            AS Telefono,
        m.email               AS Email,
        m.activo              AS Activo,
        m.fecha_creacion      AS FechaCreacion
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.id = @nuevo_id;
END;
GO

-- Actualizar médico
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_actualizar
    @id               INT,
    @nombre           NVARCHAR(150),
    @apellido_paterno NVARCHAR(150),
    @apellido_materno NVARCHAR(150) = NULL,
    @especialidad     INT,
    @telefono         NVARCHAR(20)  = NULL,
    @email            NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.mst_medicos WHERE id = @id AND activo = 1)
    BEGIN
        RAISERROR('El médico no existe o está inactivo.', 16, 1);
        RETURN;
    END

    IF NOT EXISTS (SELECT 1 FROM dbo.cat_especialidades WHERE id = @especialidad)
    BEGIN
        RAISERROR('La especialidad indicada no existe.', 16, 1);
        RETURN;
    END

    UPDATE dbo.mst_medicos
    SET
        nombre           = @nombre,
        apellido_paterno = @apellido_paterno,
        apellido_materno = @apellido_materno,
        especialidad     = @especialidad,
        telefono         = @telefono,
        email            = @email
    WHERE id = @id;

    SELECT
        m.id                  AS Id,
        m.nombre              AS Nombre,
        m.apellido_paterno    AS ApellidoPaterno,
        m.apellido_materno    AS ApellidoMaterno,
        m.especialidad        AS EspecialidadId,
        e.nombre              AS EspecialidadNombre,
        e.duracion_minutos    AS DuracionMinutos,
        m.telefono            AS Telefono,
        m.email               AS Email,
        m.activo              AS Activo,
        m.fecha_creacion      AS FechaCreacion
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.id = @id;
END;
GO

-- Crear horario
CREATE OR ALTER PROCEDURE dbo.sp_mst_horarios_crear
    @medico_id   INT,
    @dia_semana  INT,
    @hora_inicio TIME,
    @hora_fin    TIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @nombre_medico NVARCHAR(300);

    SELECT @nombre_medico = CONCAT(nombre, ' ', apellido_paterno) 
    FROM dbo.mst_medicos 
    WHERE id = @medico_id AND activo = 1;

    IF @nombre_medico IS NULL
    BEGIN
        RAISERROR('El médico no existe o está inactivo.', 16, 1);
        RETURN;
    END

    -- Regla: Cada día puede tener 1 horario por médico
    IF EXISTS (
        SELECT 1 
        FROM dbo.mst_horarios_medico 
        WHERE medico = @medico_id 
          AND dia_semana = @dia_semana
    )
    BEGIN
        DECLARE @nombre_dia NVARCHAR(20) = 
            CHOOSE(@dia_semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo');
        
        DECLARE @error_msg NVARCHAR(500) = 
            CONCAT('Ya existe un horario para el día ', @nombre_dia, ' para el médico ', @nombre_medico, '.');
        
        RAISERROR(@error_msg, 16, 1);
        RETURN;
    END

    INSERT INTO dbo.mst_horarios_medico (medico, dia_semana, hora_inicio, hora_fin)
    VALUES (@medico_id, @dia_semana, @hora_inicio, @hora_fin);

    SELECT
        id          AS Id,
        dia_semana  AS DiaSemana,
        hora_inicio AS HoraInicio,
        hora_fin    AS HoraFin
    FROM dbo.mst_horarios_medico
    WHERE id = SCOPE_IDENTITY();
END;
GO

-- Actualizar horario
CREATE OR ALTER PROCEDURE dbo.sp_mst_horarios_actualizar
    @id          INT,
    @dia_semana  INT,
    @hora_inicio TIME,
    @hora_fin    TIME
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @medico_id INT;
    DECLARE @nombre_medico NVARCHAR(300);

    SELECT 
        @medico_id = h.medico,
        @nombre_medico = CONCAT(m.nombre, ' ', m.apellido_paterno)
    FROM dbo.mst_horarios_medico h
    INNER JOIN dbo.mst_medicos m ON m.id = h.medico
    WHERE h.id = @id;

    IF @medico_id IS NULL
    BEGIN
        RAISERROR('El horario no existe.', 16, 1);
        RETURN;
    END

    -- Regla: Cada día puede tener 1 horario por médico
    IF EXISTS (
        SELECT 1 
        FROM dbo.mst_horarios_medico 
        WHERE medico = @medico_id 
          AND dia_semana = @dia_semana
          AND id <> @id
    )
    BEGIN
        DECLARE @nombre_dia NVARCHAR(20) = 
            CHOOSE(@dia_semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo');
        
        DECLARE @error_msg NVARCHAR(500) = 
            CONCAT('Ya existe un horario para el día ', @nombre_dia, ' para el médico ', @nombre_medico, '.');
        
        RAISERROR(@error_msg, 16, 1);
        RETURN;
    END

    UPDATE dbo.mst_horarios_medico
    SET 
        dia_semana = @dia_semana,
        hora_inicio = @hora_inicio,
        hora_fin = @hora_fin
    WHERE id = @id;

    SELECT
        id          AS Id,
        dia_semana  AS DiaSemana,
        hora_inicio AS HoraInicio,
        hora_fin    AS HoraFin
    FROM dbo.mst_horarios_medico
    WHERE id = @id;
END;
GO

-- Eliminar horario (borrado lógico)
CREATE OR ALTER PROCEDURE dbo.sp_mst_horarios_eliminar
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.mst_horarios_medico WHERE id = @id)
    BEGIN
        RAISERROR('El horario no existe.', 16, 1);
        RETURN;
    END

    DELETE FROM dbo.mst_horarios_medico WHERE id = @id;
END;
GO

-- Agenda del día por médico y fecha
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_agenda_dia
    @medico_id INT,
    @fecha DATE
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
    WHERE c.medico = @medico_id
      AND CAST(c.fecha_hora_inicio AS DATE) = @fecha
    ORDER BY c.fecha_hora_inicio;
END;
GO

-- Próximos horarios disponibles por médico y fecha
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_horarios_disponibles
    @medico_id INT,
    @fecha DATE,
    @cantidad INT = 5
AS
BEGIN
    SET NOCOUNT ON;
    SET DATEFIRST 1;

    DECLARE @duracion_minutos INT;
    DECLARE @especialidad_nombre NVARCHAR(100);

    IF @cantidad IS NULL OR @cantidad <= 0
        SET @cantidad = 5;

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

    ;WITH dias AS (
        SELECT CAST(@fecha AS DATE) AS Fecha
        UNION ALL
        SELECT DATEADD(DAY, 1, Fecha)
        FROM dias
        WHERE Fecha < DATEADD(DAY, 30, CAST(@fecha AS DATE))
    ),
    horarios_dia AS (
        SELECT
            d.Fecha,
            h.hora_inicio,
            h.hora_fin
        FROM dias d
        INNER JOIN dbo.mst_horarios_medico h
            ON h.medico = @medico_id
           AND h.dia_semana = DATEPART(WEEKDAY, d.Fecha)
    ),
    slots AS (
        SELECT
            CAST(DATEADD(SECOND, DATEDIFF(SECOND, CAST('00:00:00' AS TIME), hd.hora_inicio), CAST(hd.Fecha AS DATETIME2)) AS DATETIME2) AS FechaHoraInicio,
            CAST(DATEADD(SECOND, DATEDIFF(SECOND, CAST('00:00:00' AS TIME), hd.hora_fin), CAST(hd.Fecha AS DATETIME2)) AS DATETIME2) AS FechaHoraFinLimite
        FROM horarios_dia hd
        UNION ALL
        SELECT
            DATEADD(MINUTE, @duracion_minutos, s.FechaHoraInicio),
            s.FechaHoraFinLimite
        FROM slots s
        WHERE DATEADD(MINUTE, @duracion_minutos, s.FechaHoraInicio) <= DATEADD(MINUTE, -@duracion_minutos, s.FechaHoraFinLimite)
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
        @duracion_minutos AS DuracionMinutos
    FROM disponibles
    ORDER BY FechaHoraInicio
    OPTION (MAXRECURSION 32767);
END;
GO

-- Eliminar médico (borrado lógico)
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_eliminar
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.mst_medicos WHERE id = @id AND activo = 1)
    BEGIN
        RAISERROR('El médico no existe o ya fue eliminado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.trx_citas WHERE medico = @id)
    BEGIN
        RAISERROR('No se puede eliminar el médico porque tiene citas asociadas.', 16, 1);
        RETURN;
    END

    UPDATE dbo.mst_medicos
    SET activo = 0
    WHERE id = @id;
END;
GO
