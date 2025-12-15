# Análisis y Plan para Frontend (Flutter)

Este documento detalla el estado del backend para soportar un frontend móvil/web en Flutter y define la arquitectura recomendada.

## 1. Estado del Backend (Gap Analysis)

### ✅ Módulos Listos para Integrar
Estos módulos tienen controladores funcionales en Java y pueden ser consumidos por Flutter inmediatamente:

*   **Autenticación**: Login (`/auth/login`) y Registro de Colegio.
*   **Gestión Académica**:
    *   Gestiones, Cursos, Paralelos (`GestionAcademicaController`, `CursoController`).
    *   Materias y Malla Curricular (`MateriaController`, `GradoMateriaController`).
    *   Inscripciones (`InscripcionController`).
    *   **Notas**: Registro y visualización (`NotaController`).
*   **Finanzas**:
    *   Definición de cobros (`TipoPensionController`).
    *   Caja y Pagos Estudiantiles (`PagoMensualidadController`).
    *   Reportes básicos (`ReporteFinancieroController`).
*   **Personas**: ABM de Estudiantes, Profesores, Directores.

### ⚠️ Funcionalidades Backend Faltantes
Antes o durante el desarrollo del frontend, se necesitará implementar:

1.  **Recuperación de Contraseña**: No existen endpoints para "Olvidé mi contraseña" (`/auth/forgot-password`).
2.  **Horarios**: No hay modelo ni API para gestionar el horario de clases (días, horas, materias, profesores).
3.  **Comunicados/Avisos**: No existe sistema de notificaciones o muro de avisos (ej. "Reunión de padres").
4.  **Dashboard/Home Completo**: Faltan endpoints agregadores para la pantalla de inicio (ej. "Total Alumnos", "Pagos del Día"). *Workaround: El frontend puede calcular algunos datos listando todo, pero no es óptimo.*

## 2. Arquitectura Recomendada (Flutter)

Dado que se requiere **Web y Mobile**, se recomienda una arquitectura limpia que separe la UI de la lógica.

### Estructura de Proyecto (Clean Architecture)
```text
lib/
├── config/              # Temas, Rutas, Constantes
├── core/                # Cliente HTTP (Dio), Errores, Utils
├── features/            # Módulos del negocio
│   ├── auth/
│   ├── academico/
│   │   ├── data/        # Repositories Impl, Datasources
│   │   ├── domain/      # Entities, Repositories Abstract
│   │   ├── presentation/# Screens (Pages), Widgets, Providers/Blocs
│   └── finanzas/
└── shared/              # Widgets reutilizables (Inputs, Cards, Loaders)
```

### Tecnologías Clave Sugeridas
1.  **Gestor de Estado**: **Flutter Riverpod** o **Bloc**. (Riverpod es excelente para manejo de dependencias y estado inmutable).
2.  **HTTP Client**: **Dio** (Mejor manejo de interceptores para JWT y refresh tokens que http estándar).
3.  **Router**: **GoRouter** (Indispensable para soporte Web y URLs profundas).
4.  **Almacenamiento Local**: **SharedPreferences** o **Hive** (Para guardar el token JWT).
5.  **Diseño**: **Material 3** usando `ThemeData` global para coherencia visual.

## 3. Estrategia de Implementación (Fases Frontend)

### Fase 1: Esqueleto y Auth (Web & Mobile)
*   Setup del proyecto Flutter.
*   Configuración de Dio + Interceptor (Inyectar Token automáticamente).
*   Pantallas: Login, Layout Principal (Drawer/Menu lateral responsivo).
*   Logica: Guardado de Token y redirección según Rol (Director vs Profesor).

### Fase 2: Administración (Web First)
*   Enfocarse en la vista Web para el **Director/Secretaria**.
*   Pantallas: Gestión de Usuarios, Configuración de Cursos, Definición de Pensiones.
*   *Backend*: Utiliza los controladores existentes de `academia` y `finanzas`.

### Fase 3: Operación Diaria (Mobile & Web)
*   Enfocarse en **Profesores** y **Caja**.
*   **Profesor**: Toma de lista (si se añade) y Registro de Notas (Mobile friendly).
*   **Caja**: Cobro rápido de pensiones (Web/Tablet).

### Fase 4: Portal Estudiante/Padre (Mobile First)
*   Consulta de Notas y Deudas financieras.
*   (Requiere endpoint de "Mis Notas" filtraje por usuario logueado).

## 4. Instrucciones para Iniciar
1.  Crear proyecto: `flutter create -e unidad_educativa_app`.
2.  Instalar dependencias clave: `flutter pub add dio flutter_riverpod go_router json_annotation shared_preferences`.
3.  Copiar los assets (logos, imágenes).
4.  Configurar el `BaseUrl` apuntando a:
    *   Android Emulador: `http://10.0.2.2:8080/api`
    *   Web/iOS: `http://localhost:8080/api`
