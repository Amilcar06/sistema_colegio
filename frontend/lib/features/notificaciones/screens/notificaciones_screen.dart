import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/notificacion_model.dart';
import '../services/notification_service.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  final NotificationService _service = NotificationService();
  List<NotificacionResponseDTO> notificaciones = [];
  bool cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => cargando = true);
    try {
      final data = await _service.obtenerMisNotificaciones();
      setState(() {
        notificaciones = data;
        cargando = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _marcarLeida(NotificacionResponseDTO n) async {
    if (n.leido) return;
    try {
      await _service.marcarComoLeida(n.idNotificacion);
      // Actualizar localmente
      setState(() {
        final index = notificaciones.indexWhere((element) => element.idNotificacion == n.idNotificacion);
        if (index != -1) {
           // Hack para actualizar inmutables sin copyWith
           notificaciones[index] = NotificacionResponseDTO(
             idNotificacion: n.idNotificacion,
             titulo: n.titulo,
             mensaje: n.mensaje,
             leido: true,
             fechaCreacion: n.fechaCreacion
           );
        }
      });
    } catch (e) {
      // ignore
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : notificaciones.isEmpty
              ? const Center(child: Text('No tienes notificaciones'))
              : ListView.builder(
                  itemCount: notificaciones.length,
                  itemBuilder: (context, index) {
                    final n = notificaciones[index];
                    return Card(
                      color: n.leido ? Colors.white : Colors.blue.shade50,
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      child: ListTile(
                        leading: Icon(
                          n.leido ? Icons.drafts : Icons.mark_email_unread,
                          color: n.leido ? Colors.grey : Colors.blue,
                        ),
                        title: Text(n.titulo, style: TextStyle(fontWeight: n.leido ? FontWeight.normal : FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(n.mensaje),
                            const SizedBox(height: 4),
                            Text(
                              n.fechaCreacion, // Formatear si es necesario
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () => _marcarLeida(n),
                      ),
                    );
                  },
                ),
    );
  }
}
