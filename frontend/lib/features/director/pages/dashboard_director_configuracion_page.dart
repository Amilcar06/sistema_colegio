import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';
import '../models/institucion.dart';
import '../services/institucion_service.dart';

class DashboardDirectorConfiguracionPage extends StatefulWidget {
  const DashboardDirectorConfiguracionPage({super.key});

  @override
  State<DashboardDirectorConfiguracionPage> createState() => _DashboardDirectorConfiguracionPageState();
}

class _DashboardDirectorConfiguracionPageState extends State<DashboardDirectorConfiguracionPage> {
  final _formKey = GlobalKey<FormState>();
  final _institucionService = InstitucionService();
  bool _isLoading = true;
  String? _errorMessage;
  int? _idUnidadEducativa; // Store ID for update

  // Controllers
  final _nombreCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _sieCtrl = TextEditingController();
  final _logoUrlCtrl = TextEditingController(); // Assuming logoUrl editing might be needed or kept hidden/default

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _institucionService.obtenerDatos();
      setState(() {
        _idUnidadEducativa = data.idUnidadEducativa;
        _nombreCtrl.text = data.nombre;
        _direccionCtrl.text = data.direccion ?? '';
        _sieCtrl.text = data.sie;
        _logoUrlCtrl.text = data.logoUrl ?? '';
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $_errorMessage')));
      }
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final nuevaConfig = Institucion(
        idUnidadEducativa: _idUnidadEducativa, // Pass ID if available
        nombre: _nombreCtrl.text.trim(),
        sie: _sieCtrl.text.trim(),
        direccion: _direccionCtrl.text.trim(),
        logoUrl: _logoUrlCtrl.text.trim(), // Optional
      );

      await _institucionService.actualizarDatos(nuevaConfig);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Configuración guardada exitosamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Configuración General',
      child: _isLoading && _nombreCtrl.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Datos de la Institución', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    
                    TextFormField(
                      controller: _nombreCtrl,
                      decoration: const InputDecoration(labelText: 'Nombre de la Unidad Educativa', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _direccionCtrl,
                      decoration: const InputDecoration(labelText: 'Dirección', border: OutlineInputBorder()),
                      validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _sieCtrl,
                      decoration: const InputDecoration(labelText: 'Código SIE', border: OutlineInputBorder()),
                       validator: (v) => v!.isEmpty ? 'Requerido' : null,
                    ),
                    const SizedBox(height: 30),
                    
                    if (_isLoading)
                        const Center(child: CircularProgressIndicator())
                    else
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _guardarCambios,
                            icon: const Icon(Icons.save),
                            label: const Text('Guardar Cambios'),
                            style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                          ),
                        )
                  ],
                ),
              ),
            ),
    );
  }
}
