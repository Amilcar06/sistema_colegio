import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardEstudianteMateriasPage extends StatelessWidget {
  const DashboardEstudianteMateriasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      title: 'Mis Materias',
      child: Center(
        child: Text('Lista de materias asignadas (Próximamente)'),
      ),
    );
  }
}
