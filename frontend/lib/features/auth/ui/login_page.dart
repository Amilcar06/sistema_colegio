// lib/features/auth/ui/login_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../core/api.dart';
import '../../../state/auth_provider.dart';
import 'package:go_router/go_router.dart'; // <- Asegúrate de importar esto


class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passController = TextEditingController();
  bool isLoading = false;
  String? error;

  void login() async {
    print("Botón Ingresar presionado"); // DEBUG
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      print("Enviando petición a /auth/login..."); // DEBUG
      print("Datos: ${emailController.text}, ${passController.text}"); // DEBUG

      final response = await dio.post('/auth/login', data: {
        "correo": emailController.text.trim(),
        "password": passController.text.trim(),
      });

      print("Respuesta recibida: ${response.statusCode}"); // DEBUG
      print("Data: ${response.data}"); // DEBUG

      final token = response.data['token'];
      final rol = response.data['rol'];

      print("Token: $token"); // DEBUG
      print("Rol: $rol"); // DEBUG

      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.login(token, rol);

      print("Redirigiendo usuario..."); // DEBUG

      final rolNormalizado = rol.toString().trim().toLowerCase();
      print("Rol normalizado: '$rolNormalizado'"); // DEBUG

      if (rolNormalizado == 'director' || rolNormalizado == 'admin') {
        context.go('/dashboard-director');
      } else if (rolNormalizado == 'profesor') {
        context.go('/dashboard-profesor');
      } else if (rolNormalizado == 'alumno' || rolNormalizado == 'estudiante') {
        context.go('/dashboard-estudiante');
      } else if (rolNormalizado == 'secretaria') {
        context.go('/dashboard-secretaria');
      } else {
        print("Rol desconocido (despues de normalizar): '$rolNormalizado'"); // DEBUG
        setState(() {
          error = "Rol desconocido: $rol";
        });
      }

    } on DioException catch (e) {
      print("Error Dio: $e"); // DEBUG
      print("Respuesta de error: ${e.response?.data}"); // DEBUG
      setState(() {
        if (e.response?.data is Map) {
          error = e.response?.data['message']?.toString() ?? 'Error al iniciar sesión';
        } else {
          error = 'Error de conexión: ${e.response?.statusCode ?? 'Desconocido'}';
        }
      });
    } catch (e) {
      print("Error General: $e"); // DEBUG
      setState(() {
        error = "Error inesperado: $e";
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo'),
            ),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: login,
              child: const Text('Ingresar'),
            ),
          ],
        ),
      ),
    );
  }
}
