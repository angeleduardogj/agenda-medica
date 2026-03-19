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