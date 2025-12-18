package com.unidadeducativa.academia.curso.service.impl;

import com.unidadeducativa.academia.curso.dto.CursoRequestDTO;
import com.unidadeducativa.academia.curso.dto.CursoResponseDTO;
import com.unidadeducativa.academia.curso.mapper.CursoMapper;
import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.curso.repository.CursoRepository;
import com.unidadeducativa.academia.curso.service.ICursoService;
import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.grado.repository.GradoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class CursoServiceImpl implements ICursoService {

    private final CursoRepository cursoRepository;
    private final GradoRepository gradoRepository;
    private final com.unidadeducativa.academia.paralelo.repository.ConfiguracionParaleloRepository configParaleloRepository;
    private final CursoMapper cursoMapper;

    private void validarParaleloActivo(String nombreParalelo) {
        configParaleloRepository.findAll().stream()
                .filter(p -> p.getNombre().equalsIgnoreCase(nombreParalelo))
                .findFirst()
                .ifPresentOrElse(
                        p -> {
                            if (!Boolean.TRUE.equals(p.getActivo())) {
                                throw new IllegalArgumentException(
                                        "El paralelo " + nombreParalelo + " está deshabilitado en la configuración.");
                            }
                        },
                        () -> {
                            throw new IllegalArgumentException(
                                    "El paralelo " + nombreParalelo + " no existe en la configuración.");
                        });
    }

    @Override
    public CursoResponseDTO crearCurso(CursoRequestDTO dto) {
        // Validar que el paralelo esté activo
        validarParaleloActivo(dto.getParalelo());

        // Verificamos que el grado exista
        gradoRepository.findById(dto.getIdGrado())
                .orElseThrow(() -> new RuntimeException("Grado no encontrado"));

        // Verificamos que no exista el curso con esos datos
        boolean existe = cursoRepository.existsByGrado_IdGradoAndParaleloAndTurno(
                dto.getIdGrado(), dto.getParalelo(), dto.getTurno());
        if (existe) {
            throw new IllegalArgumentException("Ya existe un curso con esos datos");
        }

        Curso curso = cursoMapper.toEntity(dto);
        return cursoMapper.toDTO(cursoRepository.save(curso));
    }

    @Override
    public List<CursoResponseDTO> listarCursos() {
        return cursoRepository.findAll()
                .stream()
                .map(cursoMapper::toDTO)
                .toList();
    }

    @Override
    public CursoResponseDTO obtenerCursoPorId(Long id) {
        Curso curso = cursoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));
        return cursoMapper.toDTO(curso);
    }

    @Override
    public CursoResponseDTO actualizarCurso(Long id, CursoRequestDTO dto) {
        Curso curso = cursoRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));

        // Validar nuevo paralelo si cambia o siempre
        validarParaleloActivo(dto.getParalelo());

        Grado grado = gradoRepository.findById(dto.getIdGrado())
                .orElseThrow(() -> new RuntimeException("Grado no encontrado"));

        curso.setGrado(grado);
        curso.setParalelo(dto.getParalelo());
        curso.setTurno(dto.getTurno());
        return cursoMapper.toDTO(cursoRepository.save(curso));
    }

    @Override
    public void eliminarCurso(Long id) {
        cursoRepository.deleteById(id);
    }
}
