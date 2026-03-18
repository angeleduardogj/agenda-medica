-- Obtener todos
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_obtenertodos
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id,
        m.nombre,
        m.apellido_paterno,
        m.apellido_materno,
        m.especialidad AS especialidad_id,
        e.nombre       AS especialidad_nombre,
        e.duracion_minutos,
        m.telefono,
        m.email,
        m.activo,
        m.fecha_creacion
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.activo = 1
    ORDER BY m.apellido_paterno, m.nombre;
END;
GO

-- Obtener por Id
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_obtenerporid
    @id INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.id,
        m.nombre,
        m.apellido_paterno,
        m.apellido_materno,
        m.especialidad AS especialidad_id,
        e.nombre       AS especialidad_nombre,
        e.duracion_minutos,
        m.telefono,
        m.email,
        m.activo,
        m.fecha_creacion
    FROM dbo.mst_medicos m
    INNER JOIN dbo.cat_especialidades e ON e.id = m.especialidad
    WHERE m.id = @id;

    SELECT
        id,
        dia_semana,
        hora_inicio,
        hora_fin
    FROM dbo.mst_horarios_medico
    WHERE medico = @id
    ORDER BY dia_semana;
END;
GO

-- Crear
CREATE OR ALTER PROCEDURE dbo.sp_mst_medicos_crear
    @nombre           NVARCHAR(150),
    @apellido_paterno NVARCHAR(150),
    @apellido_materno NVARCHAR(150) = NULL,
    @especialidad     INT,
    @telefono         NVARCHAR(20)  = NULL,
    @email            NVARCHAR(200) = NULL,
    @nuevo_id         INT OUTPUT
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

    SET @nuevo_id = SCOPE_IDENTITY();
END;
GO

-- Actualizar
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
END;
GO

-- Eliminar
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

