-- ============================================================
-- MINI-AGENDA MÉDICA — DLL INICIAL
-- Angel Gaxiola
-- ============================================================

CREATE TABLE dbo.mst_pacientes (
    id               INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    nombre           NVARCHAR(150) NOT NULL,
    apellido_paterno NVARCHAR(150) NOT NULL,
    apellido_materno NVARCHAR(150) NULL,
    fecha_nacimiento DATE          NOT NULL CHECK (fecha_nacimiento < CAST(GETDATE() AS DATE)),
    telefono         NVARCHAR(20)  NULL,
    email            NVARCHAR(200) NULL,
    activo           BIT           NOT NULL DEFAULT 1,
    fecha_creacion   DATETIME2     NOT NULL DEFAULT GETDATE()
);