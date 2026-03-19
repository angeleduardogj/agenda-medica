# Migraciones con Flyway

Este documento describe cómo instalar, configurar y operar Flyway en este proyecto.

## Instalación de Flyway

## Windows (opciones comunes)

- Winget:

```bash
winget install Redgate.Flyway
```

- Chocolatey:

```bash
choco install flyway
```

- Manual:
  - Descargar ZIP de Flyway CLI
  - Descomprimir
  - Agregar carpeta `flyway` al `PATH`

Verifica instalación:

```bash
flyway -v
```

## Configuración del proyecto

Base template: [flyway.conf.template](file:///c:/Users/angel.gaxiola/Documents/angel/agenda-medica/flyway.conf.template)

Crea `flyway.conf` en la raíz con:

```properties
flyway.url=jdbc:sqlserver://localhost:1433;databaseName=AgendaMedicaDB_DEV;encrypt=true;trustServerCertificate=true
flyway.user=TU_USER
flyway.password=TU_PASSWORD
flyway.locations=filesystem:./db/migrations,filesystem:./db/seed/dev
```

## Flujo recomendado

### 1) Inicialización manual de DB

```sql
IF DB_ID('AgendaMedicaDB_DEV') IS NULL
BEGIN
    CREATE DATABASE [AgendaMedicaDB_DEV];
END
GO

USE [AgendaMedicaDB_DEV];
GO
```

### 2) Revisar estado

```bash
flyway info
```

### 3) Aplicar cambios

```bash
flyway migrate
```

### 4) Validar integridad

```bash
flyway validate
```

## Estructura de carpetas

- Migraciones versionadas: [db/migrations](file:///c:/Users/angel.gaxiola/Documents/angel/agenda-medica/db/migrations)
- Seeds de desarrollo: [db/seed/dev](file:///c:/Users/angel.gaxiola/Documents/angel/agenda-medica/db/seed/dev)

## Convenciones de nombres

- Versionadas: `V<numero>__descripcion.sql`
  - Ejemplo: `V6__sp_citas.sql`
- Seeds dev: `V9999999999__seed_dev_data.sql`

## Comandos útiles

- Estado:

```bash
flyway info
```

- Migrar:

```bash
flyway migrate
```

- Validar:

```bash
flyway validate
```

- Reparar metadatos (usar solo si sabes por qué):

```bash
flyway repair
```

## Casos frecuentes y cómo resolverlos

### Error: `Detected resolved migration not applied to database`

Significa que el archivo existe en disco pero no está aplicado en `flyway_schema_history`.

Opciones:

1. Ejecutar `flyway migrate` si está pendiente normal.
2. Si quedó fuera de orden (hay una versión mayor aplicada), crear nueva migración con versión siguiente en lugar de forzar.
3. Evitar `ignoreMigrationPatterns` como solución permanente.

### Cambió el contenido de una migración ya aplicada

Flyway fallará en validación por checksum.

Recomendación:

- No editar migraciones aplicadas en ambientes compartidos.
- Crear una nueva migración incremental.
- Usar `repair` solo cuando sea estrictamente necesario y controlado.

## Buenas prácticas

- Una migración por cambio lógico.
- Nunca borrar historial aplicado.
- Mantener seeds separados de estructura/SPs.
- Probar `info + migrate + validate` en desarrollo antes de compartir cambios.
