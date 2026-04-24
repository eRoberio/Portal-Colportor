import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // <-- Importe o Riverpod
import '../../application/auth/auth_provider.dart'; // <-- Importe nosso provedor

enum AuthFormType { login, register, recover }

// Mude de StatefulWidget para ConsumerStatefulWidget
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

// Mude de State para ConsumerState
class _LoginPageState extends ConsumerState<LoginPage> {
  AuthFormType _currentForm = AuthFormType.login;
  String _selectedCategoria = 'estudante'; // Padrão

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _inviteCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _motivationController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _switchForm(AuthFormType formType) {
    setState(() {
      _currentForm = formType;
    });
  }

  // Função para exibir mensagens de erro ou sucesso
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fica "ouvindo" o estado do provedor (Loading, Sucesso, Erro)
    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          // LÓGICA ATUALIZADA: Limpa a palavra "Exception: " de qualquer erro do Firebase
          final cleanError = error.toString().replaceAll('Exception: ', '');
          _showSnackBar(cleanError, isError: true);
        },
      );
    });

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 30.0,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 40,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '📚 Sistema de Colportagem',
                    style: GoogleFonts.inter(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Associação Espírito Santo',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 30),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _buildCurrentForm(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentForm() {
    switch (_currentForm) {
      case AuthFormType.login:
        return _buildLoginForm();
      case AuthFormType.register:
        return _buildRegisterForm();
      case AuthFormType.recover:
        return _buildRecoverForm();
    }
  }

  // WIDGET DO LOGIN ATUALIZADO COM RIVERPOD
  Widget _buildLoginForm() {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Column(
      key: const ValueKey('login'),
      children: [
        _buildTextField(
          label: 'E-mail',
          hint: 'seu@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        _buildTextField(
          label: 'Senha',
          hint: 'Digite sua senha',
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 24),

        isLoading
            ? const CircularProgressIndicator()
            : _buildPrimaryButton('Entrar', const Color(0xFF1E3A8A), () {
                if (_emailController.text.isNotEmpty &&
                    _passwordController.text.isNotEmpty) {
                  ref
                      .read(authControllerProvider.notifier)
                      .login(
                        _emailController.text.trim(),
                        _passwordController.text,
                      );
                } else {
                  _showSnackBar('Preencha e-mail e senha', isError: true);
                }
              }),

        const SizedBox(height: 20),
        Text(
          'Não tem conta?',
          style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 12),
        _buildSecondaryButton(
          'Solicitar Acesso',
          const Color(0xFF6C757D),
          () => _switchForm(AuthFormType.register),
        ),
        const SizedBox(height: 8),
        _buildSecondaryButton(
          '🔑 Esqueci Minha Senha',
          const Color(0xFFF59E0B),
          () => _switchForm(AuthFormType.recover),
        ),
      ],
    );
  }

  // WIDGET DO CADASTRO ATUALIZADO COM RIVERPOD
  Widget _buildRegisterForm() {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Column(
      key: const ValueKey('register'),
      children: [
        _buildTextField(
          label: 'Código de Convite *',
          hint: 'Digite o código',
          controller: _inviteCodeController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Nome Completo *',
          hint: 'Digite seu nome',
          controller: _nameController,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'E-mail *',
          hint: 'seu@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Telefone *',
          hint: '(00) 00000-0000',
          controller: _phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedCategoria,
          decoration: InputDecoration(
            labelText: 'Categoria *',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          items: const [
            DropdownMenuItem(value: 'estudante', child: Text('🎓 Estudante')),
            DropdownMenuItem(value: 'efetivo', child: Text('👥 Efetivo')),
          ],
          onChanged: (val) => setState(() => _selectedCategoria = val!),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Senha *',
          hint: 'Mínimo 6 caracteres',
          controller: _passwordController,
          obscureText: true,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Por que deseja ser colportor? *',
          hint: 'Conte-nos sua motivação...',
          controller: _motivationController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),

        isLoading
            ? const CircularProgressIndicator()
            : _buildPrimaryButton(
                'Solicitar Acesso',
                const Color(0xFF1E3A8A),
                () async {
                  // Executa o registro
                  await ref
                      .read(authControllerProvider.notifier)
                      .register(
                        email: _emailController.text.trim(),
                        password: _passwordController.text,
                        nome: _nameController.text.trim(),
                        telefone: _phoneController.text.trim(),
                        motivo: _motivationController.text.trim(),
                        // Transforma em maiúsculo para garantir a leitura no Firestore
                        inviteCode: _inviteCodeController.text
                            .trim()
                            .toUpperCase(),
                        categoria: _selectedCategoria.trim(),
                      );

                  // Se NÃO deu erro, voltamos pra tela de login pra ele aguardar aprovação
                  if (!ref.read(authControllerProvider).hasError) {
                    _showSnackBar('Cadastro realizado com sucesso!');
                    _switchForm(AuthFormType.login);
                  }
                },
              ),

        const SizedBox(height: 8),
        _buildSecondaryButton(
          'Voltar ao Login',
          const Color(0xFF6C757D),
          () => _switchForm(AuthFormType.login),
        ),
      ],
    );
  }

  // WIDGET DE RECUPERAÇÃO ATUALIZADO
  Widget _buildRecoverForm() {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Column(
      key: const ValueKey('recover'),
      children: [
        _buildTextField(
          label: 'E-mail Cadastrado *',
          hint: 'seu@email.com',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 24),

        isLoading
            ? const CircularProgressIndicator()
            : _buildPrimaryButton(
                '🔑 Enviar Link',
                const Color(0xFF10B981),
                () async {
                  await ref
                      .read(authControllerProvider.notifier)
                      .recoverPassword(_emailController.text.trim());
                  if (!ref.read(authControllerProvider).hasError) {
                    _showSnackBar('Link de recuperação enviado para o e-mail!');
                    _switchForm(AuthFormType.login);
                  }
                },
              ),

        const SizedBox(height: 8),
        _buildSecondaryButton(
          'Voltar ao Login',
          const Color(0xFF6C757D),
          () => _switchForm(AuthFormType.login),
        ),
      ],
    );
  }

  // ==========================================
  // WIDGETS AUXILIARES
  // ==========================================
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: GoogleFonts.inter(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(
    String text,
    Color color,
    VoidCallback onPressed,
  ) {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
