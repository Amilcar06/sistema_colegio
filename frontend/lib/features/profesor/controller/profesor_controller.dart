import 'package:flutter/material.dart';
import '../models/profesor_response.dart';
import '../models/profesor_registro_completo.dart';
import '../services/profesor_service.dart';

class ProfesorController with ChangeNotifier {
  final ProfesorService _service = ProfesorService();

  List<ProfesorResponseDTO> profesores = [];
  bool cargando = false;
  String? errorMessage;

  /// Carga todos los profesores desde el backend
  Future<void> cargarProfesores() async {
    cargando = true;
    errorMessage = null;
    notifyListeners();

    try {
      profesores = await _service.listarProfesores();
    } catch (e) {
      errorMessage = 'Error al cargar profesores: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Registra un nuevo profesor y recarga la lista
  Future<bool> registrar(ProfesorRegistroCompletoDTO dto) async {
    errorMessage = null;
    try {
      await _service.registrarProfesorCompleto(dto);
      await cargarProfesores();
      return true;
    } catch (e) {
      errorMessage = 'Error al registrar profesor: $e';
      return false;
    }
  }

  /// Elimina un profesor por su ID y recarga la lista
  Future<bool> eliminarProfesor(int idProfesor) async {
    errorMessage = null;
    try {
      await _service.eliminarProfesor(idProfesor);
      await cargarProfesores();
      return true;
    } catch (e) {
      errorMessage = 'Error al eliminar profesor: $e';
      notifyListeners();
      return false;
    }
  }

  ProfesorResponseDTO? profesorSeleccionado;

  void seleccionarParaEdicion(ProfesorResponseDTO prof) {
    profesorSeleccionado = prof;
    notifyListeners();
  }

  void cancelarEdicion() {
    profesorSeleccionado = null;
    notifyListeners();
  }

  Future<bool> actualizar(ProfesorRegistroCompletoDTO dto) async {
    if (profesorSeleccionado == null || profesorSeleccionado?.idProfesor == null) {
      errorMessage = 'No hay profesor seleccionado para actualizar';
      return false;
    }
    try {
      await _service.actualizarProfesor(profesorSeleccionado!.idProfesor, dto);
      profesorSeleccionado = null;
      await cargarProfesores();
      return true;
    } catch (e) {
      errorMessage = 'Error al actualizar profesor: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> cambiarEstado(ProfesorResponseDTO prof, bool activar) async {
    try {
      if (activar) {
        await _service.activarProfesor(prof.idProfesor);
      } else {
        await _service.desactivarProfesor(prof.idProfesor);
      }
      await cargarProfesores();
    } catch (e) {
      errorMessage = 'Error al cambiar estado: $e';
      notifyListeners();
    }
  }

  Future<void> verDetallesProfesor(int idProfesor, BuildContext context) async {
    try {
      final prof = await _service.obtenerProfesorPorId(idProfesor);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${prof.nombres} ${prof.apellidoPaterno} ${prof.apellidoMaterno}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CI: ${prof.ci}'),
              Text('Correo: ${prof.correo}'),
              Text('Teléfono: ${prof.telefono}'),
              Text('Profesión: ${prof.profesion ?? 'No especificada'}'),
              Text('Estado: ${prof.estado == true ? 'Activo' : 'Inactivo'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      errorMessage = 'No se pudo obtener el profesor: $e';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    }
  }

}
