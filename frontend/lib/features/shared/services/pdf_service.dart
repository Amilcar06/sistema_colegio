import 'package:dio/dio.dart';
import 'dart:html' as html;
import '../../../core/api_config.dart';
import '../../../core/api.dart';

class PdfService {
  /// Descarga y abre un recibo de pago en una nueva pestaña
  static Future<void> descargarRecibo(int idPago) async {
    final String url = '${ApiConfig.baseUrl}/api/reportes/recibo/$idPago';
    
    // Método 1: Abrir directamente en nueva pestaña (requiere token si no es público, pero reportes suelen ser protegidos)
    // Si la API requiere Header 'Authorization', no podemos usar window.open directamente de forma segura para endpoints protegidos sin trucos.
    // Sin embargo, para simplificar en MVP web, a veces se pasa el token por query param (inseguro) o se descarga via Blob.
    
    // Método 2: Descargar via Blob (Más seguro para APIs protegidas)
    try {
      final response = await dio.get(
        '/reportes/recibo/$idPago',
        options: Options(responseType: ResponseType.bytes),
      );
      
      _descargarBlob(response.data, 'recibo_pago_$idPago.pdf');
    } catch (e) {
      print('Error al descargar recibo: $e');
      rethrow;
    }
  }

  /// Descarga y abre el reporte de cierre de caja
  static Future<void> descargarCierreCaja() async {
    try {
      final response = await dio.get(
        '/reportes/cierre-diario/pdf',
        options: Options(responseType: ResponseType.bytes),
      );
      
      _descargarBlob(response.data, 'cierre_caja_${DateTime.now().toIso8601String().split('T')[0]}.pdf');
    } catch (e) {
      print('Error al descargar cierre de caja: $e');
      rethrow;
    }
  }

  static void _descargarBlob(List<int> bytes, String fileName) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
}
