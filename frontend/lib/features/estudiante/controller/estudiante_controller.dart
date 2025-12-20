import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:unidad_educatica_frontend/features/estudiante/models/estudiante_request.dart';
import '../models/estudiante_response.dart';
import '../models/estudiante_registro_completo.dart';
import '../services/estudiante_service.dart';
import 'package:intl/intl.dart';

class EstudianteController with ChangeNotifier {
  final EstudianteService _service = EstudianteService();

  List<EstudianteResponseDTO> estudiantes = [];
  bool cargando = false;
  String? errorMessage;

  EstudianteResponseDTO? estudianteSeleccionado;

  /// Cargar todos los estudiantes desde el backend
  Future<void> cargarEstudiantes() async {
    cargando = true;
    errorMessage = null;
    notifyListeners();

    try {
      estudiantes = await _service.listar();
    } catch (e) {
      errorMessage = 'Error al cargar estudiantes: $e';
    } finally {
      cargando = false;
      notifyListeners();
    }
  }

  /// Registrar nuevo estudiante
  Future<EstudianteResponseDTO?> registrar(EstudianteRegistroCompletoDTO dto) async {
    errorMessage = null;
    try {
      final nuevoEstudiante = await _service.registrarEstudianteCompleto(dto);
      await cargarEstudiantes();
      return nuevoEstudiante;
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        } else {
          errorMessage = 'Error al registrar estudiante: ${e.message}';
        }
      } else {
        errorMessage = 'Error al registrar estudiante: $e';
      }
      return null;
    }
  }

  /// Seleccionar estudiante para edición
  void seleccionarParaEdicion(EstudianteResponseDTO est) {
    estudianteSeleccionado = est;
    notifyListeners();
  }

  /// Cancelar selección para edición
  void cancelarEdicion() {
    estudianteSeleccionado = null;
    notifyListeners();
  }

  /// Actualizar estudiante seleccionado
  Future<bool> actualizar(EstudianteRegistroCompletoDTO dto) async {
    if (estudianteSeleccionado == null || estudianteSeleccionado?.idEstudiante == null) {
      errorMessage = 'No hay estudiante seleccionado para actualizar';
      return false;
    }
    try {
      await _service.actualizarEstudiante(estudianteSeleccionado!.idEstudiante, dto);
      estudianteSeleccionado = null;
      await cargarEstudiantes();
      return true;
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        } else {
          errorMessage = 'Error al actualizar estudiante: ${e.message}';
        }
      } else {
        errorMessage = 'Error al actualizar estudiante: $e';
      }
      notifyListeners();
      return false;
    }
  }

  /// Eliminar estudiante
  Future<bool> eliminarEstudiante(int idEstudiante) async {
    errorMessage = null;
    try {
      await _service.eliminar(idEstudiante);
      await cargarEstudiantes();
      return true;
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        } else {
          errorMessage = 'Error al eliminar estudiante: ${e.message}';
        }
      } else {
        errorMessage = 'Error al eliminar estudiante: $e';
      }
      notifyListeners();
      return false;
    }
  }

  /// Activar o desactivar estudiante
  Future<void> cambiarEstado(EstudianteResponseDTO est, bool activar) async {
    try {
      if (activar) {
        await _service.activarEstudiante(est.idEstudiante);
      } else {
        await _service.desactivarEstudiante(est.idEstudiante);
      }
      await cargarEstudiantes();
    } catch (e) {
      if (e is DioException && e.response?.data is Map) {
        final data = e.response?.data as Map;
        if (data.containsKey('error')) {
          errorMessage = data['error'].toString();
        } else {
          errorMessage = 'Error al cambiar estado: ${e.message}';
        }
      } else {
        errorMessage = 'Error al cambiar estado: $e';
      }
      notifyListeners();
    }
  }

  /// Ver detalles en un modal
  Future<void> verDetallesEstudiante(int idEstudiante, BuildContext context) async {
    try {
      final est = await _service.obtenerEstudiantePorId(idEstudiante);
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('${est.nombres} ${est.apellidoPaterno} ${est.apellidoMaterno ?? ''}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('CI: ${est.ci}'),
              Text(
                'Fecha de Nacimiento: ${est.fechaNacimiento != null
                    ? DateFormat("d 'de' MMMM 'de' y", 'es').format(est.fechaNacimiento!)
                    : 'No registrada'}',
              ),
              Text('Correo: ${est.correo}'),
              Text('Dirección: ${est.direccion}'),
              Text('Teléfono Padre: ${est.telefonoPadre}'),
              Text('Teléfono Madre: ${est.telefonoMadre}'),
              Text('Estado: ${est.estado ? 'Activo' : 'Inactivo'}'),
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
      errorMessage = 'No se pudo obtener el estudiante: $e';
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage!)),
      );
    }
  }
}
