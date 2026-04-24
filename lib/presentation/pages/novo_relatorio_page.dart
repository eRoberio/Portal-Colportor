import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';
import '../../application/reports/report_provider.dart';

class NovoRelatorioPage extends ConsumerStatefulWidget {
  final String uid; // Precisamos saber de quem é o relatório

  const NovoRelatorioPage({super.key, required this.uid});

  @override
  ConsumerState<NovoRelatorioPage> createState() => _NovoRelatorioPageState();
}

class _NovoRelatorioPageState extends ConsumerState<NovoRelatorioPage> {
  final _formKey = GlobalKey<FormState>();
  final _horasController = TextEditingController();
  final _oracoesController = TextEditingController();
  final _ofertasController = MoneyMaskedTextController(
    leftSymbol: 'R\$ ',
    decimalSeparator: ',',
    thousandSeparator: '.',
  );
  final _livrosController = TextEditingController();
  final _obsController = TextEditingController();

  @override
  void dispose() {
    _horasController.dispose();
    _oracoesController.dispose();
    _ofertasController.dispose();
    _livrosController.dispose();
    _obsController.dispose();
    super.dispose();
  }

  Future<void> _enviarRelatorio() async {
    if (_formKey.currentState!.validate()) {
      final horas =
          double.tryParse(_horasController.text.replaceAll(',', '.')) ?? 0.0;
      final oracoes = int.tryParse(_oracoesController.text) ?? 0;
      // Remove R$ and formatting for parsing
      final ofertas =
          double.tryParse(
            _ofertasController.text
                .replaceAll('R\$', '')
                .replaceAll('.', '')
                .replaceAll(',', '.')
                .trim(),
          ) ??
          0.0;
      final livros = int.tryParse(_livrosController.text) ?? 0;

      await ref
          .read(reportControllerProvider.notifier)
          .submitReport(
            uid: widget.uid,
            horas: horas,
            oracoes: oracoes,
            ofertas: ofertas,
            livros: livros,
            observacoes: _obsController.text.trim(),
          );

      final state = ref.read(reportControllerProvider);
      if (mounted && !state.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Relatório enviado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context); // Volta para a Home
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reportControllerProvider);
    final isLoading = state.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Novo Relatório',
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo do Dia',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preencha os dados do seu trabalho de hoje com fidelidade.',
                style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
              ),
              const SizedBox(height: 24),

              // Grid para colocar os campos lado a lado e economizar espaço
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      '⏰ Horas (ex: 4.5)',
                      _horasController,
                      isDecimal: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField('🙏 Orações', _oracoesController),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      '💰 Ofertas (R\$)',
                      _ofertasController,
                      isDecimal: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField('📚 Livros', _livrosController),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                'Observações (Opcional)',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _obsController,
                maxLines: 3,
                decoration: _inputDecoration(
                  hint: 'Alguma experiência marcante hoje?',
                ),
              ),
              const SizedBox(height: 32),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton.icon(
                        onPressed: _enviarRelatorio,
                        icon: const Icon(LucideIcons.send, color: Colors.white),
                        label: Text(
                          'Enviar Relatório',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981), // Verde
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberField(
    String label,
    TextEditingController controller, {
    bool isDecimal = false,
  }) {
    List<TextInputFormatter> inputFormatters = [];
    if (controller is MoneyMaskedTextController) {
      // No formatter needed, handled by controller
    } else if (isDecimal) {
      inputFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))];
    } else {
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    }
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
          keyboardType: controller is MoneyMaskedTextController
              ? TextInputType.number
              : TextInputType.numberWithOptions(decimal: isDecimal),
          inputFormatters: inputFormatters,
          validator: (value) {
            if (value == null || value.isEmpty) return 'Obrigatório';
            return null;
          },
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E0E0), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }
}
