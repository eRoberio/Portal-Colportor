import '../../application/constants/error_messages_pt_br.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
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
  DateTime? _birthDate;
  late TextEditingController _nameController;
  late TextEditingController _motivoController;

  // Variáveis para gerir o telefone sem bugar a máscara
  String _telefoneParaSalvar = '';
  String _telefoneInicialLimpo = '';

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile['nome'] ?? '');
    _motivoController = TextEditingController(
      text: widget.profile['motivo_solicitacao'] ?? '',
    );

    // Limpeza do telefone inicial para não bugar o campo (remover o +55 se existir)
    _telefoneParaSalvar = widget.profile['telefone'] ?? '';
    _telefoneInicialLimpo = _telefoneParaSalvar;

    if (_telefoneInicialLimpo.startsWith('+55')) {
      _telefoneInicialLimpo = _telefoneInicialLimpo
          .substring(3)
          .trim(); // Remove o +55
    } else if (_telefoneInicialLimpo.startsWith('55') &&
        _telefoneInicialLimpo.length > 10) {
      _telefoneInicialLimpo = _telefoneInicialLimpo
          .substring(2)
          .trim(); // Remove o 55 sem o +
    }

    // Inicializa data de nascimento se existir
    if (widget.profile['data_nascimento'] != null) {
      try {
        _birthDate = DateTime.parse(widget.profile['data_nascimento']);
      } catch (_) {}
    }
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
            content: Text(ErrorMessagesPtBr.photoUploadSuccess),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _motivoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authControllerProvider).isLoading;
    // Pegamos a foto mais atualizada do provider de perfil
    final currentProfile =
        ref.watch(currentUserProfileProvider).value ?? widget.profile;
    final fotoUrl = currentProfile['fotoUrl'];

    // Atualiza birthDate se mudou no provider
    if (currentProfile['data_nascimento'] != null && _birthDate == null) {
      try {
        _birthDate = DateTime.parse(currentProfile['data_nascimento']);
      } catch (_) {}
    }

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
            IntlPhoneField(
              // Usar initialValue em vez de controller para não criar conflito com o countryCode
              initialValue: _telefoneInicialLimpo,
              initialCountryCode: 'BR',
              invalidNumberMessage:
                  'Número inválido', // Alterado para Português
              decoration: _inputDecoration().copyWith(
                hintText: 'Digite seu telefone',
                counterText: '',
              ),
              disableLengthCheck: false,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              onChanged: (phone) {
                // Guarda o número completo (ex: +5511999999999) na variável, e NUNCA no controller
                _telefoneParaSalvar = phone.completeNumber;
              },
            ),
            const SizedBox(height: 16),

            _buildFieldLabel('Data de Nascimento'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _birthDate != null
                          ? '${_birthDate!.day.toString().padLeft(2, '0')}/${_birthDate!.month.toString().padLeft(2, '0')}/${_birthDate!.year}'
                          : 'Não definida',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _birthDate ?? DateTime(2000, 1, 1),
                              firstDate: DateTime(1940),
                              lastDate: DateTime.now(),
                              builder: (context, child) {
                                return Theme(
                                  data: Theme.of(context).copyWith(
                                    colorScheme: const ColorScheme.light(
                                      primary: Color(0xFF1E3A8A),
                                      onPrimary: Colors.white,
                                      onSurface: Colors.black87,
                                    ),
                                  ),
                                  child: child!,
                                );
                              },
                            );
                            if (picked != null) {
                              setState(() {
                                _birthDate = picked;
                              });
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A8A),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Alterar'),
                  ),
                ],
              ),
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
                        final updateData = {
                          'nome': _nameController.text.trim(),
                          'telefone':
                              _telefoneParaSalvar, // Usa a variável corretamente montada!
                          'motivo_solicitacao': _motivoController.text.trim(),
                        };

                        if (_birthDate != null) {
                          updateData['data_nascimento'] = _birthDate!
                              .toIso8601String();
                          updateData['dia_nascimento'] = _birthDate!.day
                              .toString();
                          updateData['mes_nascimento'] = _birthDate!.month
                              .toString();
                        }

                        await ref
                            .read(authControllerProvider.notifier)
                            .updateProfile(currentProfile['id'], updateData);

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
