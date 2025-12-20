# 📱 Análisis Técnico del Frontend

Este documento detalla la arquitectura, usabilidad y estado técnico del frontend (Flutter), ubicado en `frontend/lib`.

## 1. 🏗️ Arquitectura y Estructura
El proyecto sigue una arquitectura **"Clean Architecture" simplificada por Features**. Esto significa que el código está organizado por los módulos funcionales que ve el usuario, en lugar de por capas técnicas abstractas.

### Estructura de Directorios
*   `lib/features/`: Dividido por roles (`director`, `secretaria`, `profesor`, `estudiante`) y módulos compartidos (`auth`, `shared`).
    *   Cada feature tiene su micro-estructura: `pages/`, `widgets/`, `services/`, `models/`, `controller/`.
*   `lib/core/`: Configuración global (`api.dart`, `router/`).
*   `lib/state/`: Estado global de autenticación (`AuthProvider`).
*   `lib/routes/`: Definición central de rutas (`GoRouter`).

**Ventajas:**
*   **Modularidad:** Es fácil trabajar en el módulo de "Director" sin romper nada de "Estudiante".
*   **Escalabilidad UI:** Separar `pages` (pantallas completas) de `widgets` (componentes reusables) es una buena práctica.

## 2. ⚡ Gestión de Estado y Rutas
*   **State Management:** Usa **Provider**.
    *   `MultiProvider` en `main.dart` inyecta `AuthProvider` y `UsuarioController` globalmente.
    *   Ventaja: Simple, efectivo para este tamaño de app.
*   **Routing:** Usa **GoRouter**.
    *   Manejo de rutas declarativo (`/login`, `/dashboard-director`).
    *   Permite manejo de parámetros (`/dashboard-profesor/notas/:id`).

## 3. 🛡️ Seguridad y Conectividad
*   **Cliente HTTP:** **Dio**.
    *   Configurado en `core/api.dart`.
    *   **Interceptor:** Inyecta automáticamente el header `Authorization: Bearer <token>` en cada petición.
*   **Persistencia:** **FlutterSecureStorage**.
    *   Guarda el JWT de forma segura en el dispositivo (Keychain en iOS, Keystore en Android).
*   **Atención (Punto de Mejora):**
    *   Al reiniciar la app, el `AuthProvider` recupera el token pero **no recupera explícitamente el rol** (según `checkAuthOnStart`). Si el token es válido pero el rol es null, la UI podría no saber a qué dashboard redirigir. Se recomienda implementar endpoint `/auth/me` al inicio.

## 4. 🎨 Diseño y UX
*   **Estilo:** "Material Design 3" (Default).
*   **Theming:** No existe una personalización profunda (`theme.dart` está vacío). Usa los colores por defecto de Flutter (Azul).
*   **Responsividad:**
    *   Usa `SideMenu` para navegación, lo cual funciona bien en Web/Desktop.
    *   En móviles, el menú lateral podría requerir ajuste (Drawer) para mejorar la experiencia.

## 5. 🎯 Alcance: Lo que Resuelve vs. Fuera de Alcance

| ✅ Resuelve Bien | ❌ Fuera de Alcance (MVP) |
| :--- | :--- |
| **Navegación por Roles:** Cada usuario ve solo lo que le corresponde. | **Offline Mode:** La app necesita internet 100% para funcionar. |
| **Formularios Complejos:** Validaciones de registro de estudiantes y profesores. | **Animaciones Avanzadas:** Las transiciones son las estándar. |
| **Feedback Visual:** Muestra errores (Snackbars) si falla el backend. | **Modo Oscuro:** No tiene soporte nativo configurado aún. |
| **Gestión de Archivos:** Permite subir fotos y muestra imágenes. | **Chat en Tiempo Real:** Las notificaciones son asíncronas (pull), no WebSockets. |

## 6. 💡 Conclusión y Recomendaciones
El frontend tiene una estructura **clara y profesional**.

**¿Hay que reordenar?** NO.
La separación por roles en `features` es la decisión correcta para una app con perfiles tan distintos.