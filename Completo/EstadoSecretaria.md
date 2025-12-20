# Plan de Implementación: Rol Secretaria (Por Sprints)

Este documento organiza la implementación del módulo de Secretaría en Sprints lógicos para entregar valor incremental.

## Sprint 1: Inscripciones y Gestión de Estudiantes
**Objetivo**: Habilitar el registro de nuevos alumnos, la actualización de antiguos y la gestión de su información (Kardex).

### 1.1 Estructura y Navegación
- [x] **Frontend**: Implementar `DashboardSecretariaPage` con el nuevo menú definido en `menu_items.dart`.
- [x] **Frontend**: Configurar rutas base en `routes.dart`.

### 1.2 Nueva Inscripción
- [x] **Backend**: Verificar integración transaccional (Estudiante + Tutor + Inscripción).
- [x] **Frontend**: Implementar `NuevaInscripcionPage`.
    - *Componentes*: Wizard de pasos (Datos Personales -> Tutores -> Curso -> Confirmación).
    - *Reutilización*: Adaptar `RegistroEstudianteForm` para permitir flujo continuo.

### 1.3 Re-inscripción (Estudiantes Antiguos)
- [x] **Frontend**: Implementar `ReinscripcionPage`.
    - *Flujo*: Buscador de estudiantes -> Verificación de datos -> Asignación de nueva gestión/curso.

### 1.4 Gestión de Matriculados
- [x] **Frontend**: Implementar `ListaMatriculadosPage`.
    - *Features*: Filtros avanzados (Nivel, Grado, Paralelo, Gestión) y exportación rápida (PDF/Excel si aplica).

### 1.5 Kardex de Estudiante
- [x] **Frontend**: Implementar `KardexEstudiantePage`.
    - *Vista 360*: Perfil completo con pestañas para:
        - Datos Generales (Editable).
        - Boletín de Notas (Histórico).
        - Estado de Cuenta (Resumen Pagos).
        - Documentos (Certificados/RUDE).

---

## Sprint 2: Caja y Gestión Financiera
**Objetivo**: Permitir el cobro de pensiones, emisión de recibos y cuadre de caja diario.

### 2.1 Procesar Cobros
- [x] **Backend**: Asegurar endpoint `POST /api/pagos/cobrar` soporte múltiples conceptos.
- [x] **Frontend**: Implementar `CobrarPensionPage`.
    - *Flujo*:
        1. Buscar Estudiante.
        2. Seleccionar Concepto (Mensualidad X, Matrícula, Multa).
        3. Verificación de Monto (Cálculo de moras o descuentos).
        4. Selección Método Pago (Efectivo/QR).
        5. Confirmar y Generar Recibo.

### 2.2 Historial de Transacciones
- [x] **Frontend**: Implementar `HistorialTransaccionesPage`.
    - *Funcionalidad*: Listado de recibos emitidos en el día o por rango de fechas.
    - *Acciones*: Ver detalle, reimprimir recibo, anular transacción (con permisos).
- [/] **Pendiente**: Implementar impresión de PDF "Recibo de Transacción" (Implementado, Verificar).

### 2.3 Cierre de Caja
- [x] **Backend**: Endpoint de reporte diario por cajero (`/api/caja/cierre`).
- [x] **Frontend**: Implementar `CierreCajaPage`.
    - *Reporte*: Resumen de ingresos por método de pago (Efectivo vs QR) y desglose por conceptos.
- [/] **Pendiente**: Implementar impresión de PDF "Reporte de Cierre de Caja" (Implementado, Verificar).
