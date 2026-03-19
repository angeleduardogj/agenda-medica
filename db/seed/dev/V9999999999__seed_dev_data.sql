-- cat_especialidades---------------------------------------
INSERT INTO dbo.cat_especialidades (nombre, duracion_minutos) VALUES
    ('Medicina General', 20),
    ('Cardiología',      30),
    ('Cirugía',          45),
    ('Pediatría',        20),
    ('Ginecología',      30);

-- mst_medicos---------------------------------------
INSERT INTO dbo.mst_medicos (nombre, apellido_paterno, apellido_materno, especialidad, telefono, email) VALUES
    ('Carlos', 'Ramírez','Ramírez',  1, '5551001001', 'c.ramirez@hospital.com'),
    ('Ana',    'González','González', 2, '5551001002', 'a.gonzalez@hospital.com');

-- mst_horarios_medico---------------------------------------
INSERT INTO dbo.mst_horarios_medico (medico, dia_semana, hora_inicio, hora_fin) VALUES
    (1, 1, '08:00', '14:00'),
    (1, 2, '08:00', '14:00');

INSERT INTO dbo.mst_horarios_medico (medico, dia_semana, hora_inicio, hora_fin) VALUES
    (2, 1, '09:00', '15:00'),
    (2, 3, '09:00', '15:00');

-- mst_pacientes---------------------------------------
INSERT INTO dbo.mst_pacientes (nombre, apellido_paterno, apellido_materno, fecha_nacimiento, telefono, email) VALUES
    ('Luis',  'Martínez', 'Vega', '1985-03-12', '5552001001', 'luis.martinez@mail.com'),
    ('María', 'López',    'Ruiz', '1990-07-25', '5552001002', 'maria.lopez@mail.com');

-- trx_citas---------------------------------------
INSERT INTO dbo.trx_citas (medico, paciente, fecha_hora_inicio, fecha_hora_fin, motivo) VALUES
    (1, 1, '2026-03-23 09:00', '2026-03-23 09:20', 'Dolor de cabeza'),
    (2, 2, '2026-03-23 10:00', '2026-03-23 10:30', 'Revisión electrocardiograma');

-- trx_citas_reglas---------------------------------------
INSERT INTO dbo.trx_citas (medico, paciente, fecha_hora_inicio, fecha_hora_fin, motivo, estado) VALUES
    (1, 1, '2099-01-05 09:00', '2099-01-05 09:20', 'Seed conflicto reglas', 'Programada');

INSERT INTO dbo.trx_citas (medico, paciente, fecha_hora_inicio, fecha_hora_fin, motivo, estado, motivo_cancelacion, fecha_cancelacion) VALUES
    (1, 1, DATEADD(DAY, -20, SYSDATETIME()), DATEADD(DAY, -20, DATEADD(MINUTE, 20, SYSDATETIME())), 'Seed cancelada 1', 'Cancelada', 'Cancelación seed 1', DATEADD(DAY, -20, SYSDATETIME())),
    (1, 1, DATEADD(DAY, -10, SYSDATETIME()), DATEADD(DAY, -10, DATEADD(MINUTE, 20, SYSDATETIME())), 'Seed cancelada 2', 'Cancelada', 'Cancelación seed 2', DATEADD(DAY, -10, SYSDATETIME())),
    (1, 1, DATEADD(DAY, -5, SYSDATETIME()),  DATEADD(DAY, -5,  DATEADD(MINUTE, 20, SYSDATETIME())), 'Seed cancelada 3', 'Cancelada', 'Cancelación seed 3', DATEADD(DAY, -5, SYSDATETIME()));
