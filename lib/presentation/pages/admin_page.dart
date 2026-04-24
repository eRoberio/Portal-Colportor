import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';
import 'package:flutter_masked_text2/flutter_masked_text2.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // Controladores para as metas
  final _metaHorasCtrl = TextEditingController();
  final _metaLivrosCtrl = TextEditingController();
  final _metaOfertasCtrl = MoneyMaskedTextController(leftSymbol: 'R\$ ', decimalSeparator: ',', thousandSeparator: '.');
  final _metaOracoesCtrl = TextEditingController();

  bool _isLoadingMetas = false;

  @override
  void initState() {
    super.initState();
    _carregarMetasAtuais();
  }

  Future<void> _carregarMetasAtuais() async {
    final doc = await FirebaseFirestore.instance
        .collection('settings')
        .doc('campaign')
        .get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data()!;
      _metaHorasCtrl.text = data['horas'].toString();
      _metaLivrosCtrl.text = data['livros'].toString();
      _metaOfertasCtrl.text = data['ofertas'].toString();
      _metaOracoesCtrl.text = data['oracoes'].toString();
    }
  }

  Future<void> _salvarMetas() async {
    setState(() => _isLoadingMetas = true);
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('campaign')
          .set({
            'horas':
                double.tryParse(_metaHorasCtrl.text.replaceAll(',', '.')) ??
                100.0,
            'livros': double.tryParse(_metaLivrosCtrl.text) ?? 50.0,
            'ofertas':
                double.tryParse(_metaOfertasCtrl.text.replaceAll(',', '.')) ??
                2000.0,
            'oracoes': double.tryParse(_metaOracoesCtrl.text) ?? 200.0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Metas atualizadas!'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e'), backgroundColor: Colors.red),
        );
    }
    setState(() => _isLoadingMetas = false);
  }

  // Lógica dos códigos de convite (mantida igualzinha)
  String _gerarCodigoAleatorio() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<void> _gerarNovoCodigo(BuildContext context) async {
    final novoCodigo = _gerarCodigoAleatorio();
    try {
      await FirebaseFirestore.instance
          .collection('invite_codes')
          .doc(novoCodigo)
          .set({
            'code': novoCodigo,
            'used': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Código gerado!'),
            backgroundColor: Colors.green,
          ),
        );
    } catch (e) {
      if (context.mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Erro: $e'), backgroundColor: Colors.red),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Painel Admin',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ==========================================
            // 1. CONFIGURAR METAS DA CAMPANHA
            // ==========================================
            Text(
              '🎯 Metas da Campanha',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Estes valores definem as barras de Desafio de todos os colportores.',
              style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('⏰ Horas', _metaHorasCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('📚 Livros', _metaLivrosCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField('💰 Ofertas', _metaOfertasCtrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField('🙏 Orações', _metaOracoesCtrl),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 45,
                    child: _isLoadingMetas
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton.icon(
                            onPressed: _salvarMetas,
                            icon: const Icon(
                              LucideIcons.save,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              'Salvar Metas Globais',
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 24),

            // ==========================================
            // 2. GERAR CÓDIGOS DE ACESSO (O SEU ANTIGO)
            // ==========================================
            Text(
              '🔑 Gerar Códigos de Acesso',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => _gerarNovoCodigo(context),
                icon: const Icon(LucideIcons.plus, color: Colors.white),
                label: Text(
                  'Gerar Novo Código',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF59E0B),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              '📋 Códigos Disponíveis',
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('invite_codes')
                  .where('used', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  return const Text('Nenhum código disponível no momento.');

                final codigos = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap:
                      true, // Necessário dentro do SingleChildScrollView
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: codigos.length,
                  itemBuilder: (context, index) {
                    final code = codigos[index].id;
                    return Card(
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(
                          LucideIcons.key,
                          color: Color(0xFF1E3A8A),
                        ),
                        title: Text(
                          code,
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            letterSpacing: 2,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            LucideIcons.trash2,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => FirebaseFirestore.instance
                              .collection('invite_codes')
                              .doc(code)
                              .delete(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Campo de texto padronizado para as metas
  Widget _buildTextField(String label, TextEditingController controller) {
    List<TextInputFormatter> inputFormatters = [];
    if (controller is MoneyMaskedTextController) {
      // No formatter needed, handled by controller
    } else {
      inputFormatters = [FilteringTextInputFormatter.digitsOnly];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: controller is MoneyMaskedTextController
              ? TextInputType.number
              : TextInputType.number,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF1E3A8A), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
