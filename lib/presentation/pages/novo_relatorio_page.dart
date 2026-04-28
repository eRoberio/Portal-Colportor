import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NovoRelatorioPage extends StatefulWidget {
  final String uid;

  const NovoRelatorioPage({super.key, required this.uid});

  @override
  State<NovoRelatorioPage> createState() => _NovoRelatorioPageState();
}

class _NovoRelatorioPageState extends State<NovoRelatorioPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Controladores
  final _visitasCtrl = TextEditingController();
  final _ofertasAbordagensCtrl = TextEditingController();
  final _vendasQtdCtrl = TextEditingController();
  final _valorDinheiroCtrl = TextEditingController();
  final _horasCtrl = TextEditingController();
  final _gratisCtrl = TextEditingController();
  final _interessadosCtrl = TextEditingController();
  final _batismosCtrl = TextEditingController();

  Future<void> _enviarRelatorio() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Busca a categoria do usuário para o ranking
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      final categoria = userDoc.data()?['categoria'] ?? 'estudante';

      await FirebaseFirestore.instance.collection('reports').add({
        'uid': widget.uid,
        'categoria': categoria,
        'data_envio': FieldValue.serverTimestamp(),
        // Inteiros
        'visitas':
            int.tryParse(_visitasCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0,
        'ofertas_abordagens':
            int.tryParse(
              _ofertasAbordagensCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'vendas_qtd':
            int.tryParse(
              _vendasQtdCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'literatura_gratis':
            int.tryParse(_gratisCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0,
        'interessados':
            int.tryParse(
              _interessadosCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'batismos':
            int.tryParse(
              _batismosCtrl.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        // Decimais
        'valor_vendas':
            double.tryParse(
              _valorDinheiroCtrl.text
                  .replaceAll(',', '.')
                  .replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0.0,
        'horas_missionarias':
            double.tryParse(
              _horasCtrl.text
                  .replaceAll(',', '.')
                  .replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0.0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Relatório enviado!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e'), backgroundColor: Colors.red),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resumo Diário',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: _buildNumField(
                      '🏠 Visitas (Casas)',
                      _visitasCtrl,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumField(
                      '🙋 Abordagens',
                      _ofertasAbordagensCtrl,
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumField(
                      '📚 Vendas (Qtd)',
                      _vendasQtdCtrl,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumField(
                      '💰 Valor (R\$)',
                      _valorDinheiroCtrl,
                      true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumField('⏱ Horas Miss.', _horasCtrl, true),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumField('📖 Lit. Grátis', _gratisCtrl, false),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildNumField(
                      '📖 Estudos',
                      _interessadosCtrl,
                      false,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumField('✝️ Batismos', _batismosCtrl, false),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _enviarRelatorio,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          'ENVIAR RELATÓRIO',
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
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

  Widget _buildNumField(
    String label,
    TextEditingController controller,
    bool isDecimal,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.numberWithOptions(decimal: isDecimal),
          inputFormatters: isDecimal
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
              : [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: '0',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
      ],
    );
  }
}
