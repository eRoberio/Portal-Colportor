enum Role { admin, colportor }
enum Setor { efetivo, estudante, administrativo, nenhum }
enum ColportorStatus { pending, approved, rejected }

class Colportor {
  final String id;
  final String nome;
  final String email;
  final String telefone;
  final Role role;
  final Setor setor;
  final ColportorStatus status;
  final String? fotoUrl;

  Colportor({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.role,
    required this.setor,
    required this.status,
    this.fotoUrl,
  });

  // Facilita a criação de cópias mutáveis do objeto (comum no Riverpod)
  Colportor copyWith({
    String? id,
    String? nome,
    String? email,
    String? telefone,
    Role? role,
    Setor? setor,
    ColportorStatus? status,
    String? fotoUrl,
  }) {
    return Colportor(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone ?? this.telefone,
      role: role ?? this.role,
      setor: setor ?? this.setor,
      status: status ?? this.status,
      fotoUrl: fotoUrl ?? this.fotoUrl,
    );
  }
}