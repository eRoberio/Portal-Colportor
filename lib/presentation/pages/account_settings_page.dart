import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart'; // Importante para selecionar a foto
import 'package:lucide_icons/lucide_icons.dart';
import '../../application/auth/auth_provider.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> profile;

  const AccountSettingsPage({super.key, required this.profile});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _motivoController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['nome'] ?? '');
    _phoneController = TextEditingController(
      text: widget.profile['telefone'] ?? '',
    );
    _motivoController = TextEditingController(
      text: widget.profile['motivo_solicitacao'] ?? '',
    );
  }

  // Função para trocar a foto diretamente da tela de configurações
  Future<void> _changePhoto() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final uid = widget.profile['id'];

      await ref
          .read(authControllerProvider.notifier)
          .uploadProfilePicture(uid, bytes);

      if (mounted && !ref.read(authControllerProvider).hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    // Pegamos a foto mais atualizada do provider de perfil, não apenas do widget inicial
    final currentProfile =
        ref.watch(currentUserProfileProvider).value ?? widget.profile;
    final fotoUrl = currentProfile['fotoUrl'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Minha Conta',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ÁREA DA FOTO DE PERFIL
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: const Color(0xFF1E3A8A),
                    backgroundImage: fotoUrl != null
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: fotoUrl == null
                        ? const Icon(
                            LucideIcons.user,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: isLoading ? null : _changePhoto,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF59E0B),
                          shape: BoxShape.circle,
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                LucideIcons.camera,
                                color: Colors.white,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // FORMULÁRIO DE DADOS
            _buildFieldLabel('E-mail (Apenas leitura)'),
            TextFormField(
              initialValue: currentProfile['email'],
              readOnly: true,
              style: const TextStyle(color: Colors.grey),
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('Nome Completo'),
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('Telefone'),
            TextFormField(
              controller: _phoneController,
              decoration: _inputDecoration(),
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('Motivação'),
            TextFormField(
              controller: _motivoController,
              maxLines: 3,
              decoration: _inputDecoration(),
            ),

            const SizedBox(height: 32),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await ref
                            .read(authControllerProvider.notifier)
                            .updateProfile(currentProfile['id'], {
                              'nome': _nameController.text.trim(),
                              'telefone': _phoneController.text.trim(),
                              'motivo_solicitacao': _motivoController.text
                                  .trim(),
                            });
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text('Salvar Alterações'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
    );
  }
}
