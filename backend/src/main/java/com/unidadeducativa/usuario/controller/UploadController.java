package com.unidadeducativa.usuario.controller;

import com.unidadeducativa.exceptions.NotFoundException;
import com.unidadeducativa.usuario.model.Usuario;
import com.unidadeducativa.usuario.repository.UsuarioRepository;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.Map;
import java.util.Objects;

@RestController
@RequestMapping("/api/uploads")
@RequiredArgsConstructor
@Tag(name = "Uploads", description = "Carga de archivos")
public class UploadController {

    private final UsuarioRepository usuarioRepository;

    @Operation(summary = "Subir foto de perfil (Usuario autenticado)")
    @io.swagger.v3.oas.annotations.responses.ApiResponses({
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "200", description = "Foto subida correctamente. Devuelve la URL de la imagen (clave 'url').", content = @io.swagger.v3.oas.annotations.media.Content(mediaType = "application/json", schema = @io.swagger.v3.oas.annotations.media.Schema(example = "{\"url\": \"http://localhost:8080/uploads/perfil/1_123456789.jpg\"}"))),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "404", description = "Usuario no encontrado"),
            @io.swagger.v3.oas.annotations.responses.ApiResponse(responseCode = "500", description = "Error al guardar el archivo")
    })
    @PostMapping(value = "/perfil", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<Map<String, String>> subirFotoPerfil(
            @RequestParam("file") MultipartFile file,
            Authentication authentication) throws IOException {

        String email = authentication.getName();
        Usuario usuario = usuarioRepository.findByCorreo(email)
                .orElseThrow(() -> new NotFoundException("Usuario no encontrado"));

        String fileName = StringUtils.cleanPath(Objects.requireNonNull(file.getOriginalFilename()));
        String uploadDir = "uploads/perfil";

        // Guardar archivo
        Path uploadPath = Paths.get(uploadDir);
        if (!Files.exists(uploadPath)) {
            Files.createDirectories(uploadPath);
        }

        // Renombrar archivo para evitar duplicados/conflictos (ej:
        // usuarioId_timestamp.ext)
        String fileExtension = "";
        int i = fileName.lastIndexOf('.');
        if (i > 0) {
            fileExtension = fileName.substring(i);
        }
        String newFileName = usuario.getIdUsuario() + "_" + System.currentTimeMillis() + fileExtension;

        try (InputStream inputStream = file.getInputStream()) {
            Path filePath = uploadPath.resolve(newFileName);
            Files.copy(inputStream, filePath, StandardCopyOption.REPLACE_EXISTING);
        }

        // Generar URL
        String fileUrl = ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/uploads/perfil/")
                .path(newFileName)
                .toUriString();

        // Actualizar usuario
        usuario.setFotoPerfil(fileUrl);
        usuarioRepository.save(usuario);

        return ResponseEntity.ok(Map.of("url", fileUrl));
    }
}
