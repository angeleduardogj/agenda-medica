-- ============================================================
-- MINI-AGENDA MÉDICA — DLL INICIAL
-- Angel Gaxiola
-- ============================================================

CREATE TABLE dbo.cat_especialidades (
    id               INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    nombre           NVARCHAR(100) NOT NULL UNIQUE,
    duracion_minutos INT           NOT NULL CHECK (duracion_minutos > 0)
);
 
CREATE TABLE dbo.mst_medicos (
    id             INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    nombre         NVARCHAR(150) NOT NULL,
     apellido_paterno NVARCHAR(150) NOT NULL,
    apellido_materno NVARCHAR(150) NULL,
    especialidad   INT           NOT NULL REFERENCES dbo.cat_especialidades(id),
    telefono       NVARCHAR(20)  NULL,
    email          NVARCHAR(200) NULL,
    activo         BIT           NOT NULL DEFAULT 1,
    fecha_creacion DATETIME2     NOT NULL DEFAULT GETDATE()
);
 
CREATE TABLE dbo.mst_horarios_medico (
    id          INT  NOT NULL IDENTITY(1,1) PRIMARY KEY,
    medico      INT  NOT NULL REFERENCES dbo.mst_medicos(id) ON DELETE CASCADE,
    dia_semana  INT  NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),
    hora_inicio TIME NOT NULL,
    hora_fin    TIME NOT NULL,
    CHECK (hora_fin > hora_inicio),
    UNIQUE (medico, dia_semana)
);