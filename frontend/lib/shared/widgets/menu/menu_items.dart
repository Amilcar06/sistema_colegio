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
    MenuItem('Estadísticas', Icons.bar_chart, '/dashboard-director/stats'),
    MenuItem('Inscripciones', Icons.how_to_reg, '/dashboard-director/inscripciones'),
    MenuItem('Profesores', Icons.person, '/dashboard-director/profesores'),
    MenuItem('Estudiantes', Icons.people, '/dashboard-director/estudiantes'),
    MenuItem('Cursos', Icons.school, '/dashboard-director/cursos'),
    MenuItem('Materias', Icons.book, '/dashboard-director/materias'),
    MenuItem('Asignaciones', Icons.assignment, '/dashboard-director/asignaciones'),
    MenuItem('Horarios', Icons.schedule, '/dashboard-director/horarios'),
    MenuItem('Eventos Académicos', Icons.event, '/dashboard-director/eventos'),
    MenuItem('Comunicados Generales', Icons.campaign, '/dashboard-director/comunicados-generales'),
    MenuItem('Comunicados por Curso', Icons.record_voice_over, '/dashboard-director/comunicados-curso'),
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
    MenuItem('Pagos', Icons.payments, '/dashboard-secretaria/pagos'),
    MenuItem('Comprobantes', Icons.receipt_long, '/dashboard-secretaria/comprobantes'),
    MenuItem('Facturación', Icons.request_quote, '/dashboard-secretaria/facturacion'),
    MenuItem('Eventos Académicos', Icons.event, '/dashboard-secretaria/eventos'),
  ],
  'profesor': [
    MenuItem('Dashboard', Icons.dashboard, '/dashboard-profesor'),
    MenuItem('Mis Cursos', Icons.class_, '/dashboard-profesor/cursos'),
    MenuItem('Horarios', Icons.schedule, '/dashboard-profesor/horarios'),
    MenuItem('Estudiantes del Curso', Icons.group, '/dashboard-profesor/inscritos'),
    MenuItem('Notas', Icons.grade, '/dashboard-profesor/cursos'),
    MenuItem('Comunicados por Curso', Icons.record_voice_over, '/dashboard-profesor/comunicados'),
  ],
  'estudiante': [
    MenuItem('Dashboard', Icons.dashboard, '/dashboard-estudiante'),
    MenuItem('Mis Notas', Icons.grade, '/dashboard-estudiante/notas'),
    MenuItem('Pagos', Icons.payments, '/dashboard-estudiante/pagos'),
    MenuItem('Comprobantes', Icons.receipt, '/dashboard-estudiante/comprobantes'),
    MenuItem('Eventos', Icons.event, '/dashboard-estudiante/eventos'),
    MenuItem('Comunicados', Icons.campaign, '/dashboard-estudiante/comunicados'),
    MenuItem('Horarios', Icons.schedule, '/dashboard-estudiante/horarios'),
  ],
};
