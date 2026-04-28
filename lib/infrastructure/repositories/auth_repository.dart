import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // A linha abaixo resolve o erro do "_firestore"
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<void> signIn(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String nome,
    required String telefone,
    required String motivo,
    required String inviteCode,
    required String categoria, // <--- ADICIONE AQUI
  }) async {
    // 1. VERIFICA O CÓDIGO NO BANCO PRIMEIRO
    final codeRef = _firestore.collection('invite_codes').doc(inviteCode);
    final codeDoc = await codeRef.get();

    if (!codeDoc.exists) {
      throw Exception(
        'Código de convite inválido. Verifique o que foi digitado.',
      );
    }

    if (codeDoc.data()?['used'] == true) {
      throw Exception('Este código já foi utilizado por outra pessoa.');
    }

    // 2. SE O CÓDIGO É VÁLIDO, CRIA A CONTA (Pode dar erro se e-mail já existir)
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (credential.user != null) {
      // 3. OPERAÇÃO EM LOTE (Segurança Máxima)
      final batch = _firestore.batch();

      // A. Salva o perfil do usuário (Flag inicial: colportor)
      final userRef = _firestore.collection('users').doc(credential.user!.uid);
      batch.set(userRef, {
        'id': credential.user!.uid,
        'nome': nome,
        'email': email,
        'telefone': telefone,
        'motivo_solicitacao': motivo,
        'role': 'colportor', // A flag padrão inicial que você pediu
        'categoria':
            categoria, // <--- SALVA NO BANCO AQUI (efetivo ou estudante)
        'fotoUrl': '',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // B. "Queima" o código de convite para nunca mais ser usado
      batch.update(codeRef, {
        'used': true,
        'usedBy': credential.user!.uid, // Registra quem usou para auditoria
        'usedAt': FieldValue.serverTimestamp(),
      });

      // Executa as duas ações juntas
      await batch.commit();
    }
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> confirmPasswordReset(String code, String newPassword) async {
    await _auth.confirmPasswordReset(code: code, newPassword: newPassword);
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Função para atualizar os dados do perfil
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(uid).update(data);
  }
}
