import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';

class PdfUtil {
  /// Descarga un archivo PDF desde un array de bytes (BLOB) en Flutter Web.
  static void descargarPdfWeb(Uint8List bytes, String nombreArchivo) {
    // 1. Crear blob
    final blob = html.Blob([bytes], 'application/pdf');
    
    // 2. Crear URL objeto
    final url = html.Url.createObjectUrlFromBlob(blob);
    
    // 3. Crear ancla y clickear
    final anchor = html.AnchorElement(href: url)
      ..style.display = 'none'
      ..download = nombreArchivo;
      
    html.document.body?.children.add(anchor);
    anchor.click();
    
    // 4. Limpieza
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }
}
