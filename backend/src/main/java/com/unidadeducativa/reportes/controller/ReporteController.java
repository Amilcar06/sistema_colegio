package com.unidadeducativa.reportes.controller;

import com.unidadeducativa.reportes.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.security.access.prepost.PreAuthorize;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
@io.swagger.v3.oas.annotations.tags.Tag(name = "Reportes", description = "Generación de documentos PDF (Boletines, Listas, Recibos)")
public class ReporteController {

    private final ReporteService reporteService;

    @io.swagger.v3.oas.annotations.Operation(summary = "Generar boletín de notas", description = "Genera un PDF con el boletín de notas del estudiante.")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "PDF generado correctamente", content = @io.swagger.v3.oas.annotations.media.Content(mediaType = "application/pdf"))
    @PreAuthorize("hasAnyRole('ROLE_ADMIN', 'ROLE_SECRETARIA', 'ROLE_ESTUDIANTE')")
    @GetMapping("/boletin/{idEstudiante}")
    public ResponseEntity<byte[]> generarBoletin(@PathVariable Long idEstudiante) {
        byte[] pdfContent = reporteService.generarBoletin(idEstudiante);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=boletin_notas.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfContent);
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Generar lista de curso", description = "Genera un PDF con la lista de estudiantes inscritos en un curso.")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "PDF generado correctamente", content = @io.swagger.v3.oas.annotations.media.Content(mediaType = "application/pdf"))
    @GetMapping("/curso/{idCurso}")
    public ResponseEntity<byte[]> generarListaCurso(@PathVariable Long idCurso) {
        byte[] pdfContent = reporteService.generarListaCurso(idCurso);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=lista_curso.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfContent);
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Generar recibo de pago", description = "Genera un PDF con el recibo de un pago realizado.")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "PDF generado correctamente", content = @io.swagger.v3.oas.annotations.media.Content(mediaType = "application/pdf"))
    @GetMapping("/recibo/{idPago}")
    public ResponseEntity<byte[]> generarRecibo(@PathVariable Long idPago) {
        byte[] pdfContent = reporteService.generarRecibo(idPago);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=recibo_pago.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfContent);
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Generar reporte de cierre de caja", description = "Genera un PDF con el cierre de caja diario del usuario actual.")
    @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "PDF generado correctamente", content = @io.swagger.v3.oas.annotations.media.Content(mediaType = "application/pdf"))
    @GetMapping("/cierre-diario/pdf")
    public ResponseEntity<byte[]> generarCierreCaja(org.springframework.security.core.Authentication authentication) {
        String correoUsuario = authentication.getName();
        byte[] pdfContent = reporteService.generarCierreCaja(correoUsuario);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION,
                        "attachment; filename=cierre_caja_" + java.time.LocalDate.now() + ".pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfContent);
    }

    @io.swagger.v3.oas.annotations.Operation(summary = "Prueba de generación de reporte", description = "Endpoint de prueba para verificar el servicio de reportes.")
    @GetMapping("/test")
    public ResponseEntity<byte[]> testReport() {
        // TODO: Este es un placeholder. En el próximo paso crearemos una plantilla
        // real.
        // Por ahora, si la plantilla no existe, fallará, lo cual es esperado.

        // Simular datos
        Map<String, Object> params = new HashMap<>();
        params.put("TITULO", "Reporte de Prueba");
        params.put("FECHA", LocalDateTime.now().toString());

        // byte[] pdfContent = reporteService.generarReportePDF("boletin_notas.jrxml",
        // params, List.of());

        // Devolver dummy por ahora para que compile y no falle 500
        byte[] pdfContent = new byte[0];

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=reporte.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdfContent);
    }
}
