class User {
  final String id;
  final String nombre;
  final String email;
  final String rol; // 'admin' or 'client'
  final bool activo;
  final String descripcion; // opcional
  final String? password; // solo para crear/actualizar

  User({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    this.descripcion = '',
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'client',
      activo: json['activo'] ?? true,
      descripcion: json['descripcion'] ?? '',
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'activo': activo,
        'descripcion': descripcion,
        if (password != null) 'password': password,
      };
}
