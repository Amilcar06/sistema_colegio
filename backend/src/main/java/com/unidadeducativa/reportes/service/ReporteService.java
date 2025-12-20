package com.unidadeducativa.reportes.service;

import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.academia.nota.repository.NotaRepository;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.reportes.dto.NotaBoletinDTO;
import lombok.RequiredArgsConstructor;
import net.sf.jasperreports.engine.*;
import net.sf.jasperreports.engine.data.JRBeanCollectionDataSource;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Service;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.academia.curso.repository.CursoRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;

import java.io.InputStream;
import java.util.*;

import com.unidadeducativa.finanzas.repository.PagoRepository;

import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
@Transactional
public class ReporteService {

    // Repositorios
    private final NotaRepository notaRepository;
    private final EstudianteRepository estudianteRepository;
    private final InscripcionRepository inscripcionRepository;
    private final com.unidadeducativa.finanzas.repository.CuentaCobrarRepository cuentaCobrarRepository;
    private final com.unidadeducativa.academia.curso.repository.CursoRepository cursoRepository;
    private final com.unidadeducativa.finanzas.repository.PagoRepository pagoRepository;
    private final ReporteFinancieroService reporteFinancieroService;
    private final com.unidadeducativa.usuario.repository.UsuarioRepository usuarioRepository;

    // --- BOLETIN DE NOTAS (ALUMNO) ---
    public byte[] generarBoletin(Long idEstudiante) {
        Estudiante estudiante = estudianteRepository.findById(idEstudiante)
                .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));

        Inscripcion inscripcion = inscripcionRepository.findByEstudianteAndGestionEstadoTrue(estudiante)
                .orElseThrow(() -> new RuntimeException("El estudiante no está inscrito en la gestión actual"));

        Long idGestion = inscripcion.getGestion().getIdGestion();

        // VALIDACION: Verificar si tiene deudas vencidas
        List<com.unidadeducativa.finanzas.model.CuentaCobrar> deudas = cuentaCobrarRepository
                .findByEstudiante_IdEstudianteAndEstado(idEstudiante,
                        com.unidadeducativa.shared.enums.EstadoPago.PENDIENTE);

        boolean tieneDeudasVencidas = deudas.stream()
                .anyMatch(d -> d.getFechaVencimiento() != null
                        && d.getFechaVencimiento().isBefore(java.time.LocalDate.now()));

        if (tieneDeudasVencidas) {
            throw new RuntimeException("Tiene mensualidades vencidas. Regularice sus pagos.");
        }

        List<Map<String, Object>> rawNotas = notaRepository.obtenerBoletinCompletoRaw(idEstudiante, idGestion);
        Map<String, NotaBoletinDTO> notasMap = new LinkedHashMap<>();

        for (Map<String, Object> row : rawNotas) {
            String materia = (String) row.get("materia");
            String trimestre = (String) row.get("trimestre");
            Double valor = row.get("valor") != null ? ((Number) row.get("valor")).doubleValue() : null;

            notasMap.putIfAbsent(materia, NotaBoletinDTO.builder().materia(materia).observacion("").build());
            NotaBoletinDTO dto = notasMap.get(materia);

            if (valor != null) {
                if ("PRIMER".equals(trimestre))
                    dto.setNota1(valor);
                else if ("SEGUNDO".equals(trimestre))
                    dto.setNota2(valor);
                else if ("TERCER".equals(trimestre))
                    dto.setNota3(valor);
            }
        }

        List<NotaBoletinDTO> listaNotas = new ArrayList<>(notasMap.values());
        for (NotaBoletinDTO n : listaNotas) {
            double sum = 0;
            int count = 0;
            if (n.getNota1() != null) {
                sum += n.getNota1();
                count++;
            }
            if (n.getNota2() != null) {
                sum += n.getNota2();
                count++;
            }
            if (n.getNota3() != null) {
                sum += n.getNota3();
                count++;
            }
            if (count > 0)
                n.setPromedio(sum / count);
        }

        Map<String, Object> params = new HashMap<>();
        params.put("titulo", "BOLETÍN DE NOTAS");
        params.put("nombreEstudiante", estudiante.getUsuario().getNombreCompleto());
        params.put("curso", inscripcion.getCurso().getGrado().getNombre() + " " + inscripcion.getCurso().getParalelo());
        params.put("gestion", inscripcion.getGestion().getAnio().toString());

        return generarReportePDF("boletin_notas.jrxml", params, listaNotas);
    }

    // --- LISTA DE CURSO (PROFESOR) ---
    public byte[] generarListaCurso(Long idCurso) {
        var curso = cursoRepository.findById(idCurso)
                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));

        List<Inscripcion> inscripciones = inscripcionRepository.findByCursoIdCursoAndEstado(idCurso,
                com.unidadeducativa.shared.enums.EstadoInscripcion.ACTIVO);

        List<com.unidadeducativa.reportes.dto.ListaCursoDTO> lista = new ArrayList<>();
        int i = 1;
        for (Inscripcion insc : inscripciones) {
            lista.add(com.unidadeducativa.reportes.dto.ListaCursoDTO.builder()
                    .nroLista(i++)
                    .nombreEstudiante(insc.getEstudiante().getUsuario().getNombreCompleto())
                    .codigoRude(insc.getEstudiante().getCodigoRude())
                    .build());
        }

        Map<String, Object> params = new HashMap<>();
        params.put("titulo", "LISTA DE ESTUDIANTES");
        params.put("nombreProfesor", "PROFESOR ASIGNADO");
        params.put("curso", curso.getGrado().getNombre() + " " + curso.getParalelo());

        return generarReportePDF("lista_curso.jrxml", params, lista);
    }

    // --- RECIBO DE PAGO (SECRETARIA) ---
    public byte[] generarRecibo(Long idPago) {
        com.unidadeducativa.finanzas.model.Pago pago = pagoRepository.findById(idPago)
                .orElseThrow(() -> new RuntimeException("Pago no encontrado"));

        System.out.println("Generando recibo para pago ID: " + idPago);
        System.out.println("Pago encontrado: " + pago);
        if (pago.getCuentaCobrar() == null)
            System.out.println("CuentaCobrar es NULL");
        if (pago.getCuentaCobrar().getEstudiante() == null)
            System.out.println("Estudiante es NULL");

        Map<String, Object> params = new HashMap<>();
        params.put("nroRecibo",
                pago.getNumeroRecibo() != null ? pago.getNumeroRecibo() : String.valueOf(pago.getIdPago()));
        params.put("fecha", pago.getFechaPago() != null ? pago.getFechaPago().toString() : "SIN FECHA");
        params.put("estudiante", pago.getCuentaCobrar().getEstudiante().getUsuario().getNombreCompleto());
        params.put("rude", pago.getCuentaCobrar().getEstudiante().getCodigoRude());
        params.put("concepto", pago.getCuentaCobrar().getTipoPago().getNombre());
        params.put("monto", pago.getMontoPagado().toString() + " Bs.");
        params.put("cajero", pago.getCajero() != null ? pago.getCajero().getNombreCompleto() : "SISTEMA");

        // Lista vacía porque el recibo usa solo Parámetros, no Detail band (o dummy
        // data)
        return generarReportePDF("recibo_pago.jrxml", params, List.of(new Object()));
    }

    // --- REPORTE CIERRE DE CAJA ---
    public byte[] generarCierreCaja(String correoUsuario) {
        // Obtenemos los datos del día actual
        java.time.LocalDate hoy = java.time.LocalDate.now();
        Map<String, Object> data = reporteFinancieroService.obtenerCierreDiario(correoUsuario, hoy);

        System.out.println("Generando reporte de cierre para: " + correoUsuario);

        // Mapear datos a parámetros Jasper
        Map<String, Object> params = new HashMap<>();
        params.put("fecha", data.get("fecha").toString());

        // Obtener nombre del cajero desde el repositorio (mejor que solo correo)
        var usuario = usuarioRepository.findByCorreo(correoUsuario).orElse(null);
        params.put("cajero", usuario != null ? usuario.getNombreCompleto() : correoUsuario);

        params.put("totalEfectivo", data.get("totalEfectivo").toString() + " Bs.");
        params.put("totalQR", data.get("totalQR").toString() + " Bs.");
        params.put("totalDia", data.get("totalDia").toString() + " Bs.");
        params.put("transacciones", data.get("transacciones").toString());

        return generarReportePDF("cierre_caja.jrxml", params, List.of(new Object()));
    }

    public byte[] generarReportePDF(String templateName, Map<String, Object> parametros, List<?> datos) {
        try {
            // Cargar plantilla desde classpath
            InputStream reportStream = new ClassPathResource("reports/" + templateName).getInputStream();

            // Compilar el reporte
            JasperReport jasperReport = JasperCompileManager.compileReport(reportStream);

            // Fuente de datos
            JRBeanCollectionDataSource dataSource = new JRBeanCollectionDataSource(datos != null ? datos : List.of());

            // Llenar el reporte
            JasperPrint jasperPrint = JasperFillManager.fillReport(jasperReport, parametros, dataSource);

            // Exportar a PDF
            return JasperExportManager.exportReportToPdf(jasperPrint);

        } catch (Exception e) {
            throw new RuntimeException("Error al generar el reporte PDF: " + e.getMessage(), e);
        }
    }
}
