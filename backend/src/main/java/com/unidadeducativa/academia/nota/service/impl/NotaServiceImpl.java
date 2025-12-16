package com.unidadeducativa.academia.nota.service.impl;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.academia.asignaciondocente.repository.AsignacionDocenteRepository;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.academia.nota.dto.*;
import com.unidadeducativa.academia.nota.mapper.NotaMapper;
import com.unidadeducativa.academia.nota.model.Nota;
import com.unidadeducativa.academia.nota.repository.NotaRepository;
import com.unidadeducativa.academia.nota.service.INotaService;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.shared.enums.Trimestre;
import jakarta.persistence.EntityNotFoundException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotaServiceImpl implements INotaService {

        private final NotaRepository notaRepository;
        private final NotaMapper notaMapper;
        private final EstudianteRepository estudianteRepository;
        private final AsignacionDocenteRepository asignacionDocenteRepository;
        private final InscripcionRepository inscripcionRepository;

        @Override
        @Transactional
        public NotaResponseDTO registrarNota(NotaRequestDTO dto) {
                Estudiante estudiante = estudianteRepository.findById(dto.getIdEstudiante())
                                .orElseThrow(() -> new EntityNotFoundException("Estudiante no encontrado"));

                AsignacionDocente asignacion = asignacionDocenteRepository.findById(dto.getIdAsignacion())
                                .orElseThrow(() -> new EntityNotFoundException("Asignación docente no encontrada"));

                if (notaRepository.existsByEstudianteAndAsignacionAndTrimestre(estudiante, asignacion,
                                dto.getTrimestre())) {
                        throw new IllegalStateException(
                                        "La nota ya fue registrada para este estudiante, materia y trimestre");
                }

                Nota nota = notaMapper.toEntity(dto, estudiante, asignacion);
                return notaMapper.toResponseDTO(notaRepository.save(nota));
        }

        @Override
        @Transactional
        public void registrarNotasMasivas(NotaBulkRequestDTO bulk) {
                for (NotaRequestDTO dto : bulk.getNotas()) {
                        try {
                                registrarNota(dto);
                        } catch (Exception e) {
                                // Log or handle each failure individually
                        }
                }
        }

        @Override
        @Transactional(readOnly = true)
        public List<NotaResponseDTO> obtenerNotasPorEstudiante(Long idEstudiante) {
                Estudiante estudiante = estudianteRepository.findById(idEstudiante)
                                .orElseThrow(() -> new EntityNotFoundException("Estudiante no encontrado"));

                return notaRepository.findByEstudiante(estudiante).stream()
                                .map(notaMapper::toResponseDTO)
                                .toList();
        }

        @Override
        @Transactional(readOnly = true)
        public List<NotaResponseDTO> obtenerNotasPorEstudianteYTrimestre(Long idEstudiante, Trimestre trimestre) {
                Estudiante estudiante = estudianteRepository.findById(idEstudiante)
                                .orElseThrow(() -> new EntityNotFoundException("Estudiante no encontrado"));

                return notaRepository.findByEstudianteAndTrimestre(estudiante, trimestre).stream()
                                .map(notaMapper::toResponseDTO)
                                .toList();
        }

        @Override
        @Transactional
        public NotaResponseDTO actualizarNota(Long idNota, NotaRequestDTO dto) {
                Nota nota = notaRepository.findById(idNota)
                                .orElseThrow(() -> new EntityNotFoundException("Nota no encontrada"));

                nota.setValor(dto.getValor());
                nota.setTrimestre(dto.getTrimestre());
                return notaMapper.toResponseDTO(notaRepository.save(nota));
        }

        @Override
        @Transactional
        public void eliminarNota(Long idNota) {
                Nota nota = notaRepository.findById(idNota)
                                .orElseThrow(() -> new EntityNotFoundException("Nota no encontrada"));
                notaRepository.delete(nota);
        }

        @Override
        @Transactional(readOnly = true)
        public NotaBoletinDTO obtenerBoletin(Long idEstudiante, Long idGestion) {
                Estudiante estudiante = estudianteRepository.findById(idEstudiante)
                                .orElseThrow(() -> new EntityNotFoundException("Estudiante no encontrado"));

                Long gestionUsada = idGestion;
                String gestionNombre = "";
                String cursoNombre = "";

                if (gestionUsada == null) {
                        var inscripcion = inscripcionRepository.findByEstudianteAndGestionEstadoTrue(estudiante)
                                        .orElseThrow(() -> new EntityNotFoundException(
                                                        "Inscripción activa no encontrada"));
                        gestionUsada = inscripcion.getGestion().getIdGestion();
                        gestionNombre = inscripcion.getGestion().getAnio().toString();
                        cursoNombre = inscripcion.getCurso().getGrado().getNombre() + " "
                                        + inscripcion.getCurso().getParalelo();
                } else {
                        // Si se pasa gestion, buscar la inscripcion de esa gestion para sacar datos del
                        // curso
                        // Ojo: podria no estar inscrito en esa gestion, validamos
                        var inscripcion = inscripcionRepository.findByEstudianteIdEstudiante(idEstudiante).stream()
                                        .filter(i -> i.getGestion().getIdGestion().equals(idGestion))
                                        .findFirst()
                                        .orElseThrow(() -> new EntityNotFoundException(
                                                        "No se encontró inscripción para la gestión solicitada"));

                        gestionNombre = inscripcion.getGestion().getAnio().toString();
                        cursoNombre = inscripcion.getCurso().getGrado().getNombre() + " "
                                        + inscripcion.getCurso().getParalelo();
                        // Nota: idGestion es el parametro 'gestionUsada' (pero necesitamos el de la
                        // lambda, que es el mismo)
                        // y gestionUsada ya tiene valor.
                }

                List<Map<String, Object>> rows = notaRepository.obtenerBoletinCompletoRaw(idEstudiante, gestionUsada);

                List<NotaTrimestreDTO> detalle = rows.stream()
                                .map(row -> NotaTrimestreDTO.builder()
                                                .materia((String) row.get("materia"))
                                                .trimestre(Trimestre
                                                                .valueOf(((String) row.get("trimestre")).toUpperCase()))
                                                .valor(row.get("valor") == null ? 0.0
                                                                : ((Number) row.get("valor")).doubleValue())
                                                .nombreProfesor((String) row.getOrDefault("nombre_profesor", ""))
                                                .build())
                                .collect(Collectors.toList());

                return NotaBoletinDTO.builder()
                                .idEstudiante(estudiante.getIdEstudiante())
                                .nombreEstudiante(estudiante.getUsuario().getNombreCompleto())
                                .curso(cursoNombre)
                                .gestion(gestionNombre)
                                .notas(detalle)
                                .build();
        }

        @Override
        @Transactional(readOnly = true)
        public LibretaDigitalDTO obtenerLibreta(Long idAsignacion) {
                AsignacionDocente asignacion = asignacionDocenteRepository.findById(idAsignacion)
                                .orElseThrow(() -> new EntityNotFoundException("Asignación no encontrada"));

                var inscritos = inscripcionRepository.findByCursoIdCursoAndGestionIdGestion(
                                asignacion.getCurso().getIdCurso(),
                                asignacion.getGestion().getIdGestion());

                List<Nota> notasRegistradas = notaRepository.findByAsignacion_IdAsignacion(idAsignacion);

                // Agrupar notas por estudiante
                Map<Long, List<Nota>> notasPorEstudiante = notasRegistradas.stream()
                                .collect(Collectors.groupingBy(n -> n.getEstudiante().getIdEstudiante()));

                List<EstudianteNotaDTO> estudiantes = inscritos.stream()
                                .map(ins -> {
                                        Estudiante e = ins.getEstudiante();
                                        List<Nota> notas = notasPorEstudiante.getOrDefault(e.getIdEstudiante(),
                                                        List.of());
                                        EstudianteNotaDTO dto = new EstudianteNotaDTO();
                                        dto.setIdEstudiante(e.getIdEstudiante());
                                        dto.setNombreCompleto(e.getUsuario().getNombreCompleto());

                                        for (Nota n : notas) {
                                                if (n.getTrimestre() == Trimestre.PRIMER) {
                                                        dto.setNotaPrimerTrimestre(n.getValor());
                                                        dto.setIdNotaPrimerTrimestre(n.getIdNota());
                                                } else if (n.getTrimestre() == Trimestre.SEGUNDO) {
                                                        dto.setNotaSegundoTrimestre(n.getValor());
                                                        dto.setIdNotaSegundoTrimestre(n.getIdNota());
                                                } else if (n.getTrimestre() == Trimestre.TERCER) {
                                                        dto.setNotaTercerTrimestre(n.getValor());
                                                        dto.setIdNotaTercerTrimestre(n.getIdNota());
                                                }
                                        }
                                        return dto;
                                })
                                .sorted((a, b) -> a.getNombreCompleto().compareTo(b.getNombreCompleto()))
                                .collect(Collectors.toList());

                return LibretaDigitalDTO.builder()
                                .idAsignacion(asignacion.getIdAsignacion())
                                .materia(asignacion.getMateria().getNombre())
                                .curso(asignacion.getCurso().getGrado().getNombre() + " "
                                                + asignacion.getCurso().getParalelo())
                                .gestion(asignacion.getGestion().getAnio().toString())
                                .estudiantes(estudiantes)
                                .build();
        }
}