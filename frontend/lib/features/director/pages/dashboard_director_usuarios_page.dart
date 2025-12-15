import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import 'usuarios_list_page.dart';

class DashboardDirectorUsuariosPage extends StatelessWidget {
  const DashboardDirectorUsuariosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const MainScaffold(
      child: UsuariosListWrapper(),
    );
  }
}
