import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'state/auth_provider.dart';
import 'features/director/controller/usuarios_controller.dart';
import 'routes/app_router.dart';
import 'core/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkAuthOnStart()),
        ChangeNotifierProvider(create: (_) => UsuarioController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Portal Educativo',
      routerConfig: appRouter,
      theme: AppTheme.getTheme(),
      debugShowCheckedModeBanner: false,
    );
  }
}
