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
import org.springframework.core.annotation.Order;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Component
@Order(1)
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
    private final com.unidadeducativa.academia.gradomateria.repository.GradoMateriaRepository gradoMateriaRepository;

    // Repositorios Finanzas
    private final TipoPagoRepository tipoPagoRepository;
    private final CuentaCobrarRepository cuentaCobrarRepository;

    private final jakarta.persistence.EntityManager entityManager;

    @Override
    @org.springframework.transaction.annotation.Transactional
    public void run(String... args) {
        try {
            log.info("Inicializando datos base...");

            // 0. MIGRATION RAW SQL: Fix 'ALUMNO' to 'ESTUDIANTE' to avoid Enum mapping
            // error
            try {
                entityManager.createNativeQuery("ALTER TABLE rol DROP CONSTRAINT IF EXISTS rol_nombre_check")
                        .executeUpdate();
                entityManager.createNativeQuery("UPDATE rol SET nombre = 'ESTUDIANTE' WHERE nombre = 'ALUMNO'")
                        .executeUpdate();
                log.info("MIGRATION SQL: Updated 'ALUMNO' roles to 'ESTUDIANTE'");

                // FIX DUPLICATE MATERIAS (Matemática -> Matemáticas)
                entityManager.createNativeQuery("UPDATE materia SET nombre = 'Matemáticas' WHERE nombre = 'Matemática'")
                        .executeUpdate();

                // MERGE DUPLICATES
                List<Object> ids = entityManager
                        .createNativeQuery(
                                "SELECT id_materia FROM materia WHERE nombre = 'Matemáticas' ORDER BY id_materia ASC")
                        .getResultList();
                if (ids.size() > 1) {
                    Long masterId = ((Number) ids.get(0)).longValue();
                    log.info("Merging duplicates for Matemáticas into ID: " + masterId);
                    for (int i = 1; i < ids.size(); i++) {
                        Long duplicateId = ((Number) ids.get(i)).longValue();
                        // Delete GradoMateria for duplicate (SchoolInit will ensure Master is linked)
                        entityManager.createNativeQuery("DELETE FROM grado_materia WHERE id_materia = :dup")
                                .setParameter("dup", duplicateId)
                                .executeUpdate();

                        // 1a. Delete Notes on Master that collide with Notes on Dup (prefer Dup, so
                        // remove Master's)
                        entityManager.createNativeQuery(
                                "DELETE FROM nota n_master " +
                                        "USING asignacion_docente ad_master " +
                                        "WHERE n_master.id_asignacion = ad_master.id_asignacion " +
                                        "AND ad_master.id_materia = :master " +
                                        "AND EXISTS ( " +
                                        "  SELECT 1 FROM nota n_dup " +
                                        "  JOIN asignacion_docente ad_dup ON n_dup.id_asignacion = ad_dup.id_asignacion "
                                        +
                                        "  WHERE ad_dup.id_materia = :dup " +
                                        "  AND n_dup.id_estudiante = n_master.id_estudiante " +
                                        "  AND n_dup.trimestre = n_master.trimestre " +
                                        "  AND ad_dup.id_profesor = ad_master.id_profesor " +
                                        "  AND ad_dup.id_curso = ad_master.id_curso " +
                                        "  AND ad_dup.id_gestion = ad_master.id_gestion " +
                                        ")")
                                .setParameter("dup", duplicateId)
                                .setParameter("master", masterId)
                                .executeUpdate();

                        // 1b. Move Notes from Duplicate Asignacion to Master Asignacion (now safe from
                        // collision)
                        entityManager.createNativeQuery(
                                "UPDATE nota SET id_asignacion = ad_master.id_asignacion " +
                                        "FROM asignacion_docente ad_dup, asignacion_docente ad_master " +
                                        "WHERE nota.id_asignacion = ad_dup.id_asignacion " +
                                        "AND ad_dup.id_materia = :dup " +
                                        "AND ad_master.id_materia = :master " +
                                        "AND ad_dup.id_profesor = ad_master.id_profesor " +
                                        "AND ad_dup.id_curso = ad_master.id_curso " +
                                        "AND ad_dup.id_gestion = ad_master.id_gestion")
                                .setParameter("dup", duplicateId)
                                .setParameter("master", masterId)
                                .executeUpdate();

                        // 1c. Delete Horarios linked to Duplicate Asignacion (to allow deletion of
                        // Asignacion)
                        entityManager.createNativeQuery(
                                "DELETE FROM horarios WHERE id_asignacion IN (SELECT id_asignacion FROM asignacion_docente WHERE id_materia = :dup)")
                                .setParameter("dup", duplicateId)
                                .executeUpdate();

                        // 2. Delete Duplicate Asignaciones that successfully moved notes (collided)
                        entityManager.createNativeQuery(
                                "DELETE FROM asignacion_docente ad_dup " +
                                        "WHERE ad_dup.id_materia = :dup " +
                                        "AND EXISTS (SELECT 1 FROM asignacion_docente ad_master " +
                                        "WHERE ad_master.id_materia = :master " +
                                        "AND ad_master.id_profesor = ad_dup.id_profesor " +
                                        "AND ad_master.id_curso = ad_dup.id_curso " +
                                        "AND ad_master.id_gestion = ad_dup.id_gestion)")
                                .setParameter("dup", duplicateId)
                                .setParameter("master", masterId)
                                .executeUpdate();

                        // 3. Relink execution remaining AsignacionDocente (no collision)
                        entityManager
                                .createNativeQuery(
                                        "UPDATE asignacion_docente SET id_materia = :master WHERE id_materia = :dup")
                                .setParameter("master", masterId)
                                .setParameter("dup", duplicateId)
                                .executeUpdate();

                        // Delete Duplicate Materia
                        entityManager.createNativeQuery("DELETE FROM materia WHERE id_materia = :dup")
                                .setParameter("dup", duplicateId)
                                .executeUpdate();
                    }
                }
                log.info("MIGRATION SQL: Fixed duplicate 'Matemáticas'");

            } catch (Exception e) {
                log.warn("Migration SQL failed (might be harmless if first run): " + e.getMessage());
                e.printStackTrace(); // PRINT TRACE FOR MIGRATION
            }

            // 0.5 MIGRATION: Fix NULL dimensions in Nota table for existing records
            try {
                // Check if we need to update nulls to 0.0
                int updated = entityManager.createNativeQuery(
                        "UPDATE nota SET " +
                                "ser = COALESCE(ser, 0), " +
                                "saber = COALESCE(saber, 0), " +
                                "hacer = COALESCE(hacer, 0), " +
                                "decidir = COALESCE(decidir, 0), " +
                                "autoevaluacion = COALESCE(autoevaluacion, 0), " +
                                "nota_final = COALESCE(nota_final, valor, 0) " + // Copy from old valor if needed
                                "WHERE ser IS NULL OR nota_final IS NULL")
                        .executeUpdate();
                if (updated > 0) {
                    log.info("MIGRATION SQL: Updated {} notes with NULL dimensions/nota_final.", updated);
                }
            } catch (Exception e) {
                log.warn("Migration 0.5 failed (maybe columns don't exist yet/first run?): " + e.getMessage());
            }

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

        } catch (Exception e) {
            log.error("CRITICAL ERROR IN DATA INITIALIZER", e);
            e.printStackTrace();
            throw e; // Rethrow to fail startup if critical
        }
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
                    RolNombre.ESTUDIANTE, ue, usuario -> {
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
            // SELF-HEALING: Fix missing UnidadEducativa for existing users
            if (usuario.getUnidadEducativa() == null) {
                log.warn("Usuario {} encontrado sin Unidad Educativa. Reparando...", correo);
                usuario.setUnidadEducativa(ue);
                usuario = usuarioRepository.save(usuario);
            }
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

        // Materia: Buscar la que corresponde al Grado en la Malla Curricular
        List<com.unidadeducativa.academia.gradomateria.model.GradoMateria> gradoMaterias = gradoMateriaRepository
                .findByGradoAndGestion(curso.getGrado(), gestion);

        Materia materia = gradoMaterias.stream()
                .map(gm -> gm.getMateria())
                .filter(m -> m.getNombre().toUpperCase().contains("MATEMÁTICA")) // Busca Matemáticas o Matemática
                .findFirst()
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
                        .notaFinal((double) Math.round(valorNota * 100) / 100) // Changed from .valor() to .notaFinal()
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
                        .unidadEducativa(ue)
                        .build()));

        if (tipoPago.getUnidadEducativa() == null) {
            tipoPago.setUnidadEducativa(ue);
            tipoPagoRepository.save(tipoPago);
        }

        // Generar deuda para todos los estudiantes
        List<Estudiante> estudiantes = estudianteRepository.findAll();
        for (Estudiante est : estudiantes) {
            if (!cuentaCobrarRepository.existsByEstudianteAndTipoPago(est, tipoPago)) {
                cuentaCobrarRepository.save(CuentaCobrar.builder()
                        .estudiante(est)
                        .tipoPago(tipoPago)
                        .monto(tipoPago.getMontoDefecto())
                        .saldoPendiente(tipoPago.getMontoDefecto()) // Todo pendiente
                        .fechaVencimiento(LocalDate.of(2026, 2, 28)) // Future date to avoid blocking
                        .estado(EstadoPago.PENDIENTE)
                        .build());
                log.info("Deuda generada para {}", est.getUsuario().getNombres());
            }
        }
    }
}