import 'package:flutter/material.dart';
import '../models/materia.dart';
import '../services/materia_service.dart';

class MateriaController extends ChangeNotifier {
  final MateriaService _service = MateriaService();

  List<Materia> materias = [];
  bool isLoading = false;
  String? errorMessage;

  MateriaController() {
    cargarMaterias();
  }

  Future<void> cargarMaterias() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      materias = await _service.listarMaterias();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearMateria(String nombre) async {
    try {
      await _service.crearMateria(nombre);
      await cargarMaterias();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminarMateria(int id) async {
    try {
      await _service.eliminarMateria(id);
      await cargarMaterias();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
