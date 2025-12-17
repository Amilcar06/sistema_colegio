import 'package:flutter/material.dart';
import '../models/curso.dart';
import '../models/grado.dart';
import '../services/curso_service.dart';

class CursoController extends ChangeNotifier {
  final CursoService _service = CursoService();

  List<Curso> cursos = [];
  List<Grado> grados = []; // Para el dropdown de creación
  bool isLoading = false;
  String? errorMessage;

  CursoController() {
    cargarCursos();
    cargarGrados();
  }

  Future<void> cargarCursos() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      cursos = await _service.listarCursos();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarGrados() async {
    try {
      grados = await _service.listarGrados();
      notifyListeners();
    } catch (e) {
      print("Error cargando grados: $e");
    }
  }

  Future<bool> crearCurso(int idGrado, String paralelo, String turno) async {
    try {
      await _service.crearCurso(idGrado, paralelo, turno);
      await cargarCursos(); // Recargar lista
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateCurso(int id, int idGrado, String paralelo, String turno) async {
    try {
      await _service.updateCurso(id, idGrado, paralelo, turno);
      await cargarCursos();
      return true;
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> eliminarCurso(int id) async {
    try {
      await _service.eliminarCurso(id);
      await cargarCursos();
    } catch (e) {
      errorMessage = e.toString();
      notifyListeners();
    }
  }
}
