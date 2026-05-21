import '../../application/constants/error_messages_pt_br.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../application/reports/report_provider.dart';

class NovoRelatorioPage extends ConsumerStatefulWidget {
  final String uid;

  const NovoRelatorioPage({super.key, required this.uid});

  @override
  ConsumerState<NovoRelatorioPage> createState() => _NovoRelatorioPageState();
}

class _NovoRelatorioPageState extends ConsumerState<NovoRelatorioPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _tabMetasIndex = 0; // 0 = Campanha, 1 = Pessoal

  // Controladores do Relatório (Atualizados conforme sua solicitação)
  final _horasCtrl = TextEditingController();
  final _ofertasDadasCtrl = TextEditingController(); // Novo campo único
  final _vendasQtdCtrl = TextEditingController();
  final _valorDinheiroCtrl = TextEditingController();
  final _gratisCtrl = TextEditingController();
  final _interessadosCtrl = TextEditingController();
  final _batismosCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Ouvintes para o gráfico em tempo real
    _horasCtrl.addListener(_atualizarGraficos);
    _ofertasDadasCtrl.addListener(_atualizarGraficos);
    _vendasQtdCtrl.addListener(_atualizarGraficos);
    _valorDinheiroCtrl.addListener(_atualizarGraficos);
  }

  @override
  void dispose() {
    _horasCtrl.dispose();
    _ofertasDadasCtrl.dispose();
    _vendasQtdCtrl.dispose();
    _valorDinheiroCtrl.dispose();
    _gratisCtrl.dispose();
    _interessadosCtrl.dispose();
    _batismosCtrl.dispose();
    super.dispose();
  }

  void _atualizarGraficos() => setState(() {});

  Future<void> _enviarRelatorio() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.uid)
          .get();
      final categoria = userDoc.data()?['categoria'] ?? 'estudante';

      await FirebaseFirestore.instance.collection('reports').add({
        'uid': widget.uid,
        'categoria': categoria,
        'data_envio': FieldValue.serverTimestamp(),
        // Dados do Relatório
        'horas_missionarias':
            double.tryParse(_horasCtrl.text.replaceAll(',', '.')) ?? 0.0,
        'ofertas_dadas': int.tryParse(_ofertasDadasCtrl.text) ?? 0,
        'vendas_qtd': int.tryParse(_vendasQtdCtrl.text) ?? 0,
        'valor_vendas':
            double.tryParse(
              _valorDinheiroCtrl.text
                  .replaceAll(',', '.')
                  .replaceAll(RegExp(r'[^0-9.]'), ''),
            ) ??
            0.0,
        'literatura_gratis': int.tryParse(_gratisCtrl.text) ?? 0,
        'interessados': int.tryParse(_interessadosCtrl.text) ?? 0,
        'batismos': int.tryParse(_batismosCtrl.text) ?? 0,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(ErrorMessagesPtBr.reportSent),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${ErrorMessagesPtBr.unknownError}\n$e'), backgroundColor: Colors.red),
        );
    }
    setState(() => _isLoading = false);
  }

  // MODAL PARA DEFINIR METAS PESSOAIS (Sincronizado com os novos campos)
  void _abrirConfiguracaoMetasPessoais(Map<String, dynamic> metasAtuais) {
    final hCtrl = TextEditingController(
      text: (metasAtuais['meta_horas'] ?? '').toString(),
    );
    final oCtrl = TextEditingController(
      text: (metasAtuais['meta_ofertas'] ?? '').toString(),
    );
    final vCtrl = TextEditingController(
      text: (metasAtuais['meta_vendas'] ?? '').toString(),
    );
    final valCtrl = TextEditingController(
      text: (metasAtuais['meta_valor'] ?? '').toString(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🎯 Minhas Metas Pessoais',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: _buildNumField('⏰ Meta Horas', hCtrl, true)),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumField('🙋 Meta Ofertas', oCtrl, false),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildNumField('📚 Meta Vendas', vCtrl, false)),
                const SizedBox(width: 16),
                Expanded(child: _buildNumField('💰 Meta Valor', valCtrl, true)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(widget.uid)
                      .set({
                        'meta_horas':
                            double.tryParse(hCtrl.text.replaceAll(',', '.')) ??
                            0,
                        'meta_ofertas': int.tryParse(oCtrl.text) ?? 0,
                        'meta_vendas': int.tryParse(vCtrl.text) ?? 0,
                        'meta_valor':
                            double.tryParse(
                              valCtrl.text.replaceAll(',', '.'),
                            ) ??
                            0,
                      }, SetOptions(merge: true));
                },
                icon: const Icon(LucideIcons.save),
                label: const Text('SALVAR MINHAS METAS'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(userTotalStatsProvider(widget.uid));
    final campaignAsync = ref.watch(campaignSettingsProvider);
    final personalGoalsAsync = ref.watch(userPersonalGoalsProvider(widget.uid));

    // Valores para o gráfico em tempo real
    final dHoras = double.tryParse(_horasCtrl.text.replaceAll(',', '.')) ?? 0.0;
    final dOfertas = double.tryParse(_ofertasDadasCtrl.text) ?? 0.0;
    final dVendas = double.tryParse(_vendasQtdCtrl.text) ?? 0.0;
    final dValor =
        double.tryParse(
          _valorDinheiroCtrl.text
              .replaceAll(',', '.')
              .replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;

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
                      '⏱ Horas Trabalhadas',
                      _horasCtrl,
                      true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumField(
                      '🙋 Ofertas Dadas',
                      _ofertasDadasCtrl,
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
                    child: _buildNumField('📖 Lit. Grátis', _gratisCtrl, false),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumField(
                      '📖 Estudos',
                      _interessadosCtrl,
                      false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildNumField('✝️ Batismos', _batismosCtrl, false),

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

              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 24),

              // SEÇÃO DE METAS (Com o seletor Campanha/Pessoal)
              Row(
                children: [
                  const Icon(LucideIcons.trendingUp, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    'Projeção de Metas',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    _buildTabToggle('Metas da Campanha', 0),
                    _buildTabToggle('Metas Pessoais', 1),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              statsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => const Text(ErrorMessagesPtBr.errorLoadingStats),
                data: (stats) {
                  if (_tabMetasIndex == 0) {
                    return campaignAsync.when(
                      loading: () => const SizedBox.shrink(),
                        error: (err, _) =>
                          const Text(ErrorMessagesPtBr.errorLoadingCampaign),
                      data: (config) => Column(
                        children: [
                          _buildProgressCard(
                            '⏱ Horas Trab.',
                            (stats['horas'] ?? 0.0).toDouble(),
                            dHoras,
                            (config['horas'] ?? 1).toDouble(),
                            'h',
                            Colors.blue,
                          ),
                          _buildProgressCard(
                            '🙋 Ofertas Dadas',
                            (stats['ofertas'] ?? 0).toDouble(),
                            dOfertas,
                            (config['ofertas_abordagens'] ?? 1).toDouble(),
                            ' un',
                            Colors.orange,
                          ),
                          _buildProgressCard(
                            '📚 Qtd Vendas',
                            (stats['vendas'] ?? 0).toDouble(),
                            dVendas,
                            (config['vendas_qtd'] ?? 1).toDouble(),
                            ' un',
                            Colors.green,
                          ),
                          _buildProgressCard(
                            '💰 Valor Arrecadado',
                            (stats['valor'] ?? 0.0).toDouble(),
                            dValor,
                            (config['valor_total_vendas'] ?? 1).toDouble(),
                            ' R\$',
                            Colors.purple,
                            isMoney: true,
                          ),
                        ],
                      ),
                    );
                  } else {
                    return personalGoalsAsync.when(
                      loading: () => const SizedBox.shrink(),
                        error: (err, _) =>
                          const Text(ErrorMessagesPtBr.errorLoadingPersonalGoals),
                      data: (goals) {
                        final mH = (goals['meta_horas'] ?? 0.0).toDouble();
                        if (mH == 0)
                          return Center(
                            child: TextButton.icon(
                              onPressed: () =>
                                  _abrirConfiguracaoMetasPessoais(goals),
                              icon: const Icon(LucideIcons.plus),
                              label: const Text('Definir metas pessoais'),
                            ),
                          );
                        return Column(
                          children: [
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    _abrirConfiguracaoMetasPessoais(goals),
                                child: const Text('Editar Metas'),
                              ),
                            ),
                            _buildProgressCard(
                              '⏱ Horas Trab.',
                              (stats['horas'] ?? 0.0).toDouble(),
                              dHoras,
                              mH,
                              'h',
                              Colors.blue,
                            ),
                            _buildProgressCard(
                              '🙋 Ofertas Dadas',
                              (stats['ofertas'] ?? 0).toDouble(),
                              dOfertas,
                              (goals['meta_ofertas'] ?? 1).toDouble(),
                              ' un',
                              Colors.orange,
                            ),
                            _buildProgressCard(
                              '📚 Qtd Vendas',
                              (stats['vendas'] ?? 0).toDouble(),
                              dVendas,
                              (goals['meta_vendas'] ?? 1).toDouble(),
                              ' un',
                              Colors.green,
                            ),
                            _buildProgressCard(
                              '💰 Valor Arrecadado',
                              (stats['valor'] ?? 0.0).toDouble(),
                              dValor,
                              (goals['meta_valor'] ?? 1).toDouble(),
                              ' R\$',
                              Colors.purple,
                              isMoney: true,
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabToggle(String label, int index) {
    bool isSelected = _tabMetasIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabMetasIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
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

  Widget _buildProgressCard(
    String title,
    double hist,
    double digit,
    double meta,
    String unit,
    Color color, {
    bool isMoney = false,
  }) {
    double m = meta <= 0 ? 1 : meta;
    double progNovo = ((hist + digit) / m).clamp(0.0, 1.0);
    double total = hist + digit;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                '${(progNovo * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progNovo,
              minHeight: 8,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${isMoney ? total.toStringAsFixed(2) : total.toInt()} / ${isMoney ? m.toStringAsFixed(2) : m.toInt()}$unit',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
