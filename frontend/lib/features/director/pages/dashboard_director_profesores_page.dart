import 'package:flutter/material.dart';
import '../../profesor/pages/profesor_list_page.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardDirectorProfesoresPage extends StatelessWidget {
  const DashboardDirectorProfesoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      child: ProfesorListWrapper(),
    );
  }
}
