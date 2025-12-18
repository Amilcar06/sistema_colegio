package com.unidadeducativa.reportes.service;

import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.repository.PagoRepository;
import com.unidadeducativa.shared.enums.EstadoPago;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ReporteFinancieroService {

    private final PagoRepository pagoRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;
    private final UsuarioRepository usuarioRepository;

    @Transactional(readOnly = true)
    public Map<String, Object> obtenerReporteIngresos(String correoDirector, int year, int month) {
        // 1. Obtener UE del director
        Usuario director = usuarioRepository.findByCorreo(correoDirector)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        if (director.getUnidadEducativa() == null) {
            // RETORNA VACIO EN LUGAR DE ERROR
            System.out.println(
                    "ADVERTENCIA: Usuario " + correoDirector + " no tiene Unidad Educativa (Reporte Ingresos).");
            Map<String, Object> respuestaVacia = new HashMap<>();
            respuestaVacia.put("mes", month);
            respuestaVacia.put("anio", year);
            respuestaVacia.put("totalMes", BigDecimal.ZERO);
            respuestaVacia.put("ingresosDiarios", new ArrayList<>());
            return respuestaVacia;
        }
        Long idUe = director.getUnidadEducativa().getIdUnidadEducativa();

        // 2. Definir rango de fechas (todo el mes)
        LocalDateTime inicioMes = LocalDateTime.of(year, month, 1, 0, 0, 0);
        LocalDateTime finMes = inicioMes.plusMonths(1).minusSeconds(1);

        // 3. Consultar DB
        List<Object[]> resultados = pagoRepository.findIngresosPorDia(idUe, inicioMes, finMes);

        // 4. Transformar resultados a Lista de Mapas amigable para JSON
        List<Map<String, Object>> ingresosDiarios = new ArrayList<>();
        BigDecimal totalMes = BigDecimal.ZERO;

        if (resultados != null) {
            for (Object[] fila : resultados) {
                Map<String, Object> item = new HashMap<>();
                // fila[0] es Date, fila[1] es BigDecimal
                Date fechaSql = (Date) fila[0];
                BigDecimal totalDia = (BigDecimal) fila[1];

                item.put("fecha", fechaSql.toString()); // YYYY-MM-DD
                item.put("total", totalDia);

                ingresosDiarios.add(item);
                totalMes = totalMes.add(totalDia);
            }
        }

        Map<String, Object> respuesta = new HashMap<>();
        respuesta.put("mes", month);
        respuesta.put("anio", year);
        respuesta.put("totalMes", totalMes);
        respuesta.put("ingresosDiarios", ingresosDiarios);

        return respuesta;
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> obtenerListaMorosos(String correoDirector) {
        Usuario director = usuarioRepository.findByCorreo(correoDirector)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        if (director.getUnidadEducativa() == null) {
            System.out.println(
                    "ADVERTENCIA: Usuario " + correoDirector + " no tiene Unidad Educativa (Reporte Morosos).");
            return new ArrayList<>();
        }
        Long idUe = director.getUnidadEducativa().getIdUnidadEducativa();

        // Buscar cuentas por cobrar pendientes
        // Nota: Necesitamos filtrar también por UE. CuentaCobrar -> Estudiante ->
        // Usuario -> UE
        List<CuentaCobrar> pendientes = cuentaCobrarRepository
                .findByEstadoAndEstudianteUsuarioUnidadEducativaIdUnidadEducativa(
                        EstadoPago.PENDIENTE, idUe);

        return pendientes.stream().map(cc -> {
            Map<String, Object> map = new HashMap<>();
            map.put("idEstudiante", cc.getEstudiante().getIdEstudiante());
            map.put("nombreEstudiante", cc.getEstudiante().getUsuario().getNombreCompleto());
            map.put("concepto", cc.getTipoPago().getNombre());
            map.put("montoTotal", cc.getMonto());
            map.put("saldoPendiente", cc.getSaldoPendiente());
            map.put("fechaVencimiento", cc.getFechaVencimiento() != null ? cc.getFechaVencimiento().toString() : "N/A");
            return map;
        }).collect(Collectors.toList());
    }

    @Transactional(readOnly = true)
    public List<Map<String, Object>> obtenerUltimasTransacciones(String correoDirector) {
        Usuario director = usuarioRepository.findByCorreo(correoDirector)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado: " + correoDirector));

        if (director.getUnidadEducativa() == null) {
            System.out.println(
                    "ADVERTENCIA: Usuario " + correoDirector + " no tiene Unidad Educativa (Reporte Transacciones).");
            return new ArrayList<>();
        }
        Long idUe = director.getUnidadEducativa().getIdUnidadEducativa();

        return pagoRepository.findUltimasTransacciones(idUe, org.springframework.data.domain.PageRequest.of(0, 20))
                .stream().map(pago -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("idPago", pago.getIdPago());
                    map.put("fecha", pago.getFechaPago().toString());
                    map.put("monto", pago.getMontoPagado());
                    map.put("metodo", pago.getMetodoPago());

                    // Defensive Null Check
                    String nombreEst = "Desconocido";
                    String concepto = "Sin concepto";

                    if (pago.getCuentaCobrar() != null) {
                        if (pago.getCuentaCobrar().getEstudiante() != null
                                && pago.getCuentaCobrar().getEstudiante().getUsuario() != null) {
                            nombreEst = pago.getCuentaCobrar().getEstudiante().getUsuario().getNombreCompleto();
                        }
                        if (pago.getCuentaCobrar().getTipoPago() != null) {
                            concepto = pago.getCuentaCobrar().getTipoPago().getNombre();
                        }
                    }

                    map.put("estudiante", nombreEst);
                    map.put("concepto", concepto);
                    map.put("recibo", pago.getNumeroRecibo());
                    return map;
                }).collect(Collectors.toList());
    }
}
