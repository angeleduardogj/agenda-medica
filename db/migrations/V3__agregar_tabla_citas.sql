-- ============================================================
-- MINI-AGENDA MÉDICA — DLL INICIAL
-- Angel Gaxiola
-- ============================================================

CREATE TABLE dbo.trx_citas (
    id                 INT           NOT NULL IDENTITY(1,1) PRIMARY KEY,
    medico             INT           NOT NULL REFERENCES dbo.mst_medicos(id),
    paciente           INT           NOT NULL REFERENCES dbo.mst_pacientes(id),
    fecha_hora_inicio  DATETIME2     NOT NULL,
    fecha_hora_fin     DATETIME2     NOT NULL,
    motivo             NVARCHAR(500) NOT NULL,
    estado             NVARCHAR(20)  NOT NULL DEFAULT 'Programada' CHECK (estado IN ('Programada','Cancelada','Completada')),
    motivo_cancelacion NVARCHAR(500) NULL,
    fecha_cancelacion  DATETIME2     NULL,
    fecha_creacion     DATETIME2     NOT NULL DEFAULT GETDATE(),
    CHECK (fecha_hora_fin > fecha_hora_inicio),
    CHECK ((estado = 'Cancelada' AND motivo_cancelacion IS NOT NULL) OR estado <> 'Cancelada')
);