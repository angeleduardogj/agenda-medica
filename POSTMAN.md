# Guía de Postman

La colección del proyecto está en:

- [AgendaMedica.postman_collection.json](file:///c:/Users/angel.gaxiola/Documents/angel/agenda-medica/AgendaMedica.postman_collection.json)

## Importar colección

1. Abre Postman.
2. `Import` → selecciona el archivo `AgendaMedica.postman_collection.json`.
3. Verifica variable `base_url` en la colección:
   - `http://localhost:5022`

## Carpetas de la colección

- `Medicos`
- `Horarios`
- `Pacientes`
- `Citas`
- `Reglas Citas con datos seed`

## Flujo recomendado de pruebas

### Flujo base

1. Crear médico
2. Crear horario
3. Crear paciente
4. Agendar cita
5. Consultar cita
6. Cancelar cita

### Flujo de reglas con seed

Usa la carpeta `Reglas Citas con datos seed`.  
Está pensada para validar conflictos, fuera de horario, cita en pasado y alerta de cancelaciones con datos del seed.

Orden sugerido dentro de esa carpeta:

1. Obtener médico seed
2. Obtener horario seed
3. Agendar para conflicto
4. Agendar fuera de horario
5. Agendar en pasado
6. Agendar para alerta de cancelaciones
7. Consultar citas
8. Cancelar cita seed

## Notas

- Si cambias puertos o ambiente, actualiza `base_url`.
- Si la BD fue recreada, vuelve a correr migraciones y seeds antes de probar.
