# Estado del Módulo Estudiante

Plan de implementación para completar el módulo de Estudiante basándonos en `RolMenu.md`.

## 📌 Sprint 1: Dashboard (Inicio)
**Objetivo:** Crear una pantalla de inicio útil e informativa.
- [x] **Implementar `DashboardEstudiante.dart`**:
    - [x] **Widget Resumen Académico**: Mostrar "Próxima Materia" (según horario) o "Promedio Actual" (Se implementó el perfil y saludo).
    - [x] **Widget Estado Financiero**: Mostrar estado de la mensualidad del mes actual (Pagado/Pendiente).
    - [x] **Widget Últimos Avisos**: Mostrar los 2 últimos comunicados no leídos.

## 📌 Sprint 2: Gestión Académica
**Objetivo:** Visualización de carga académica y rendimiento.
- [x] **Mis Materias (`/dashboard-estudiante/materias`)**:
    - [x] Implementar vista con lista de asignaturas, nombre del profesor y horario resumen.
- [x] **Mis Notas (`/dashboard-estudiante/notas`)**:
    - [x] Integrar botón "Descargar Boletín Oficial" (PDF).
    - [x] Backend: Verificar Endpoint `/api/reportes/boletin/{idEstudiante}`.
    - [x] Frontend: Conectar con `PdfService`.

## 📌 Sprint 3: Finanzas y Documentos
**Objetivo:** Transparencia financiera y acceso a recibos.
- [x] **Pagos (`/dashboard-estudiante/pagos`)**:
    - [x] Optimizar vista para diferenciar deudas vencidas/pendientes.
- [x] **Comprobantes (`/dashboard-estudiante/comprobantes`)**:
    - [x] Implementar lista de pagos realizados.
    - [x] Agregar botón "Descargar Recibo" (Endpoint `/api/reportes/recibo/{id}`).

## 📌 Sprint 4: Social y Validaciones
**Objetivo:** Comunicación efectiva.
- [x] **Validación UX/UI**:
    - [x] Verificar que `Comunicados` y `Agenda (Eventos)` sigan el diseño visual del sistema.
    - [x] Asegurar que las notificaciones (si existen) redirijan a estas pantallas.

---
## 🛠 Notas Técnicas
*   **Servicios Requeridos**:
    *   `EstudianteService`: Para perfil y materias.
    *   `PagoService`: Para deudas y transacciones.
    *   `PdfService`: Para descargar boletines y recibos.
    *   `ComunicadoService`: Para el dashboard.
