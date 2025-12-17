package com.unidadeducativa.comunicacion.service;

import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.comunicacion.dto.ComunicadoRequestDTO;
import com.unidadeducativa.comunicacion.dto.ComunicadoResponseDTO;
import com.unidadeducativa.comunicacion.enums.TipoDestinatario;
import com.unidadeducativa.comunicacion.model.Comunicado;
import com.unidadeducativa.comunicacion.repository.ComunicadoRepository;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.usuario.model.Usuario;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class ComunicadoService {

    private final ComunicadoRepository comunicadoRepository;
    private final EstudianteRepository estudianteRepository;
    private final InscripcionRepository inscripcionRepository;

    public ComunicadoResponseDTO crearComunicado(ComunicadoRequestDTO request, Usuario autor) {
        Comunicado comunicado = Comunicado.builder()
                .titulo(request.getTitulo())
                .contenido(request.getContenido())
                .fechaPublicacion(LocalDateTime.now())
                .prioridad(request.getPrioridad())
                .tipoDestinatario(request.getTipoDestinatario())
                .idReferencia(request.getIdReferencia()) // Null if Global
                .autor(autor)
                .build();

        Comunicado guardado = comunicadoRepository.save(comunicado);
        return mapToDTO(guardado);
    }

    public List<ComunicadoResponseDTO> listarComunicados(Usuario usuario) {
        RolNombre rol = usuario.getRol().getNombre();

        if (rol == RolNombre.ESTUDIANTE) {
            return listarParaEstudiante(usuario);
        } else if (rol == RolNombre.PROFESOR) {
            // Professors see global and their own (or all)
            // For now, let's return ALL (or just theirs? Plan says "Send to their courses")
            // Ideally they should see what they sent.
            // Let's return Global + By Author for now, OR just all if simpler.
            // Keeping it simple: Return All so they can see global announcements too.
            // Improve later if needed.
            return comunicadoRepository.findAll().stream()
                    .map(this::mapToDTO)
                    .collect(Collectors.toList());
        } else {
            // ADMIN / DIRECTOR / SECRETARIA -> See ALL
            return comunicadoRepository.findAll().stream()
                    .map(this::mapToDTO)
                    .collect(Collectors.toList());
        }
    }

    private List<ComunicadoResponseDTO> listarParaEstudiante(Usuario usuario) {
        Estudiante estudiante = estudianteRepository.findByUsuario(usuario)
                .orElseThrow(
                        () -> new RuntimeException("Estudiante no encontrado para usuario " + usuario.getIdUsuario()));

        // Find active inscription to get Course ID
        List<Inscripcion> inscripciones = inscripcionRepository
                .findByEstudianteIdEstudiante(estudiante.getIdEstudiante());

        // Asumimos la última inscripción o filtramos por estado activo
        // MVP: Filtramos por la que tenga ID más alto (última)
        Inscripcion ultima = inscripciones.stream()
                .max(Comparator.comparing(Inscripcion::getIdInscripcion))
                .orElse(null);

        Long idCurso = (ultima != null && ultima.getCurso() != null) ? ultima.getCurso().getIdCurso() : -1L;

        return comunicadoRepository.findGlobalOrPorCurso(idCurso).stream()
                .map(this::mapToDTO)
                .collect(Collectors.toList());
    }

    public ComunicadoResponseDTO actualizarComunicado(Long id, ComunicadoRequestDTO request) {
        Comunicado comunicado = comunicadoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Comunicado no encontrado con ID: " + id));

        comunicado.setTitulo(request.getTitulo());
        comunicado.setContenido(request.getContenido());
        comunicado.setPrioridad(request.getPrioridad());
        comunicado.setTipoDestinatario(request.getTipoDestinatario());
        comunicado.setIdReferencia(request.getIdReferencia());

        Comunicado actualizado = comunicadoRepository.save(comunicado);
        return mapToDTO(actualizado);
    }

    public void eliminarComunicado(Long id) {
        if (!comunicadoRepository.existsById(id)) {
            throw new RuntimeException("Comunicado no encontrado con ID: " + id);
        }
        comunicadoRepository.deleteById(id);
    }

    private ComunicadoResponseDTO mapToDTO(Comunicado c) {
        return ComunicadoResponseDTO.builder()
                .idComunicado(c.getIdComunicado())
                .titulo(c.getTitulo())
                .contenido(c.getContenido())
                .fechaPublicacion(c.getFechaPublicacion())
                .prioridad(c.getPrioridad())
                .tipoDestinatario(c.getTipoDestinatario())
                .nombreAutor(c.getAutor().getNombreCompleto())
                .build();
    }
}
