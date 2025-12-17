import 'package:flutter/material.dart';
import '../../../shared/widgets/main_scaffold.dart';

class DashboardDirectorConfiguracionPage extends StatefulWidget {
  const DashboardDirectorConfiguracionPage({super.key});

  @override
  State<DashboardDirectorConfiguracionPage> createState() => _DashboardDirectorConfiguracionPageState();
}

class _DashboardDirectorConfiguracionPageState extends State<DashboardDirectorConfiguracionPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nombreCtrl = TextEditingController(text: 'Unidad Educativa Ejemplo');
  final _direccionCtrl = TextEditingController(text: 'Av. Principal #123');
  final _sieCtrl = TextEditingController(text: '80808012');

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Configuración General',
      child: SingleChildScrollView(
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
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Implementar guardado
                       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Configuración guardada (Simulado)')));
                    }
                  },
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
