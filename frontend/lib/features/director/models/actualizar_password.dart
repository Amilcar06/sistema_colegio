class ActualizarPasswordDTO {
  final String passwordActual;
  final String nuevaPassword;

  ActualizarPasswordDTO({
    required this.passwordActual,
    required this.nuevaPassword,
  });

  Map<String, dynamic> toJson() => {
    'passwordActual': passwordActual,
    'nuevaPassword': nuevaPassword,
  };
}
