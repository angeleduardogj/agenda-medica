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
