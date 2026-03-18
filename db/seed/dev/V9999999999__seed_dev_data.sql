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