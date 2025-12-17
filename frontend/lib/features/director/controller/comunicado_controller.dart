import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../comunicacion/models/comunicado.dart';
import '../services/comunicado_service.dart';

class ComunicadoController extends ChangeNotifier {
  final ComunicadoService _service = ComunicadoService();
  
  List<Comunicado> _comunicados = [];
  bool _cargando = false;
  String? _errorMessage;

  List<Comunicado> get comunicados => _comunicados;
  bool get cargando => _cargando;
  String? get errorMessage => _errorMessage;

  Future<void> cargarComunicados() async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _comunicados = await _service.listar();
    } catch (e) {
      _errorMessage = _handleError(e);
      _comunicados = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crearComunicado(Map<String, dynamic> data) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.crear(data);
      await cargarComunicados();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _cargando = false; // cargarComunicados ya lo pone en false, pero por seguridad
      notifyListeners();
    }
  }

  Future<bool> actualizarComunicado(int id, Map<String, dynamic> data) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.actualizar(id, data);
      await cargarComunicados();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarComunicado(int id) async {
    try {
      // Optimistic delete or wait? Let's wait.
      await _service.eliminar(id);
      _comunicados.removeWhere((c) => c.idComunicado == id);
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
    }
    return e.toString().replaceAll('Exception:', '').trim();
  }
}
