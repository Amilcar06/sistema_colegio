import 'package:flutter/material.dart';
import 'package:unidad_educatica_frontend/features/estudiante/pages/estudiante_list_page.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardDirectorEstudiantesPage extends StatelessWidget {
  const DashboardDirectorEstudiantesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      child: EstudianteListWrapper(),
    );
  }
}
