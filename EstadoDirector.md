# 📋 Plan de Implementación: Finalización del Rol Director

Este documento detalla la hoja de ruta estratégica para completar el 100% de las funcionalidades del **Director** en el sistema "Unidad Educativa". El plan está organizado por Sprints lógicos para maximizar la entrega de valor y minimizar dependencias.

---

## 🏃 Sprint 1: Infraestructura y Configuración Base (Prioridad Alta)
**Objetivo:** Establecer las bases de configuración institucional y académica que actualmente están simuladas o faltantes.

### 1.1 Configuración de Paralelos (Backend & Frontend)
Actualmente, los paralelos (A, B, C) son solo strings en la clase `Curso`. Necesitamos controlarlos globalmente.
- [x] **Backend (JPA):** Crear entidad `ConfiguracionParalelo` (id, nombre, activo, orden).
- [x] **Backend (API):** Endpoint `GET /api/configuracion/paralelos` y `PUT /api/configuracion/paralelos` para habilitar/deshabilitar.
- [x] **Frontend:** Conectar la pestaña 2 de `DashboardDirectorParalelosPage` para leer/escribir esta configuración real.

### 1.2 Configuración Institucional (Global)
El formulario de "Configuración General" ya persiste datos en la base de datos.
- [x] **Backend (JPA):** Crear entidad `Institucion` (id, nombre, direccion, sie, logoUrl, gestionActualId).
- [x] **Backend (API):** Endpoints para obtener y actualizar los datos de la institución.
- [x] **Frontend:** Conectar `DashboardDirectorConfiguracionPage` al endpoint real.

---

## 🏃 Sprint 2: Integridad de Datos y Dashboard
**Objetivo:** Asegurar que los números que ve el Director sean reales y consistentes.

### 2.1 Auditoría del Dashboard
- [ ] **Backend:** Revisar `DashboardController.java`. Confirmar que `getStats` haga `count()` reales sobre tablas `Estudiante` (activos), `Profesor` (activos) y `Pago` (ingresos del día).
- [ ] **Frontend:** Verificar que los KPIs en `DashboardDirector` se actualicen correctamente al hacer cambios (ej. crear un estudiante nuevo).

### 2.2 Validación de Horarios
- [ ] **Test:** Verificar la generación de la matriz de horarios. Asegurar que no se permitan choques de horario para un mismo profesor o aula (si aplica).

---

## 🏃 Sprint 3: Módulo Financiero (Bloque Crítico)
**Objetivo:** Implementar la visualización y reportes de pagos para la toma de decisiones. Actualmente la pantalla está "En Desarrollo".

### 3.1 Backend de Reportes Financieros
Ya existen entidades de `Pago`, pero faltan endpoints agregados para reportes.
- [ ] **Endpoint:** `GET /api/reportes/ingresos` (Filtros: diario, mensual, rango fechas).
- [ ] **Endpoint:** `GET /api/reportes/morosos` (Lista de estudiantes con cuotas vencidas).

### 3.2 Frontend - Pantalla de Pagos (`DashboardDirectorPagosPage`)
Reemplazar la pantalla placeholder actual con un dashboard financiero funcional.
- [ ] **Tab 1 - Transacciones Recientes:** Tabla con los últimos pagos recibidos (paginada).
- [ ] **Tab 2 - Reporte Económico:** Selectores de fecha y Gráfico de barras (Ingresos por mes).
- [ ] **Tab 3 - Control de Mora:** Lista de estudiantes deudores con botón para exportar PDF.

---

## 🏃 Sprint 4: Pulido Final y UX
**Objetivo:** Asegurar una experiencia de usuario fluida y libre de errores.

- [ ] **Navegación:** Verificar consistencia del `MainScaffold` y Drawer en todas las pantallas nuevas (Ya avanzado).
- [ ] **Feedback Usuario:** Estandarizar mensajes de error/éxito (Snackbars) en todas las acciones CRUD.
- [ ] **Pruebas de Flujo:** Simular un ciclo completo de año escolar (Apertura gestión -> Configuración cursos -> Inscripción -> Pagos).

---

## 📝 Resumen del Estado Actual vs. Meta

| Módulo | Característica | Estado Actual | Meta del Plan |
| :--- | :--- | :--- | :--- |
| **Configuración** | Paralelos | ✅ Completado | ✅ Entidad Configurable |
| **Configuración** | Datos Institución | ✅ Completado | ✅ Persistente (BD) |
| **Dashboard** | KPIs | ⚠️ Parcial | ✅ Data Real 100% |
| **Finanzas** | Reportes | ❌ "En Desarrollo" | ✅ Dashboard Financiero |

Siguiente paso: **Sprint 2: Integridad de Datos y Dashboard**

