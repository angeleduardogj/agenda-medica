-- Obtener pacientes activos
CREATE OR ALTER PROCEDURE dbo.sp_mst_pacientes_obtenertodos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id                  AS Id,
        nombre              AS Nombre,
        apellido_paterno    AS ApellidoPaterno,
        apellido_materno    AS ApellidoMaterno,
        fecha_nacimiento    AS FechaNacimiento,
        telefono            AS Telefono,
        email               AS Email,
        activo              AS Activo,
        fecha_creacion      AS FechaCreacion
    FROM dbo.mst_pacientes
    WHERE activo = 1
    ORDER BY apellido_paterno, nombre;
END;
GO

-- Obtener paciente por id
CREATE OR ALTER PROCEDURE dbo.sp_mst_pacientes_obtenerporid
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        id                  AS Id,
        nombre              AS Nombre,
        apellido_paterno    AS ApellidoPaterno,
        apellido_materno    AS ApellidoMaterno,
        fecha_nacimiento    AS FechaNacimiento,
        telefono            AS Telefono,
        email               AS Email,
        activo              AS Activo,
        fecha_creacion      AS FechaCreacion
    FROM dbo.mst_pacientes
    WHERE id = @id;
END;
GO

-- Crear paciente
CREATE OR ALTER PROCEDURE dbo.sp_mst_pacientes_crear
    @nombre           NVARCHAR(150),
    @apellido_paterno NVARCHAR(150),
    @apellido_materno NVARCHAR(150) = NULL,
    @fecha_nacimiento DATE,
    @telefono         NVARCHAR(20)  = NULL,
    @email            NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO dbo.mst_pacientes (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono, email)
    VALUES (@nombre, @apellido_paterno, @apellido_materno, @fecha_nacimiento, @telefono, @email);

    DECLARE @nuevo_id INT = CAST(SCOPE_IDENTITY() AS INT);

    EXEC dbo.sp_mst_pacientes_obtenerporid @id = @nuevo_id;
END;
GO

-- Actualizar pacientes
CREATE OR ALTER PROCEDURE dbo.sp_mst_pacientes_actualizar
    @id               INT,
    @nombre           NVARCHAR(150),
    @apellido_paterno NVARCHAR(150),
    @apellido_materno NVARCHAR(150) = NULL,
    @fecha_nacimiento DATE,
    @telefono         NVARCHAR(20)  = NULL,
    @email            NVARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.mst_pacientes WHERE id = @id AND activo = 1)
    BEGIN
        RAISERROR('El paciente no existe o está inactivo.', 16, 1);
        RETURN;
    END

    UPDATE dbo.mst_pacientes
    SET
        nombre           = @nombre,
        apellido_paterno = @apellido_paterno,
        apellido_materno = @apellido_materno,
        fecha_nacimiento = @fecha_nacimiento,
        telefono         = @telefono,
        email            = @email
    WHERE id = @id;

    EXEC dbo.sp_mst_pacientes_obtenerporid @id = @id;
END;
GO

-- Eliminar paciente (borrado lógico)
CREATE OR ALTER PROCEDURE dbo.sp_mst_pacientes_eliminar
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM dbo.mst_pacientes WHERE id = @id AND activo = 1)
    BEGIN
        RAISERROR('El paciente no existe o ya fue eliminado.', 16, 1);
        RETURN;
    END

    IF EXISTS (SELECT 1 FROM dbo.trx_citas WHERE paciente = @id AND estado = 'Programada')
    BEGIN
        RAISERROR('No se puede eliminar el paciente porque tiene citas programadas.', 16, 1);
        RETURN;
    END

    UPDATE dbo.mst_pacientes
    SET activo = 0
    WHERE id = @id;
END;
GO

-- Historial de citas por paciente
CREATE OR ALTER PROCEDURE dbo.sp_mst_pacientes_historial_citas
    @paciente_id INT
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
    WHERE c.paciente = @paciente_id
    ORDER BY c.fecha_hora_inicio DESC;
END;
GO
