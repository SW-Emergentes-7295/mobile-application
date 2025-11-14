class Trip {
  final String titulo;
  final String fecha;
  final String hora;
  final String lugar;

  Trip({
    required this.titulo,
    required this.fecha,
    required this.hora,
    required this.lugar,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      titulo: json['titulo'],
      fecha: json['fecha'],
      hora: json['hora'],
      lugar: json['lugar'],
    );
  }
}
