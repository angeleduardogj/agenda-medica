# Por mejorar

## 1) Docker

- Implementar contenedores para la API y base de datos.
- Dejar un `docker-compose` funcional para levantar entorno local con un solo comando.
- Asegurar compatibilidad con migraciones Flyway y seed en arranque.

## 2) Swagger / OpenAPI

- Agregar documentación interactiva de endpoints en .NET.
- Publicar contratos de request/response para facilitar integración.
- Estandarizar ejemplos y códigos HTTP por endpoint.

## 3) Evaluar Entity Framework

- Revisar viabilidad de usar Entity Framework en algunos módulos.
- Actualmente no se usó para mantener una separación clara entre capa API y lógica SQL en SPs.
- Evaluar enfoque híbrido (SPs + EF en módulos que sí lo justifiquen).

## 4) Autorización y seguridad

- Implementar autenticación/autorización (por ejemplo JWT con roles).
- Definir permisos por módulo (médicos, pacientes, citas, administración).
- Endurecer políticas de acceso y manejo de credenciales.

## 5) Frontend (React / React Native)

- Construir frontend web con React por compatibilidad del equipo y velocidad de desarrollo.
- Mantener diseño de componentes pensando en reutilización para React Native.
- Considerar esta base para facilitar futura migración a app móvil.

## 6) Variables de entorno / configuración

- Terminar configuración por entorno para cadenas de conexión (dev, qa, prod).
- No quedó concluido por conflictos de configuración no nativa en el flujo actual.
- Dejar centralizado y estandarizado el uso de variables para evitar cambios manuales.
