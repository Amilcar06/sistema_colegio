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
import com.unidadeducativa.finanzas.model.TipoPago;
import com.unidadeducativa.finanzas.repository.CuentaCobrarRepository;
import com.unidadeducativa.finanzas.repository.TipoPagoRepository;
import com.unidadeducativa.institucion.model.UnidadEducativa;
import com.unidadeducativa.institucion.repository.UnidadEducativaRepository;
import com.unidadeducativa.institucion.service.SchoolInitializationService;
import com.unidadeducativa.personas.director.model.Director;
import com.unidadeducativa.personas.director.repository.DirectorRepository;
import com.unidadeducativa.personas.estudiante.model.Estudiante;
import com.unidadeducativa.personas.estudiante.repository.EstudianteRepository;
import com.unidadeducativa.personas.profesor.model.Profesor;
import com.unidadeducativa.personas.profesor.repository.ProfesorRepository;
import com.unidadeducativa.personas.secretaria.model.Secretaria;
import com.unidadeducativa.personas.secretaria.repository.SecretariaRepository;
import com.unidadeducativa.shared.enums.EstadoInscripcion;
import com.unidadeducativa.shared.enums.EstadoPago;
import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.shared.enums.TipoTurno;
import com.unidadeducativa.shared.enums.Trimestre;
import com.unidadeducativa.usuario.model.Rol;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Component
@RequiredArgsConstructor
@Slf4j
public class DataInitializer implements CommandLineRunner {

    private final RolRepository rolRepository;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final UnidadEducativaRepository unidadEducativaRepository;
    private final SchoolInitializationService schoolInitializationService;

    // Repositorios de Personas
    private final DirectorRepository directorRepository;
    private final SecretariaRepository secretariaRepository;
    private final ProfesorRepository profesorRepository;
    private final EstudianteRepository estudianteRepository;

    // Repositorios Académicos
    private final CursoRepository cursoRepository;
    private final GestionRepository gestionRepository;
    private final GradoRepository gradoRepository;
    private final MateriaRepository materiaRepository;
    private final AsignacionDocenteRepository asignacionDocenteRepository;
    private final InscripcionRepository inscripcionRepository;
    private final NotaRepository notaRepository;

    // Repositorios Finanzas
    private final TipoPagoRepository tipoPagoRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;

    @Override
    public void run(String... args) {
        log.info("Inicializando datos base...");

        // 1. Roles
        inicializarRoles();

        // 2. Unidad Educativa y Configuración Inicial
        UnidadEducativa ue = inicializarUnidadEducativa();

        // 3. Inicializar Malla y Gestión (SchoolInitializationService)
        schoolInitializationService.initializeSchool(ue);

        // 4. Usuarios por Defecto
        inicializarUsuarios(ue);

        // 5. Cursos para la Gestión Actual (si no existen)
        inicializarCursos(ue);

        // 6. Registros Académicos (Materia->Profesor->Inscripción->Notas)
        inicializarRegistrosAcademicos(ue);

        // 7. Finanzas (Tipos de Pago -> Cuentas por Cobrar)
        inicializarFinanzas(ue);

        log.info("Inicialización completada exitosamente.");
    }

    private void inicializarRoles() {
        for (RolNombre rolNombre : RolNombre.values()) {
            rolRepository.findByNombre(rolNombre)
                    .orElseGet(() -> {
                        Rol nuevoRol = rolRepository.save(new Rol(null, rolNombre));
                        log.info("Rol creado: {}", nuevoRol.getNombre());
                        return nuevoRol;
                    });
        }
    }

    private UnidadEducativa inicializarUnidadEducativa() {
        return unidadEducativaRepository.findBySie("808080") // SIE ficticio
                .orElseGet(() -> unidadEducativaRepository.save(UnidadEducativa.builder()
                        .nombre("Unidad Educativa San Andrés")
                        .sie("808080")
                        .direccion("Av. Villazon N 1995")
                        .estado(true)
                        .build()));
    }

    private void inicializarUsuarios(UnidadEducativa ue) {
        // Director
        crearUsuarioSiNoExiste("director@gmail.com", "Juan", "Director", "Perez", RolNombre.DIRECTOR, ue, usuario -> {
            if (directorRepository.findByUsuario(usuario).isEmpty()) {
                directorRepository.save(Director.builder().usuario(usuario).build());
                log.info("Director creado y asignado.");
            }
        });

        // Secretaria
        crearUsuarioSiNoExiste("secretaria@gmail.com", "Ana", "Secretaria", "Lopez", RolNombre.SECRETARIA, ue,
                usuario -> {
                    if (secretariaRepository.findByUsuario(usuario).isEmpty()) {
                        secretariaRepository.save(Secretaria.builder().usuario(usuario).build());
                        log.info("Secretaria creada y asignada.");
                    }
                });

        // Profesor
        crearUsuarioSiNoExiste("profesor@gmail.com", "Carlos", "Profe", "Gomez", RolNombre.PROFESOR, ue, usuario -> {
            if (profesorRepository.findByUsuario(usuario).isEmpty()) {
                profesorRepository.save(Profesor.builder().usuario(usuario).profesion("Lic. Matemáticas").build());
                log.info("Profesor creado y asignado.");
            }
        });

        // Estudiantes (5 ejemplos)
        for (int i = 1; i <= 5; i++) {
            final int index = i; // Capture for lambda
            crearUsuarioSiNoExiste("estudiante" + i + "@gmail.com", "Estudiante" + i, "Apellido" + i, "Mamani",
                    RolNombre.ALUMNO, ue, usuario -> {
                        if (estudianteRepository.findByUsuario(usuario).isEmpty()) {
                            estudianteRepository.save(Estudiante.builder()
                                    .usuario(usuario)
                                    .codigoRude("RUDE-" + usuario.getCi())
                                    .direccion("Av. Siempre Viva 123")
                                    .nombrePadre("Padre Test " + index)
                                    .telefonoPadre("7000000" + index)
                                    .nombreMadre("Madre Test " + index)
                                    .telefonoMadre("6000000" + index)
                                    .build());
                            log.info("Estudiante {} creado con datos completos.", usuario.getCorreo());
                        }
                    });
        }
    }

    private void crearUsuarioSiNoExiste(String correo, String nombre, String apPaterno, String apMaterno,
            RolNombre rolNombre, UnidadEducativa ue, java.util.function.Consumer<Usuario> onCreated) {
        if (!usuarioRepository.existsByCorreo(correo)) {
            Rol rol = rolRepository.findByNombre(rolNombre)
                    .orElseThrow(() -> new RuntimeException("Rol no encontrado: " + rolNombre));

            Usuario usuario = Usuario.builder()
                    .nombres(nombre)
                    .apellidoPaterno(apPaterno)
                    .apellidoMaterno(apMaterno)
                    .ci(String.valueOf(System.currentTimeMillis() % 100000000)) // CI random seguro
                    .correo(correo)
                    .contrasena(passwordEncoder.encode("123456"))
                    .rol(rol)
                    .unidadEducativa(ue)
                    .estado(true)
                    .build();

            usuario = usuarioRepository.save(usuario);
            log.info("Usuario creado: {}", correo);
            onCreated.accept(usuario);
        } else {
            Usuario usuario = usuarioRepository.findByCorreo(correo).get();
            onCreated.accept(usuario);
        }
    }

    private void inicializarCursos(UnidadEducativa ue) {
        int year = LocalDate.now().getYear();
        GestionAcademica gestion = gestionRepository
                .findByAnioAndUnidadEducativa_IdUnidadEducativa(year, ue.getIdUnidadEducativa())
                .orElseThrow(() -> new RuntimeException("Gestión no encontrada."));

        // Crear paralelos A para secundaria
        List<Grado> gradosSecundaria = gradoRepository
                .findByNivel(com.unidadeducativa.shared.enums.TipoNivel.SECUNDARIA);
        for (Grado grado : gradosSecundaria) {
            if (!cursoRepository.existsByGrado_IdGradoAndParaleloAndTurno(grado.getIdGrado(), "A", TipoTurno.MANANA)) {
                Curso curso = Curso.builder()
                        .paralelo("A")
                        .turno(TipoTurno.MANANA)
                        .grado(grado)
                        .build();
                cursoRepository.save(curso);
                log.info("Curso creado: {} - A", grado.getNombre());
            }
        }
    }

    private void inicializarRegistrosAcademicos(UnidadEducativa ue) {
        // Obtener gestión
        int year = LocalDate.now().getYear();
        GestionAcademica gestion = gestionRepository
                .findByAnioAndUnidadEducativa_IdUnidadEducativa(year, ue.getIdUnidadEducativa())
                .orElseThrow();

        // Obtener curso: "Primero de Secundaria A"
        Optional<Curso> opCurso = cursoRepository.findAll().stream()
                .filter(c -> c.getGrado().getNombre().equals("PRIMERO") && c.getParalelo().equals("A"))
                .findFirst();

        if (opCurso.isEmpty())
            return;
        Curso curso = opCurso.get();

        // Obtener Profesor
        Usuario userProf = usuarioRepository.findByCorreo("profesor@gmail.com").orElse(null);
        if (userProf == null)
            return;
        Profesor profesor = profesorRepository.findByUsuario(userProf).orElse(null);
        if (profesor == null)
            return;

        // Materia: Matemáticas
        Materia materia = materiaRepository.findByNombre("Matemáticas").stream().findFirst()
                .orElseGet(() -> materiaRepository.save(Materia.builder()
                        .nombre("Matemáticas")
                        .build()));

        // Asignación Docente (Profesor -> Matemáticas -> Curso)
        AsignacionDocente asignacion = asignacionDocenteRepository
                .findByProfesorAndCursoAndMateria(profesor, curso, materia)
                .orElseGet(() -> asignacionDocenteRepository.save(AsignacionDocente.builder()
                        .profesor(profesor)
                        .curso(curso)
                        .materia(materia)
                        .gestion(gestion)
                        .estado(true)
                        .build()));
        log.info("Asignación docente verificada: Matemáticas en 1ro A");

        // Inscripciones y Notas para los 5 estudiantes test
        List<Estudiante> estudiantes = estudianteRepository.findAll();

        for (Estudiante est : estudiantes) {
            // Verificar si el estudiante está activo y pertenece a la UE (en test local
            // asumo todos)
            // Inscribir en 1ro A si no tiene inscripción
            Optional<Inscripcion> opInsc = inscripcionRepository.findByEstudianteAndGestion(est, gestion);
            Inscripcion inscripcion;
            if (opInsc.isEmpty()) {
                inscripcion = inscripcionRepository.save(Inscripcion.builder()
                        .estudiante(est)
                        .curso(curso)
                        .gestion(gestion)
                        .fechaInscripcion(LocalDate.now())
                        .estado(EstadoInscripcion.ACTIVO)
                        .build());
                log.info("Estudiante {} inscrito en 1ro A", est.getUsuario().getNombres());
            } else {
                inscripcion = opInsc.get();
            }

            // Crear Nota Random en Primer Trimestre para Matemáticas
            if (!notaRepository.existsByEstudianteAndAsignacionAndTrimestre(est, asignacion, Trimestre.PRIMER)) {
                // Random nota entre 51 y 100
                double valorNota = 51 + (Math.random() * 49);
                notaRepository.save(Nota.builder()
                        .estudiante(est)
                        .asignacion(asignacion)
                        .trimestre(Trimestre.PRIMER)
                        .valor((double) Math.round(valorNota * 100) / 100)
                        .fechaRegistro(LocalDate.now())
                        .build());
                log.info("Nota registrada para {}", est.getUsuario().getNombres());
            }
        }
    }

    private void inicializarFinanzas(UnidadEducativa ue) {
        // Get current gestion
        int year = LocalDate.now().getYear();
        GestionAcademica gestion = gestionRepository
                .findByAnioAndUnidadEducativa_IdUnidadEducativa(year, ue.getIdUnidadEducativa())
                .orElseThrow();

        // Tipo Pago: Mensualidad Febrero
        TipoPago tipoPago = tipoPagoRepository.findByNombre("Mensualidad Febrero 2025")
                .orElseGet(() -> tipoPagoRepository.save(TipoPago.builder()
                        .nombre("Mensualidad Febrero 2025")
                        .montoDefecto(new BigDecimal("350.00"))
                        .gestion(gestion)
                        .build()));

        // Generar deuda para todos los estudiantes
        List<Estudiante> estudiantes = estudianteRepository.findAll();
        for (Estudiante est : estudiantes) {
            if (!cuentaCobrarRepository.existsByEstudianteAndTipoPago(est, tipoPago)) {
                cuentaCobrarRepository.save(CuentaCobrar.builder()
                        .estudiante(est)
                        .tipoPago(tipoPago)
                        .monto(tipoPago.getMontoDefecto())
                        .saldoPendiente(tipoPago.getMontoDefecto()) // Todo pendiente
                        .fechaVencimiento(LocalDate.of(2025, 2, 28))
                        .estado(EstadoPago.PENDIENTE)
                        .build());
                log.info("Deuda generada para {}", est.getUsuario().getNombres());
            }
        }
    }
}