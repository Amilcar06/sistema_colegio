import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/api_config.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/widgets/main_scaffold.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../shared/services/pdf_service.dart';

class CierreCajaPage extends StatefulWidget {
  const CierreCajaPage({super.key});

  @override
  State<CierreCajaPage> createState() => _CierreCajaPageState();
}

class _CierreCajaPageState extends State<CierreCajaPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _reporte;
  String? _error;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _cargarCierre();
  }

  Future<void> _cargarCierre() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/reportes/cierre-diario'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          _reporte = jsonDecode(response.body);
        });
      } else {
        setState(() => _error = 'Error al cargar reporte: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _error = 'Error de conexión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MainScaffold(
      title: 'Cierre de Caja Diario',
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 60, color: Colors.red),
                        const SizedBox(height: 10),
                        Text(_error!),
                        const SizedBox(height: 20),
                        ElevatedButton(onPressed: _cargarCierre, child: const Text('Reintentar'))
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            children: [
                              Text(
                                DateFormat('dd MMMM yyyy (EEEE)', 'es').format(DateTime.parse(_reporte!['fecha'])),
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              const SizedBox(height: 20),
                              const Text(
                                'TOTAL RECAUDADO',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blueGrey),
                              ),
                              Text(
                                'Bs ${_reporte!['totalDia']}',
                                style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.green),
                              ),
                              const Divider(height: 40),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      const Icon(Icons.attach_money, color: Colors.green),
                                      const Text('Efectivo'),
                                      Text('Bs ${_reporte!['totalEfectivo']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.qr_code, color: Colors.blue),
                                      const Text('QR/Transf'),
                                      Text('Bs ${_reporte!['totalQR']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      const Icon(Icons.receipt_long, color: Colors.orange),
                                      const Text('Transacciones'),
                                      Text('${_reporte!['transacciones']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: () async {
                              try {
                                await PdfService.descargarCierreCaja();
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('Error al descargar reporte: $e'),
                                    backgroundColor: Colors.red));
                              }
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('IMPRIMIR REPORTE DE CIERRE'),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }
}
