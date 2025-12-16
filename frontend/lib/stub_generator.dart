import 'dart:io';

final Map<String, List<Map<String, String>>> menuPorRol = {
  'director': [
    {'label': 'Estadísticas', 'route': '/dashboard-director/stats'},
    {'label': 'Inscripciones', 'route': '/dashboard-director/inscripciones'},
    {'label': 'Profesores', 'route': '/dashboard-director/profesores'},
    {'label': 'Estudiantes', 'route': '/dashboard-director/estudiantes'},
    {'label': 'Cursos', 'route': '/dashboard-director/cursos'},
    {'label': 'Materias', 'route': '/dashboard-director/materias'},
    {'label': 'Asignaciones', 'route': '/dashboard-director/asignaciones'},
    {'label': 'Horarios', 'route': '/dashboard-director/horarios'},
    {'label': 'Eventos Académicos', 'route': '/dashboard-director/eventos'},
    {'label': 'Comunicados Generales', 'route': '/dashboard-director/comunicados-generales'},
    {'label': 'Comunicados por Curso', 'route': '/dashboard-director/comunicados-curso'},
    {'label': 'Pagos', 'route': '/dashboard-director/pagos'},
    {'label': 'Tipos de Pensión', 'route': '/dashboard-director/tipo-pension'},
    {'label': 'Notas', 'route': '/dashboard-director/notas'},
    {'label': 'Usuarios', 'route': '/dashboard-director/usuarios'},
  ],
  'secretaria': [
    {'label': 'Estudiantes', 'route': '/dashboard-secretaria/estudiantes'},
    {'label': 'Inscripciones', 'route': '/dashboard-secretaria/inscripciones'},
    {'label': 'Cursos', 'route': '/dashboard-secretaria/cursos'},
    {'label': 'Pagos', 'route': '/dashboard-secretaria/pagos'},
    {'label': 'Comprobantes', 'route': '/dashboard-secretaria/comprobantes'},
    {'label': 'Facturación', 'route': '/dashboard-secretaria/facturacion'},
    {'label': 'Eventos Académicos', 'route': '/dashboard-secretaria/eventos'},
  ],
  'profesor': [
    {'label': 'Mis Cursos', 'route': '/dashboard-profesor/cursos'},
    {'label': 'Horarios', 'route': '/dashboard-profesor/horarios'},
    {'label': 'Estudiantes del Curso', 'route': '/dashboard-profesor/inscritos'},
    {'label': 'Notas', 'route': '/dashboard-profesor/notas'},
    {'label': 'Comunicados por Curso', 'route': '/dashboard-profesor/comunicados'},
  ],
  'estudiante': [
    {'label': 'Mis Notas', 'route': '/dashboard-estudiante/notas'},
    {'label': 'Pagos', 'route': '/dashboard-estudiante/pagos'},
    {'label': 'Comprobantes', 'route': '/dashboard-estudiante/comprobantes'},
    {'label': 'Eventos', 'route': '/dashboard-estudiante/eventos'},
    {'label': 'Comunicados', 'route': '/dashboard-estudiante/comunicados'},
    {'label': 'Horarios', 'route': '/dashboard-estudiante/horarios'},
  ],
};

String toSnakeCase(String input) {
  return input.toLowerCase().replaceAll('/', '_').replaceAll('-', '_').replaceAll('__', '_').replaceAll(RegExp(r'^_'), '');
}

Future<void> main() async {
  for (final rol in menuPorRol.keys) {
    final pages = menuPorRol[rol]!;
    final dir = Directory('lib/features/$rol/pages');
    if (!await dir.exists()) await dir.create(recursive: true);

    for (final item in pages) {
      final route = item['route']!;
      final label = item['label']!;
      final name = toSnakeCase(route.replaceFirst('/', ''));
      final fileName = '${name}_page.dart';
      final file = File('${dir.path}/$fileName');

      final className = name.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join() + 'Page';

      final content = '''
      import 'package:flutter/material.dart';
      import '../../../shared/widgets/main_scaffold.dart';
      
      class $className extends StatelessWidget {
        const $className({super.key});
      
        @override
        Widget build(BuildContext context) {
          return const MainScaffold(
            child: Center(child: Text('Página: $label')),
          );
        }
      }
      ''';

      await file.writeAsString(content);
      print('Generado: ${file.path}');
    }
  }
}
