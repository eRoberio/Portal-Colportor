import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../infrastructure/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

final authStateProvider = StreamProvider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
});

final currentUserProfileProvider = StreamProvider<Map<String, dynamic>?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((snapshot) => snapshot.data());
    },
    loading: () => Stream.value(null),
    error: (err, stack) => Stream.value(null), // Corrigido os underscores aqui
  );
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AsyncData(null));

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.signIn(email, password));
  }

  Future<void> register({
    required String email,
    required String password,
    required String nome,
    required String telefone,
    required String motivo,
    required String inviteCode,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.signUp(
        email: email,
        password: password,
        nome: nome,
        telefone: telefone,
        motivo: motivo,
        inviteCode: inviteCode,
      ),
    );
  }

  Future<void> recoverPassword(String email) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.resetPassword(email));
  }

  Future<void> confirmPasswordReset(String code, String newPassword) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.confirmPasswordReset(code, newPassword),
    );
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repository.signOut());
  }

  // A função updateProfile agora está no lugar certo!
  Future<void> updateProfile(String uid, Map<String, dynamic> data) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _repository.updateUserProfile(uid, data),
    );
  }

  // NOVO: Função para enviar foto para ImgBB e atualizar Firestore
  Future<void> uploadProfilePicture(String uid, Uint8List imageBytes) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. Prepara a requisição para o ImgBB com sua API Key
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['key'] = 'c4f0cbac5be04b616817ca5aaf1dbd59'
        ..files.add(
          http.MultipartFile.fromBytes(
            'image',
            imageBytes,
            filename: 'profile.png',
          ),
        );

      // 2. Envia a imagem
      final response = await request.send();

      // 3. Processa a resposta
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final json = jsonDecode(responseData);
        final imageUrl = json['data']['url']; // Pega o link direto da imagem

        // 4. Salva a URL no Firebase
        await _repository.updateUserProfile(uid, {'fotoUrl': imageUrl});
      } else {
        throw Exception('Falha ao enviar a imagem para o servidor.');
      }
    });
  }
}

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
      final repository = ref.watch(authRepositoryProvider);
      return AuthController(repository);
    });
