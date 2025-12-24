import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../../director/services/gestion_service.dart';
import '../services/inscripcion_service.dart';
import 'package:unidad_educatica_frontend/shared/widgets/infinite_scroll_paginator.dart';
import '../models/inscripcion_response.dart';

class ListaMatriculadosPage extends StatefulWidget {
  const ListaMatriculadosPage({super.key});

  @override
  State<ListaMatriculadosPage> createState() => _ListaMatriculadosPageState();
}

class _ListaMatriculadosPageState extends State<ListaMatriculadosPage> {
  final GestionService _gestionService = GestionService();
  final InscripcionService _inscripcionService = InscripcionService();
  final GlobalKey<InfiniteScrollPaginatorState> _paginatorKey = GlobalKey();
  
  bool _isLoadingGestion = true;
  String? _error;
  Gestion? _gestionActiva;
  // Removed local lists and search controller

  @override
  void initState() {
    super.initState();
    _cargarGestion();
  }

  Future<void> _cargarGestion() async {
    setState(() { 
      _isLoadingGestion = true; 
      _error = null;
    });
    
    try {
      // 1. Get active gestion
      final gestiones = await _gestionService.getAll();
      final activa = gestiones.firstWhere((g) => g.activa, orElse: () => gestiones.last);
      
      setState(() {
        _gestionActiva = activa;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingGestion = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Lista de Matriculados ${_gestionActiva != null ? _gestionActiva!.anio : ""}',
      child: Column(
        children: [
          // Header
          if (_error != null)
             Padding(padding: const EdgeInsets.all(8.0), child: Text('Error: $_error', style: const TextStyle(color: Colors.red))),

          // Paginator
          Expanded(
            child: _isLoadingGestion
              ? const Center(child: CircularProgressIndicator())
              : _gestionActiva == null
                ? const Center(child: Text('No hay gestión activa.'))
                : InfiniteScrollPaginator<InscripcionResponseDTO>(
                    key: _paginatorKey,
                    fetchPage: (page, size) => _inscripcionService.listarPorGestionPaginated(_gestionActiva!.idGestion, page: page, size: size),
                    itemBuilder: (context, inscripcion) {
                      final est = inscripcion.estudiante;
                      final curso = inscripcion.curso;
                      final fechaText = inscripcion.fechaInscripcion;
                      // Parse fechaText (assuming strict format string from backend or already parsed in DTO if date? DTO has String)
                      // Backend typically sends YYYY-MM-DD or full timestamp.
                      // Let's try parsing or just display text
                      DateTime? fecha;
                      try {
                          fecha = DateTime.parse(fechaText);
                      } catch (e) {
                          // ignore
                      }

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(est.nombres.isNotEmpty ? est.nombres[0] : 'E', style: const TextStyle(color: Colors.blue)),
                          ),
                          title: Text('${est.nombres} ${est.apellidoPaterno} ${est.apellidoMaterno ?? ''}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.class_, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text('${curso.nombreGrado} "${curso.paralelo}" - ${curso.turno}'),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                                  const SizedBox(width: 4),
                                  Text(fecha != null ? DateFormat('dd/MM/yyyy').format(fecha) : fechaText),
                                ],
                              ),
                            ],
                          ),
                          trailing: Chip(
                            label: Text(inscripcion.estado, style: const TextStyle(fontSize: 10, color: Colors.white)),
                            backgroundColor: (inscripcion.estado == 'RETIRADO') ? Colors.red : Colors.green,
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      );
                    },
                  ),
            ),
        ],
      ),
    );
  }
}
