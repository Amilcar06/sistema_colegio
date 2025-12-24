package com.unidadeducativa.finanzas.service.impl;

import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import com.unidadeducativa.finanzas.dto.TipoPagoRequestDTO;
import com.unidadeducativa.finanzas.mapper.TipoPagoMapper;
import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.model.TipoPago;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.repository.TipoPagoRepository;
import com.unidadeducativa.finanzas.service.ITipoPagoService;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.shared.enums.EstadoPago;
import com.unidadeducativa.usuario.model.Usuario;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
public class TipoPagoServiceImpl implements ITipoPagoService {

    private final TipoPagoRepository tipoPagoRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;
    private final GestionRepository gestionRepository;
    private final com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository inscripcionRepository;
    private final TipoPagoMapper tipoPagoMapper;
    private final com.unidadeducativa.finanzas.service.PaymentGenerationService paymentGenerationService;

    @Override
    @Transactional
    public TipoPago crearTipoPago(TipoPagoRequestDTO request, Usuario usuarioAuditor) {
        TipoPago tipoPago = tipoPagoMapper.toEntity(request);
        tipoPago.setUnidadEducativa(usuarioAuditor.getUnidadEducativa());
        tipoPago.setGestion(gestionRepository.findById(request.getIdGestion())
                .orElseThrow(() -> new RuntimeException("Gestión no encontrada")));

        TipoPago saved = tipoPagoRepository.save(tipoPago);

        if (saved.isEsObligatorio()) {
            paymentGenerationService.generarDeudaMasiva(saved);
        }
        return saved;
    }

    @Override
    public List<TipoPago> listarPorGestion(Long idGestion, Usuario usuarioAuditor) {
        return tipoPagoRepository.findAllByUnidadEducativa_IdUnidadEducativaAndGestion_IdGestion(
                usuarioAuditor.getUnidadEducativa().getIdUnidadEducativa(), idGestion);
    }

    @Override
    @Transactional
    public void generarDeudasLote(Long idTipoPago, Usuario usuarioAuditor) {
        TipoPago tipoPago = tipoPagoRepository.findById(idTipoPago)
                .orElseThrow(() -> new RuntimeException("Tipo de Pago no encontrado"));

        if (!tipoPago.getUnidadEducativa().getIdUnidadEducativa()
                .equals(usuarioAuditor.getUnidadEducativa().getIdUnidadEducativa())) {
            throw new RuntimeException("No tiene permiso para gestionar este pago");
        }

        paymentGenerationService.generarDeudaMasiva(tipoPago);
    }

    @Override
    @Transactional
    public TipoPago actualizarTipoPago(Long id, TipoPagoRequestDTO request, Usuario usuarioAuditor) {
        TipoPago tipoPago = tipoPagoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tipo de Pago no encontrado"));

        if (!tipoPago.getUnidadEducativa().getIdUnidadEducativa()
                .equals(usuarioAuditor.getUnidadEducativa().getIdUnidadEducativa())) {
            throw new RuntimeException("No tiene permiso para editar este pago");
        }

        tipoPagoMapper.updateEntityFromDTO(request, tipoPago);

        // Si se cambia la gestión
        if (request.getIdGestion() != null) {
            tipoPago.setGestion(gestionRepository.findById(request.getIdGestion())
                    .orElseThrow(() -> new RuntimeException("Gestión no encontrada")));
        }

        return tipoPagoRepository.save(tipoPago);
    }

    @Override
    @Transactional
    public void eliminarTipoPago(Long id, Usuario usuarioAuditor) {
        TipoPago tipoPago = tipoPagoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Tipo de Pago no encontrado"));

        if (!tipoPago.getUnidadEducativa().getIdUnidadEducativa()
                .equals(usuarioAuditor.getUnidadEducativa().getIdUnidadEducativa())) {
            throw new RuntimeException("No tiene permiso para eliminar este pago");
        }

        // Validar si tiene cobros asociados antes de eliminar
        boolean tieneCobros = cuentaCobrarRepository.existsByTipoPago_IdTipoPago(id);
        if (tieneCobros) {
            throw new RuntimeException("No se puede eliminar el tipo de pago porque ya tiene cobros generados");
        }

        tipoPagoRepository.delete(tipoPago);
    }
}
