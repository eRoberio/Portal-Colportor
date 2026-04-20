import 'package:colportportal/application/auth/auth_provider.dart';
import 'package:colportportal/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Variáveis globais para controle de link de redefinição
String? linkMode;
String? linkCode;

class ResetPasswordPage extends ConsumerStatefulWidget {
  final String oobCode;
  const ResetPasswordPage({super.key, required this.oobCode});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🔑 Criar Nova Senha',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Digite a nova senha',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          if (_passwordController.text.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'A senha deve ter no mínimo 6 caracteres.',
                                ),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                            return;
                          }

                          // Envia a nova senha e o código da URL pro Firebase
                          await ref
                              .read(authControllerProvider.notifier)
                              .confirmPasswordReset(
                                widget.oobCode,
                                _passwordController.text,
                              );

                          // Se não deu erro, fazemos a festa!
                          if (!ref.read(authControllerProvider).hasError &&
                              context.mounted) {
                            // 1. MOSTRA A MENSAGEM VERDE
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  '✅ Senha alterada com sucesso! Faça login.',
                                ),
                                backgroundColor: Colors
                                    .green, // <-- Cor verde adicionada aqui!
                                behavior: SnackBarBehavior
                                    .floating, // Fica flutuando, mais moderno
                              ),
                            );

                            // 2. LIMPA A MEMÓRIA PARA NÃO TRAVAR NA TELA DE RECUPERAÇÃO
                            linkMode = null;
                            linkCode = null;

                            // 3. REDIRECIONA PARA O LOGIN (Limpando o histórico de navegação)
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginPage(),
                              ),
                              (route) => false,
                            );
                          }
                        },
                        child: const Text('Salvar Nova Senha'),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
