import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/ui/login_page.dart';
import '../features/profesor/pages/profesor_list_page.dart';
import '../features/splash/ui/splash_page.dart';
import '../features/director/pages/dashboard_director.dart';
import '../features/secretaria/pages/dashboard_secretaria.dart';
import '../features/profesor/pages/dashboard_profesor.dart';
import '../features/estudiante/pages/dashboard_estudiante.dart';
import '../features/shared/screens/perfil_screen.dart';
import '../features/notificaciones/screens/notificaciones_screen.dart';

// Director Pages
import '../features/director/pages/dashboard_director_inscripciones_page.dart';
import '../features/director/pages/dashboard_director_profesores_page.dart';
import '../features/director/pages/dashboard_director_estudiantes_page.dart';
import '../features/director/pages/dashboard_director_cursos_page.dart';
import '../features/director/pages/dashboard_director_materias_page.dart';
import '../features/director/pages/dashboard_director_asignaciones_page.dart';
import '../features/director/pages/dashboard_director_horarios_page.dart';
import '../features/director/pages/dashboard_director_eventos_page.dart';
import '../features/director/pages/dashboard_director_comunicados_generales_page.dart';
import '../features/director/pages/dashboard_director_comunicados_curso_page.dart';
import '../features/director/pages/dashboard_director_pagos_page.dart';
import '../features/director/pages/dashboard_director_tipo_pension_page.dart';
import '../features/director/pages/dashboard_director_notas_page.dart';
import '../features/director/pages/dashboard_director_usuarios_page.dart';
import '../features/director/pages/dashboard_director_gestiones_page.dart';
import '../features/director/pages/dashboard_director_configuracion_page.dart';
import '../features/director/pages/dashboard_director_paralelos_page.dart';

// Secretaria Pages
import '../features/secretaria/pages/dashboard_secretaria_inscripciones_nueva_page.dart';
import '../features/secretaria/pages/dashboard_secretaria_inscripciones_reinscripcion_page.dart';
import '../features/secretaria/pages/dashboard_secretaria_matriculados_page.dart';
import '../features/secretaria/pages/dashboard_secretaria_kardex_page.dart';
import '../features/secretaria/pages/dashboard_secretaria_eventos_page.dart';
// New Secretary Pages
import '../features/secretaria/pages/dashboard_secretaria_cobros_page.dart';
import '../features/secretaria/pages/dashboard_secretaria_transacciones_page.dart';
import '../features/secretaria/pages/dashboard_secretaria_cierre_caja_page.dart';

// Profesor Pages
import '../features/profesor/pages/cursos_asignados_page.dart';
import '../features/profesor/pages/registro_notas_page.dart';
import '../features/profesor/pages/dashboard_profesor_horarios_page.dart';
import '../features/profesor/pages/dashboard_profesor_inscritos_page.dart';
import '../features/profesor/pages/dashboard_profesor_comunicados_page.dart';

// Alumno Pages
import '../features/estudiante/pages/dashboard_estudiante_notas_page.dart';
import '../features/estudiante/pages/dashboard_estudiante_pagos_page.dart';
import '../features/estudiante/pages/dashboard_estudiante_comprobantes_page.dart';
import '../features/estudiante/pages/dashboard_estudiante_eventos_page.dart';
import '../features/estudiante/pages/dashboard_estudiante_comunicados_page.dart';
import '../features/estudiante/pages/dashboard_estudiante_horarios_page.dart';
import '../features/estudiante/pages/dashboard_estudiante_materias_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
    ),
    GoRoute(
      path: '/perfil',
      builder: (_, __) => const PerfilScreen(),
    ),
    GoRoute(
      path: '/notificaciones',
      builder: (_, __) => const NotificacionesScreen(),
    ),

    // Director
    GoRoute(
      path: '/dashboard-director',
      builder: (_, __) => const DashboardDirector(),
    ),
    GoRoute(
      path: '/dashboard-director/inscripciones',
      builder: (_, __) => const DashboardDirectorInscripcionesPage(),
    ),
    GoRoute(
      path: '/dashboard-director/profesores',
      builder: (_, __) => const DashboardDirectorProfesoresPage(),
    ),
    GoRoute(
      path: '/dashboard-director/estudiantes',
      builder: (_, __) => const DashboardDirectorEstudiantesPage(),
    ),
    GoRoute(
      path: '/dashboard-director/cursos',
      builder: (_, __) => const DashboardDirectorCursosPage(),
    ),
    GoRoute(
      path: '/dashboard-director/paralelos',
      builder: (_, __) => const DashboardDirectorParalelosPage(),
    ),
    GoRoute(
      path: '/dashboard-director/materias',
      builder: (_, __) => const DashboardDirectorMateriasPage(),
    ),
    GoRoute(
      path: '/dashboard-director/asignaciones',
      builder: (_, __) => const DashboardDirectorAsignacionesPage(),
    ),
    GoRoute(
      path: '/dashboard-director/horarios',
      builder: (_, __) => const DashboardDirectorHorariosPage(),
    ),
    GoRoute(
      path: '/dashboard-director/eventos',
      builder: (_, __) => const DashboardDirectorEventosPage(),
    ),
    GoRoute(
      path: '/dashboard-director/comunicados-generales',
      builder: (_, __) => const DashboardDirectorComunicadosGeneralesPage(),
    ),
    GoRoute(
      path: '/dashboard-director/comunicados-curso',
      builder: (_, __) => const DashboardDirectorComunicadosCursoPage(),
    ),
    GoRoute(
      path: '/dashboard-director/pagos',
      builder: (_, __) => const DashboardDirectorPagosPage(),
    ),
    GoRoute(
      path: '/dashboard-director/tipo-pension',
      builder: (_, __) => const DashboardDirectorTipoPensionPage(),
    ),
    GoRoute(
      path: '/dashboard-director/notas',
      builder: (_, __) => const DashboardDirectorNotasPage(),
    ),
    GoRoute(
      path: '/dashboard-director/usuarios',
      builder: (_, __) => const DashboardDirectorUsuariosPage(),
    ),
    GoRoute(
      path: '/dashboard-director/gestiones',
      builder: (_, __) => const DashboardDirectorGestionesPage(),
    ),
    GoRoute(
      path: '/dashboard-director/configuracion',
      builder: (_, __) => const DashboardDirectorConfiguracionPage(),
    ),
    GoRoute(
      path: '/directores/profesores',
      builder: (context, state) => const ProfesorListWrapper(),
    ),

    // Secretaria
    GoRoute(
      path: '/dashboard-secretaria',
      builder: (_, __) => const DashboardSecretaria(),
    ),
    // Inscripciones
    GoRoute(
      path: '/dashboard-secretaria/inscripciones/nueva',
      builder: (_, __) => const NuevaInscripcionPage(),
    ),
    GoRoute(
      path: '/dashboard-secretaria/inscripciones/reinscripcion',
      builder: (_, __) => const ReinscripcionPage(),
    ),
    GoRoute(
      path: '/dashboard-secretaria/matriculados',
      builder: (_, __) => const ListaMatriculadosPage(),
    ),
    // Estudiantes
    GoRoute(
      path: '/dashboard-secretaria/estudiantes',
      builder: (_, __) => const KardexEstudiantePage(),
    ),
    // Caja y Cobros
    GoRoute(
      path: '/dashboard-secretaria/cobros',
      builder: (_, __) => const CobrarPensionPage(),
    ),
    GoRoute(
      path: '/dashboard-secretaria/transacciones',
      builder: (_, __) => const HistorialTransaccionesPage(),
    ),
    GoRoute(
      path: '/dashboard-secretaria/cierre-caja',
      builder: (_, __) => const CierreCajaPage(),
    ),

    // Profesor
    GoRoute(
      path: '/dashboard-profesor',
      builder: (_, __) => const DashboardProfesor(),
    ),
    GoRoute(
      path: '/dashboard-profesor/cursos',
      builder: (_, __) => const CursosAsignadosPage(),
    ),
    GoRoute(
      path: '/dashboard-profesor/horarios',
      builder: (_, __) => const DashboardProfesorHorariosPage(),
    ),
    GoRoute(
      path: '/dashboard-profesor/inscritos',
      builder: (_, __) => const DashboardProfesorInscritosPage(idAsignacion: ''), // Default or handle empty
    ),
    GoRoute(
      path: '/dashboard-profesor/estudiantes/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return DashboardProfesorInscritosPage(idAsignacion: id);
      },
    ),
    GoRoute(
      path: '/dashboard-profesor/notas/:id',
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        return RegistroNotasPage(idAsignacion: id);
      },
    ),
    GoRoute(
      path: '/dashboard-profesor/comunicados',
      builder: (_, __) => const DashboardProfesorComunicadosPage(),
    ),


    // Estudiante
    GoRoute(
      path: '/dashboard-estudiante',
      builder: (_, __) => const DashboardEstudiante(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/notas',
      builder: (_, __) => const DashboardEstudianteNotasPage(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/pagos',
      builder: (_, __) => const DashboardEstudiantePagosPage(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/comprobantes',
      builder: (_, __) => const DashboardEstudianteComprobantesPage(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/eventos',
      builder: (_, __) => const DashboardEstudianteEventosPage(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/comunicados',
      builder: (_, __) => const DashboardEstudianteComunicadosPage(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/horarios',
      builder: (_, __) => const DashboardEstudianteHorariosPage(),
    ),
    GoRoute(
      path: '/dashboard-estudiante/materias',
      builder: (_, __) => const DashboardEstudianteMateriasPage(),
    ),
  ],
);
