import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter/services.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  // 1. CONTROLADORES ATUALIZADOS (Removido o MoneyMasked das Ofertas)
  final _metaHorasCtrl = TextEditingController();
  final _metaVendasQtdCtrl = TextEditingController(); // Livros + Revistas
  final _metaOfertasCtrl =
      TextEditingController(); // Agora é quantidade de abordagens
  final _metaValorVendasCtrl = TextEditingController(); // Valor em R$

  final _nomeDesafioCtrl = TextEditingController();
  final _premioCtrl = TextEditingController();
  final _videoUrlCtrl = TextEditingController();

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
      setState(() {
        _metaHorasCtrl.text = (data['horas'] ?? '0').toString();
        _metaVendasQtdCtrl.text = (data['vendas_qtd'] ?? '0').toString();
        _metaOfertasCtrl.text = (data['ofertas_abordagens'] ?? '0').toString();
        _metaValorVendasCtrl.text = (data['valor_total_vendas'] ?? '0')
            .toString();

        _nomeDesafioCtrl.text = data['nome_desafio'] ?? '';
        _premioCtrl.text = data['premio'] ?? '';
        _videoUrlCtrl.text = data['video_url'] ?? '';
      });
    }
  }

  Future<void> _salvarMetas() async {
    setState(() => _isLoadingMetas = true);
    try {
      await FirebaseFirestore.instance
          .collection('settings')
          .doc('campaign')
          .set({
            'horas': double.tryParse(_metaHorasCtrl.text) ?? 0,
            'vendas_qtd': int.tryParse(_metaVendasQtdCtrl.text) ?? 0,
            'ofertas_abordagens': int.tryParse(_metaOfertasCtrl.text) ?? 0,
            'valor_total_vendas':
                double.tryParse(
                  _metaValorVendasCtrl.text.replaceAll(',', '.'),
                ) ??
                0.0,
            'nome_desafio': _nomeDesafioCtrl.text.trim(),
            'premio': _premioCtrl.text.trim(),
            'video_url': _videoUrlCtrl.text.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Configurações salvas!'),
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

  // Lógica dos códigos de convite (mantida igual)
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
            // 1. IDENTIDADE DO DESAFIO (Campos novos)
            // ==========================================
            Text(
              '🎯 Identidade do Desafio',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Nome do Desafio (ex: Operação Resgate)',
              _nomeDesafioCtrl,
              isNumeric: false,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Prêmio (ex: Jantar ou Kit)',
              _premioCtrl,
              isNumeric: false,
            ),
            const SizedBox(height: 12),
            _buildTextField(
              'Link do Vídeo (YouTube)',
              _videoUrlCtrl,
              isNumeric: false,
            ),
            const SizedBox(height: 32),

            // ==========================================
            // 2. METAS NUMÉRICAS (Ajustado)
            // ==========================================
            Text(
              '📈 Metas da Campanha',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
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
                        child: _buildTextField(
                          '⏰ Horas Missionárias',
                          _metaHorasCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          '📚 Qtd Vendas',
                          _metaVendasQtdCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          '🙋 Ofertas (Abordagens)',
                          _metaOfertasCtrl,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          '💰 Valor Total (R\$)',
                          _metaValorVendasCtrl,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
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
                              'SALVAR CONFIGURAÇÕES',
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
            // 3. CÓDIGOS DE ACESSO (Igual ao seu)
            // ==========================================
            Text(
              '🔑 Códigos de Acesso',
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
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('invite_codes')
                  .where('used', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());
                final codigos = snapshot.data?.docs ?? [];
                if (codigos.isEmpty)
                  return const Text('Nenhum código disponível.');
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: codigos.length,
                  itemBuilder: (context, index) {
                    final code = codigos[index].id;
                    return Card(
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

  // Widget de texto padronizado atualizado
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = true,
  }) {
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
          keyboardType: isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
              : [],
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
