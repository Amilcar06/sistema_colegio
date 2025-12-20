import 'package:flutter/material.dart';

abstract class MenuEntry {
  const MenuEntry();
}

class MenuHeader extends MenuEntry {
  final String title;
  const MenuHeader(this.title);
}

class MenuItem extends MenuEntry {
  final String label;
  final IconData icon;
  final String route;

  const MenuItem(this.label, this.icon, this.route);
}

final Map<String, List<MenuEntry>> menuPorRol = {
  'director': [
    // Dashboard
    // const MenuItem('Inicio (Dashboard)', Icons.dashboard, '/dashboard-director'), // Redundant

    // Gestión Institucional
    const MenuHeader('GESTIÓN INSTITUCIONAL'),
    const MenuItem('Gestiones Académicas', Icons.calendar_today, '/dashboard-director/gestiones'),
    const MenuItem('Configuración General', Icons.settings, '/dashboard-director/configuracion'),

    // Gestión Académica
    const MenuHeader('GESTIÓN ACADÉMICA'),
    const MenuItem('Cursos y Grados', Icons.school, '/dashboard-director/cursos'),
    const MenuItem('Paralelos', Icons.view_column, '/dashboard-director/paralelos'),
    const MenuItem('Materias', Icons.menu_book, '/dashboard-director/materias'),
    const MenuItem('Horarios', Icons.schedule, '/dashboard-director/horarios'),
    
    // Gestión de Usuarios
    const MenuHeader('GESTIÓN DE USUARIOS'),
    const MenuItem('Administrativos', Icons.admin_panel_settings, '/dashboard-director/usuarios'),
    const MenuItem('Cuerpo Docente', Icons.person_outline, '/dashboard-director/profesores'),
    const MenuItem('Estudiantes', Icons.people_outline, '/dashboard-director/estudiantes'),
    const MenuItem('Asignaciones', Icons.assignment_ind, '/dashboard-director/asignaciones'),

    // Finanzas
    const MenuHeader('FINANZAS'),
    const MenuItem('Configurar Pensiones', Icons.attach_money, '/dashboard-director/tipo-pension'),
    const MenuItem('Reportes Económicos', Icons.bar_chart, '/dashboard-director/pagos'),
    
    // Social
    const MenuHeader('COMUNIDAD'),
    const MenuItem('Comunicados', Icons.campaign, '/dashboard-director/comunicados-generales'),
    const MenuItem('Eventos', Icons.event, '/dashboard-director/eventos'),
  ],
  'secretaria': [
    // Dashboard
    // const MenuItem('Inicio', Icons.dashboard, '/dashboard-secretaria'),

    // Inscripciones
    const MenuHeader('INSCRIPCIONES'),
    const MenuItem('Nueva Inscripción', Icons.person_add, '/dashboard-secretaria/inscripciones/nueva'),
    const MenuItem('Re-inscripción', Icons.manage_accounts, '/dashboard-secretaria/inscripciones/reinscripcion'),
    const MenuItem('Lista de Matriculados', Icons.list_alt, '/dashboard-secretaria/matriculados'),

    // Estudiantes
    const MenuHeader('ESTUDIANTES'),
    const MenuItem('Kardex / Buscador', Icons.search, '/dashboard-secretaria/estudiantes'),

    // Caja / Cobros
    const MenuHeader('CAJA Y COBROS'),
    const MenuItem('Realizar Cobro', Icons.point_of_sale, '/dashboard-secretaria/cobros'),
    const MenuItem('Historial Transacciones', Icons.receipt_long, '/dashboard-secretaria/transacciones'),
    const MenuItem('Cierre de Caja', Icons.account_balance_wallet, '/dashboard-secretaria/cierre-caja'),
  ],
  'profesor': [
    // const MenuItem('Dashboard', Icons.dashboard, '/dashboard-profesor'),

    const MenuHeader('GESTIÓN ACADÉMICA'),
    const MenuItem('Mis Cursos', Icons.class_, '/dashboard-profesor/cursos'),
    const MenuItem('Horarios', Icons.schedule, '/dashboard-profesor/horarios'),
    // const MenuItem('Estudiantes del Curso', Icons.group, '/dashboard-profesor/inscritos'),
    // const MenuItem('Notas', Icons.grade, '/dashboard-profesor/cursos'),

    const MenuHeader('COMUNICACIÓN'),
    const MenuItem('Comunicados por Curso', Icons.record_voice_over, '/dashboard-profesor/comunicados'),
  ],
  'estudiante': [
    // ACADÉMICO
    const MenuHeader('ACADÉMICO'),
    const MenuItem('Mis Notas', Icons.grade, '/dashboard-estudiante/notas'),
    const MenuItem('Mi Horario', Icons.schedule, '/dashboard-estudiante/horarios'),
    const MenuItem('Mis Materias', Icons.class_, '/dashboard-estudiante/materias'),

    // PAGOS (ESTADO DE CUENTA)
    const MenuHeader('PAGOS'),
    const MenuItem('Estado de Cuenta', Icons.payments, '/dashboard-estudiante/pagos'),
    const MenuItem('Comprobantes', Icons.receipt, '/dashboard-estudiante/comprobantes'),

    // SOCIAL
    const MenuHeader('SOCIAL'),
    const MenuItem('Comunicados', Icons.campaign, '/dashboard-estudiante/comunicados'),
    const MenuItem('Agenda', Icons.event, '/dashboard-estudiante/eventos'),
  ],
};
