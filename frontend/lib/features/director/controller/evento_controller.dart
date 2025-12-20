import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../comunicacion/models/evento.dart';
import '../services/evento_service.dart';

class EventoController extends ChangeNotifier {
  final EventoService _service = EventoService();
  
  List<Evento> _eventos = [];
  bool _cargando = false;
  String? _errorMessage;

  List<Evento> get eventos => _eventos;
  bool get cargando => _cargando;
  String? get errorMessage => _errorMessage;

  Future<void> cargarEventos() async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventos = await _service.listar();
    } catch (e) {
      _errorMessage = _handleError(e);
      _eventos = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<void> cargarHistorial() async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _eventos = await _service.listarHistorial();
    } catch (e) {
      _errorMessage = _handleError(e);
      _eventos = [];
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> crearEvento(Map<String, dynamic> data) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.crear(data);
      await cargarEventos();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarEvento(int id, Map<String, dynamic> data) async {
    _cargando = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _service.actualizar(id, data);
      await cargarEventos();
      return true;
    } catch (e) {
      _errorMessage = _handleError(e);
      return false;
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<bool> eliminarEvento(int id) async {
    try {
      await _service.eliminar(id);
      _eventos.removeWhere((e) => e.idEvento == id);
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
