import 'package:flutter/material.dart';

class MenuItem {
  final String label;
  final IconData icon;
  final String route;

  const MenuItem(this.label, this.icon, this.route);
}

final Map<String, List<MenuItem>> menuPorRol = {
  'director': [
    MenuItem('Dashboard', Icons.dashboard, '/dashboard-director'),
    // MenuItem('Estadísticas', Icons.bar_chart, '/dashboard-director/stats'), // Integrado en Dashboard principal
    MenuItem('Inscripciones', Icons.how_to_reg, '/dashboard-director/inscripciones'),
    MenuItem('Profesores', Icons.person, '/dashboard-director/profesores'),
    MenuItem('Estudiantes', Icons.people, '/dashboard-director/estudiantes'),
    MenuItem('Cursos', Icons.school, '/dashboard-director/cursos'),
    MenuItem('Materias', Icons.book, '/dashboard-director/materias'),
    MenuItem('Asignaciones', Icons.assignment, '/dashboard-director/asignaciones'),
    MenuItem('Horarios', Icons.schedule, '/dashboard-director/horarios'),
    // MenuItem('Eventos Académicos', Icons.event, '/dashboard-director/eventos'), // Fase 3
    // MenuItem('Comunicados Generales', Icons.campaign, '/dashboard-director/comunicados-generales'), // Fase 3
    // MenuItem('Comunicados por Curso', Icons.record_voice_over, '/dashboard-director/comunicados-curso'), // Fase 3
    MenuItem('Pagos', Icons.payments, '/dashboard-director/pagos'),
    MenuItem('Tipos de Pensión', Icons.price_change, '/dashboard-director/tipo-pension'),
    MenuItem('Notas', Icons.grade, '/dashboard-director/notas'),
    MenuItem('Usuarios', Icons.manage_accounts, '/dashboard-director/usuarios'),
  ],
  'secretaria': [
    MenuItem('Dashboard', Icons.dashboard, '/dashboard-secretaria'),
    MenuItem('Estudiantes', Icons.people, '/dashboard-secretaria/estudiantes'),
    MenuItem('Inscripciones', Icons.how_to_reg, '/dashboard-secretaria/inscripciones'),
    MenuItem('Cursos', Icons.school, '/dashboard-secretaria/cursos'),
    MenuItem('Pagos', Icons.payments, '/dashboard-secretaria/pagos'), // Cobro de Pensiones
    MenuItem('Comprobantes', Icons.receipt_long, '/dashboard-secretaria/comprobantes'), // Historial y Reimpresion
    // MenuItem('Facturación', Icons.request_quote, '/dashboard-secretaria/facturacion'), // Redundante o Fase 3
    // MenuItem('Eventos Académicos', Icons.event, '/dashboard-secretaria/eventos'), // Fase 3
  ],
  'profesor': [
    MenuItem('Dashboard', Icons.dashboard, '/dashboard-profesor'),
    MenuItem('Mis Cursos', Icons.class_, '/dashboard-profesor/cursos'), // Incluye Notas y Lista Estudiantes
    MenuItem('Horarios', Icons.schedule, '/dashboard-profesor/horarios'),
    // MenuItem('Estudiantes del Curso', Icons.group, '/dashboard-profesor/inscritos'), // Accesible desde Mis Cursos
    // MenuItem('Notas', Icons.grade, '/dashboard-profesor/cursos'), // Redundante
    // MenuItem('Comunicados por Curso', Icons.record_voice_over, '/dashboard-profesor/comunicados'), // Fase 3
  ],
  'estudiante': [
    MenuItem('Dashboard', Icons.dashboard, '/dashboard-estudiante'),
    MenuItem('Mis Notas', Icons.grade, '/dashboard-estudiante/notas'),
    MenuItem('Pagos', Icons.payments, '/dashboard-estudiante/pagos'), // Ver Deudas
    // MenuItem('Comprobantes', Icons.receipt, '/dashboard-estudiante/comprobantes'), // Implícito en pagos o Fase 3
    // MenuItem('Eventos', Icons.event, '/dashboard-estudiante/eventos'), // Fase 3
    // MenuItem('Comunicados', Icons.campaign, '/dashboard-estudiante/comunicados'), // Fase 3
    MenuItem('Horarios', Icons.schedule, '/dashboard-estudiante/horarios'),
  ],
};
