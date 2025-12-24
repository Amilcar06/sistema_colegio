# 🔗 Análisis Detallado de Conexión Frontend-Backend

Este documento desglosa la verificación de los puntos de conexión (Endpoints) entre el cliente Flutter y el servidor Spring Boot, organizado por Rol.

## 1. 👨‍💼 Rol: Director (Administrador)
**Estado General:** ✅ Conectado
El director tiene acceso a la gestión de usuarios y dashboard.

| Acción | Frontend Service (`UsuarioService/DashboardService`) | Backend Controller (`UsuarioController/DashboardController`) | Estado |
| :--- | :--- | :--- | :--- |
| **Login** | `/auth/login` | `/api/auth/login` | ✅ Correcto |
| **Dashboard** | `/dashboard/stats` | `/api/dashboard/stats` | ✅ Correcto (*) |
| **Listar Usuarios** | `/usuarios` | `/api/usuarios` | ✅ Correcto |
| **Registrar Director** | `/usuarios/registro-director` | `/api/usuarios/registro-director` | ✅ Correcto |
| **Registrar Secretaria**| `/usuarios/registro-secretaria`| `/api/usuarios/registro-secretaria`| ✅ Correcto |
| **Ver Perfil** | `/usuarios/me` | `/api/usuarios/me` | ✅ Correcto |
| **Cambiar Password** | `/usuarios/me/contrasena` | `/api/usuarios/me/contrasena` | ✅ Correcto |

*( * ) Nota: El Backend usa un ID hardcodeado (1L) temporalmente, pero la conexión es funcional.*
*( **Error** ): El frontend llama a `/password` pero el backend espera `/me/contrasena`. Esto fallará con 404.*

## 2. 👩‍💼 Rol: Secretaria
**Estado General:** ✅ Conectado
Gestiona inscripciones, estudiantes y pagos.

| Acción | Frontend Service (`InscripcionService/PagoPensionService`) | Backend Controller (`InscripcionController/PagoMensualidad`) | Estado |
| :--- | :--- | :--- | :--- |
| **Registrar Estudiante**| `/estudiantes/registro` | `/api/estudiantes/registro` | ✅ Correcto |
| **Inscribir** | `/inscripciones` | `/api/inscripciones` | ✅ Correcto |
| **Listar por Gestión** | `/inscripciones/gestion/{id}` | `/api/inscripciones/gestion/{id}` | ✅ Correcto |
| **Registrar Pago** | `/finanzas/pagos` | `/api/finanzas/pagos` | ✅ Correcto |
| **Ver Deudas** | `/finanzas/pagos/estudiante/{id}`| `/api/finanzas/pagos/estudiante/{id}`| ✅ Correcto |
| **Descargar Recibo** | `/reportes/recibo/{id}` | `/api/reportes/recibo/{id}` | ✅ Correcto |

## 3. 👨‍🏫 Rol: Profesor
**Estado General:** ✅ Conectado
Gestiona calificaciones y ve sus cursos asignados.

| Acción | Frontend Service (`ProfesorService`) | Backend Controller (`NotaController`) | Estado |
| :--- | :--- | :--- | :--- |
| **Listar Cursos** | `/asignaciones/mis-cursos` | `/api/asignaciones/mis-cursos` | ✅ Correcto |
| **Ver Libreta** | `/notas/asignacion/{id}/libreta` | `/api/notas/asignacion/{id}/libreta` | ✅ Correcto |
| **Registrar Nota** | `/notas` | `/api/notas` | ✅ Correcto |
| **Actualizar Nota** | `/notas/{id}` | `/api/notas/{id}` | ✅ Correcto |
| **Descargar Lista** | `/reportes/curso/{id}` | `/api/reportes/curso/{id}` | ✅ Correcto |

## 4. 👨‍🎓 Rol: Estudiante
**Estado General:** ✅ Conectado
Consulta su información académica y financiera.

| Acción | Frontend Service (`EstudianteService/NotaService`) | Backend Controller (`EstudianteController/NotaController`) | Estado |
| :--- | :--- | :--- | :--- |
| **Ver Perfil** | `/estudiantes/mi-perfil` | `/api/estudiantes/mi-perfil` | ✅ Correcto |
| **Ver Gestiones** | `/estudiantes/{id}/gestiones` | `/api/estudiantes/{id}/gestiones` | ✅ Correcto |
| **Ver Notas** | `/notas/estudiante/{id}` | `/api/notas/estudiante/{id}` | ✅ Correcto |
| **Ver Deudas** | `/finanzas/pagos/estudiante/{id}`| `/api/finanzas/pagos/estudiante/{id}`| ✅ Correcto |
| **Descargar Boletín** | `/reportes/boletin/{id}` | `/api/reportes/boletin/{id}` | ✅ Correcto |

## 📉 Conclusiones y Correcciones Necesarias

1.  **Bug Crítico en Cambio de Contraseña:**
    *   **Archivo:** `frontend/lib/features/director/services/usuario_service.dart`
    *   **Problema:** Llama a `PUT /usuarios/password`.
    *   **Solución:** Cambiar a `PUT /usuarios/me/contrasena` para coincidir con el backend.

2.  **Estado del SideMenu:**
    *   La navegación (`SideMenu`) redirige a las pantallas correctas, las cuales instancian estos servicios. Al estar los servicios (casi todos) bien mapeados, la integración UI -> Lógica -> Backend es sólida.

El sistema está listo para pruebas integrales, salvo por la corrección del endpoint de contraseña.
