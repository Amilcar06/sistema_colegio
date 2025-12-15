# Estructura del Proyecto y Estado Actual

## 1. Estructura de Carpetas (Backend)
El proyecto es una aplicación **Spring Boot** gestionada con **Maven**.

```text
unidad-educativa/
├── src/main/java/com/unidadeducativa
│   ├── academia/            # Módulo Académico (Core)
│   │   ├── gestion/         # Gestión Académica (Años escolares)
│   │   ├── curso/           # Cursos y niveles
│   │   ├── materia/         # Materias (con soporte de maillaje)
│   │   ├── inscripcion/     # Inscripsiones de alumnos cursantes
│   │   └── ...
│   ├── finanzas/            # [NUEVO] Módulo Financiero
│   │   ├── dto/             # Objetos de transferencia de datos
│   │   ├── model/           # Entidades: Pago, TipoPago, CuentaCobrar
│   │   ├── repository/      # Repositorios JPA
│   │   ├── service/         # Lógica de negocio (Pagos, Reportes)
│   │   └── controller/      # Endpoints REST (PagoMensualidadController)
│   ├── personas/            # Actores (Estudiante, Profesor, Director...)
│   ├── usuario/             # Gestión de Usuarios y Roles (Auth)
│   └── shared/              # Utilidades compartidas (excepciones, mapeadores base)
├── docker-compose.yml       # Orquestación de Base de Datos y App (Opcional)
└── pom.xml                  # Dependencias del proyecto
```

## 2. Funcionalidades Implementadas

### ✅ Fase 1: Multi-Tenancy (SaaS)
- **Entidad `UnidadEducativa`**: Centraliza la lógica SaaS.
- **Relaciones**: Todos los usuarios y entidades clave (`Gestion`, `Materia`, etc.) ahora pertenecen a una `UnidadEducativa`.
- **Propósito**: Permitir que múltiples colegios usen el sistema con datos aislados.

### ✅ Fase 2: Gestión Curricular
- **Plantillas Curriculares**: Enumeración `CurriculumTemplate` con la base boliviana (Inicial, Primaria, Secundaria).
- **Inicialización Automática**: Al registrar un colegio, se crean automáticamente sus cursos y materias base.

### ✅ Fase 3: Registro y Autenticación
- **Flujo de Registro**: Endpoint `/auth/register-school` crea:
    1. La Unidad Educativa.
    2. El usuario Director (Admin del colegio).
    3. La Gestión Académica inicial (ej. 2024).

### ✅ Fase 4: Módulo Financiero
- **Pensiones y Pagos**:
    - **Conceptos de Pago**: Definición de montos (Mensualidades, Matrículas).
    - **Cuentas por Cobrar**: Generación de deudas a estudiantes.
    - **Registro de Pagos**: Procesamiento de transacciones con validación de montos.
- **Reportes**:
    - Ingresos por rango de fechas.
    - Lista de estudiantes deudores.

## 3. Cosas que Faltan / Próximos Pasos (Recomendados)

Aunque la lógica core está completa, para un entorno de producción se sugiere:

1.  **Seguridad Avanzada**:
    - Verificar que un Director solo pueda ver datos *de su unidad educativa* (actualmente la relación existe, asegurar en todos los `findAll`).
    - Implementar `@PreAuthorize` más estricto en controladores financieros.

2.  **Pruebas de Integración**:
    - Crear tests automatizados (`src/test/java`) para el flujo completo de pago: `Asignar Deuda -> Pagar Parcial -> Pagar Total`.

3.  **Frontend**:
    - Conectar estas nuevas APIs al cliente web/móvil.

4.  **Despliegue**:
    - Configurar variables de entorno para credenciales de BD en producción (evitar `application.properties` hardcodeado).
