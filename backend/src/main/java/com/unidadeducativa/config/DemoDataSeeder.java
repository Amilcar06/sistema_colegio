package com.unidadeducativa.config;

import com.unidadeducativa.academia.asignaciondocente.model.AsignacionDocente;
import com.unidadeducativa.academia.asignaciondocente.repository.AsignacionDocenteRepository;
import com.unidadeducativa.academia.curso.model.Curso;
import com.unidadeducativa.academia.curso.repository.CursoRepository;
import com.unidadeducativa.academia.gestion.model.GestionAcademica;
import com.unidadeducativa.academia.gestion.repository.GestionRepository;
import com.unidadeducativa.academia.grado.model.Grado;
import com.unidadeducativa.academia.grado.repository.GradoRepository;
import com.unidadeducativa.academia.inscripcion.model.Inscripcion;
import com.unidadeducativa.academia.inscripcion.repository.InscripcionRepository;
import com.unidadeducativa.academia.materia.model.Materia;
import com.unidadeducativa.academia.materia.repository.MateriaRepository;
import com.unidadeducativa.academia.nota.model.Nota;
import com.unidadeducativa.academia.nota.repository.NotaRepository;
import com.unidadeducativa.finanzas.model.CuentaCobrar;
import com.unidadeducativa.finanzas.model.Pago;
import com.unidadeducativa.finanzas.model.TipoPago;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.repository.PagoRepository;
import com.unidadeducativa.finanzas.repository.TipoPagoRepository;
import com.unidadeducativa.institucion.model.UnidadEducativa;
import com.unidadeducativa.institucion.repository.UnidadEducativaRepository;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.personas.profesor.repository.ProfesorRepository;
import com.unidadeducativa.shared.enums.*;
import com.unidadeducativa.usuario.model.Rol;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Profile;
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.Random;

@Component
@RequiredArgsConstructor
@Slf4j
@Order(2) // Run after DataInitializer
public class DemoDataSeeder implements CommandLineRunner {

    private final UnidadEducativaRepository unidadEducativaRepository;
    private final GestionRepository gestionRepository;
    private final CursoRepository cursoRepository;
    private final GradoRepository gradoRepository;
    private final EstudianteRepository estudianteRepository;
    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final PasswordEncoder passwordEncoder;
    private final InscripcionRepository inscripcionRepository;
    private final ProfesorRepository profesorRepository;
    private final MateriaRepository materiaRepository;
    private final AsignacionDocenteRepository asignacionDocenteRepository;
    private final NotaRepository notaRepository;
    private final TipoPagoRepository tipoPagoRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;
    private final PagoRepository pagoRepository;

    @Override
    public void run(String... args) throws Exception {
        if (estudianteRepository.count() > 10) {
            log.info("Seeding omitido: Ya existen suficientes estudiantes.");
            return;
        }

        log.info("INICIANDO SEEDING DE DATOS MASIVOS PARA DEMO...");

        UnidadEducativa ue = unidadEducativaRepository.findAll().get(0);
        int year = LocalDate.now().getYear();
        GestionAcademica gestion = gestionRepository
                .findByAnioAndUnidadEducativa_IdUnidadEducativa(year, ue.getIdUnidadEducativa())
                .orElseThrow();
        Rol rolEstudiante = rolRepository.findByNombre(RolNombre.ESTUDIANTE).orElseThrow();

        // 1. Crear Cursos para todos los grados (1-6 Primaria, 1-6 Secundaria) Paralelo
        // A
        List<Grado> grados = gradoRepository.findAll();
        for (Grado grado : grados) {
            if (!cursoRepository.existsByGrado_IdGradoAndParaleloAndTurno(grado.getIdGrado(), "A", TipoTurno.MANANA)) {
                cursoRepository.save(Curso.builder()
                        .grado(grado)
                        .paralelo("A")
                        .turno(TipoTurno.MANANA)
                        // .cupoMaximo(30) // Removed as it doesn't exist in entity
                        .build());
            }
        }

        List<Curso> cursos = cursoRepository.findAll();

        // 2. Crear Profesores Extra (uno por area para variedad)
        crearProfesorDemo(ue, "Profesor Ciencias", "ciencias@gmail.com", "Lic. Biología");
        crearProfesorDemo(ue, "Profesor Lenguaje", "lenguaje@gmail.com", "Lic. Literatura");

        List<Profesor> profesores = profesorRepository.findAll();
        Random random = new Random();

        // 3. Poblar estudiantes por curso (3 por curso para no sobrecargar, total ~36
        // estudiantes)
        for (Curso curso : cursos) {
            log.info("Poblando curso: {} {} {}", curso.getGrado().getNivel(), curso.getGrado().getNombre(),
                    curso.getParalelo());

            // Asignar Materia y Profesor al Curso (Simulacro)
            Materia materia = materiaRepository.findAll().stream().findAny().orElse(null);

            // Check existence using findBy...
            boolean asignacionExists = false;
            if (materia != null) {
                // We don't have existsByCursoAndMateria, but we can iterate or try to query
                // differently.
                // Ideally we should use a proper check, but for demo let's rely on try/catch or
                // simple list check if repo method missing.
                // Actually AsignacionDocenteRepository has `findByProfesorAndCursoAndMateria`.
                // Let's assume we don't want to duplicate assignments for SAME course and
                // materia.
                // Let's iterate existing assignments for this course to check.
                // Or better, let's just skip this check or use the full
                // findByProfesorAndCursoAndMateria if we pick a professor first.

                // Since we pick a random professor:
                Profesor profe = profesores.get(random.nextInt(profesores.size()));

                if (asignacionDocenteRepository.findByProfesorAndCursoAndMateria(profe, curso, materia).isEmpty()) {
                    asignacionDocenteRepository.save(AsignacionDocente.builder()
                            .curso(curso)
                            .materia(materia)
                            .profesor(profe)
                            .gestion(gestion)
                            .estado(true)
                            .build());
                }
            }

            for (int i = 1; i <= 3; i++) {
                String email = "est_" + curso.getIdCurso() + "_" + i + "@demo.com";
                if (!usuarioRepository.existsByCorreo(email)) {
                    Usuario u = usuarioRepository.save(Usuario.builder()
                            .nombres("Estudiante " + i)
                            .apellidoPaterno("Curso " + curso.getGrado().getNombre())
                            .apellidoMaterno("Demo")
                            .ci("CI" + System.nanoTime()) // Unique CI
                            .correo(email)
                            .contrasena(passwordEncoder.encode("123456"))
                            .rol(rolEstudiante)
                            .unidadEducativa(ue)
                            .estado(true)
                            .build());

                    Estudiante est = estudianteRepository.save(Estudiante.builder()
                            .usuario(u)
                            .codigoRude("RUDE-" + u.getCi())
                            .direccion("Calle Demo 123")
                            // .fechaNacimiento(LocalDate.of(2010, 1, 1)) // Removed as not in entity
                            .build());

                    // Inscribir
                    inscripcionRepository.save(Inscripcion.builder()
                            .estudiante(est)
                            .curso(curso)
                            .gestion(gestion)
                            .fechaInscripcion(LocalDate.now())
                            .estado(EstadoInscripcion.ACTIVO)
                            .build());

                    // Generar Deuda y Pago Parcial
                    TipoPago mensualidad = tipoPagoRepository.findAll().stream().findFirst().orElse(null);
                    if (mensualidad != null) {
                        CuentaCobrar cc = cuentaCobrarRepository.save(CuentaCobrar.builder()
                                .estudiante(est)
                                .tipoPago(mensualidad)
                                .monto(mensualidad.getMontoDefecto())
                                .saldoPendiente(BigDecimal.ZERO) // Pagado
                                .fechaVencimiento(LocalDate.now().plusDays(30))
                                .estado(EstadoPago.PAGADO)
                                .build());

                        // Fake Pago
                        // Add cajero (can be null or any user, let's skip or use first user found if
                        // needed, checking Pago model... cajero is optional?)
                        // Pago model has `private Usuario cajero;`. It's nullable in DB usually unless
                        // constrained.
                        // Ideally we set a cajero. Let's use the first user as cajero (e.g. director).
                        Usuario cajero = usuarioRepository.findAll().get(0);

                        pagoRepository.save(Pago.builder()
                                .cuentaCobrar(cc)
                                .montoPagado(mensualidad.getMontoDefecto())
                                .fechaPago(java.time.LocalDateTime.now()) // Fixed type
                                .metodoPago(com.unidadeducativa.shared.enums.MetodoPago.EFECTIVO)
                                .numeroRecibo("REC-" + System.nanoTime())
                                .cajero(cajero)
                                .build());
                    }
                }
            }
        }
        log.info("SEEDING FINALIZADO.");
    }

    private void crearProfesorDemo(UnidadEducativa ue, String nombre, String email, String profesion) {
        if (!usuarioRepository.existsByCorreo(email)) {
            Rol rol = rolRepository.findByNombre(RolNombre.PROFESOR).orElseThrow();
            Usuario u = usuarioRepository.save(Usuario.builder()
                    .nombres(nombre)
                    .apellidoPaterno("Demo")
                    .ci(String.valueOf(System.currentTimeMillis()))
                    .correo(email)
                    .contrasena(passwordEncoder.encode("123456"))
                    .rol(rol)
                    .unidadEducativa(ue)
                    .estado(true)
                    .build());
            profesorRepository.save(Profesor.builder().usuario(u).profesion(profesion).build());
        }
    }
}
