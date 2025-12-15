class RolResponseDTO {
  final int idRol;
  final String nombre;

  RolResponseDTO({
    required this.idRol,
    required this.nombre,
  });

  factory RolResponseDTO.fromJson(Map<String, dynamic> json) => RolResponseDTO(
    idRol: json['idRol'] ?? 0,
    nombre: json['nombre'] ?? '',
  );
}
