import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/asignacion_docente.dart';
import '../services/asignacion_service.dart';

class AsignacionController extends ChangeNotifier {
  final AsignacionService _service = AsignacionService();
  
  List<AsignacionDocente> _asignaciones = [];
  bool _cargando = false;
  String? _errorMessage;

  List<AsignacionDocente> get asignaciones => _asignaciones;
  bool get cargando => _cargando;
  String? get errorMessage => _errorMessage;

  // Cargar asignaciones de un curso
  Future<void> cargarAsignaciones(int idCurso) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _asignaciones = await _service.listarPorCurso(idCurso);
    } catch (e) {
      _errorMessage = _handleError(e);
      _asignaciones = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Crear nueva asignación
  Future<bool> crearAsignacion(int idCurso, int idMateria, int idProfesor, int idGestion) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.crearAsignacion(idCurso, idMateria, idProfesor, idGestion);
      await cargarAsignaciones(idCurso); // Recargar lista
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Actualizar asignación
  Future<bool> actualizarAsignacion(int idAsignacion, int idCurso, int idMateria, int idProfesor, int idGestion) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _service.actualizarAsignacion(idAsignacion, idCurso, idMateria, idProfesor, idGestion);
      await cargarAsignaciones(idCurso); // Recargar lista
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  // Eliminar asignación
  Future<bool> eliminarAsignacion(int idAsignacion, int idCursoContexto) async {
    try {
      await _service.eliminarAsignacion(idAsignacion);
      // Eliminar localmente para feedback inmediato
      _asignaciones.removeWhere((a) => a.idAsignacion == idAsignacion);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      notifyListeners();
      return false;
    }
  }

  String _handleError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response?.data is Map) {
        return e.response?.data['error'] ?? 'Error desconocido del servidor';
      }
      return 'Error de conexión: ${e.message}';
    }
    return e.toString().replaceAll('Exception:', '').trim();
  }
}
