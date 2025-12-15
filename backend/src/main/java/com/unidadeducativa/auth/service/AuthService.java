package com.unidadeducativa.auth.service;

import com.unidadeducativa.auth.dto.LoginRequest;
import com.unidadeducativa.auth.dto.LoginResponse;
import com.unidadeducativa.auth.dto.RegistroInstitucionRequest;
import com.unidadeducativa.auth.security.JwtTokenProvider;
import com.unidadeducativa.institucion.model.UnidadEducativa;
import com.unidadeducativa.institucion.repository.UnidadEducativaRepository;
import com.unidadeducativa.institucion.service.SchoolInitializationService;
import com.unidadeducativa.personas.director.model.Director;
import com.unidadeducativa.personas.director.repository.DirectorRepository;
import com.unidadeducativa.shared.enums.RolNombre;
import com.unidadeducativa.usuario.model.Rol;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.RolRepository;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuthService {

        private final AuthenticationManager authenticationManager;
        private final UsuarioRepository usuarioRepository;
        private final JwtTokenProvider jwtTokenProvider;
        private final UserDetailsService userDetailsService;
        private final UnidadEducativaRepository unidadEducativaRepository;
        private final RolRepository rolRepository;
        private final PasswordEncoder passwordEncoder;
        private final DirectorRepository directorRepository;
        private final SchoolInitializationService schoolInitializationService;

        public LoginResponse login(LoginRequest request) {
                // 1. Autenticar credenciales
                authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(
                                                request.getCorreo(),
                                                request.getPassword()));

                // 2. Cargar detalles de usuario y generar JWT
                UserDetails userDetails = userDetailsService.loadUserByUsername(request.getCorreo());
                Usuario usuario = usuarioRepository.findByCorreo(request.getCorreo())
                                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

                String token = jwtTokenProvider.generateToken(userDetails);

                // 3. Construir respuesta
                return LoginResponse.builder()
                                .token(token)
                                .correo(usuario.getCorreo())
                                .nombreCompleto(usuario.getNombres() + " " + usuario.getApellidoPaterno())
                                .rol(usuario.getRol().getNombre().name())
                                .build();
        }

        @Transactional
        public LoginResponse registrarInstitucion(RegistroInstitucionRequest request) {
                // 1. Validar duplicados
                if (unidadEducativaRepository.existsBySie(request.getSie())) {
                        throw new RuntimeException("El código SIE ya está registrado");
                }
                if (usuarioRepository.existsByCorreo(request.getCorreoDirector())) {
                        throw new RuntimeException("El correo ya está registrado");
                }

                // 2. Crear Unidad Educativa
                UnidadEducativa unidad = UnidadEducativa.builder()
                                .nombre(request.getNombreInstitucion())
                                .sie(request.getSie())
                                .direccion(request.getDireccion())
                                .logoUrl(request.getLogoUrl())
                                .estado(true)
                                .build();
                unidad = unidadEducativaRepository.save(unidad);

                // 3. Crear Usuario Director
                Rol rolDirector = rolRepository.findByNombre(RolNombre.DIRECTOR)
                                .orElseThrow(() -> new RuntimeException("Rol DIRECTOR no encontrado"));

                Usuario usuario = Usuario.builder()
                                .nombres(request.getNombreDirector())
                                .apellidoPaterno(request.getApellidoDirector())
                                .ci(request.getCiDirector())
                                .correo(request.getCorreoDirector())
                                .contrasena(passwordEncoder.encode(request.getPasswordDirector()))
                                .rol(rolDirector)
                                .unidadEducativa(unidad)
                                .build();
                usuario = usuarioRepository.save(usuario);

                // 4. Crear Entidad Persona Director
                Director director = Director.builder()
                                .usuario(usuario)
                                .build();
                directorRepository.save(director);

                // 5. Inicializar Malla Curricular
                schoolInitializationService.initializeSchool(unidad);

                // 6. Auto-Login
                authenticationManager.authenticate(
                                new UsernamePasswordAuthenticationToken(request.getCorreoDirector(),
                                                request.getPasswordDirector()));
                String token = jwtTokenProvider
                                .generateToken(userDetailsService.loadUserByUsername(request.getCorreoDirector()));

                return LoginResponse.builder()
                                .token(token)
                                .correo(usuario.getCorreo())
                                .nombreCompleto(usuario.getNombreCompleto())
                                .rol(rolDirector.getNombre().name())
                                .build();
        }
}
