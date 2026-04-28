import 'dart:math';
import 'package:colportportal/application/services/pdf_service.dart';
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

  DateTime _dataInicio = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _dataFim = DateTime.now();
  String _tipoRelatorio = 'geral'; // geral, categoria, individual
  String _categoriaSelecionada = 'estudante';
  String? _usuarioSelecionado;
  List<Map<String, dynamic>> _listaUsuariosCache = [];

  bool _isGeneratingPdf = false;

  bool _isLoadingMetas = false;

  @override
  void initState() {
    super.initState();
    _carregarMetasAtuais();
  }

  void _abrirAssistenteExportacao() async {
    // Carrega os utilizadores rapidamente para o dropdown (se for escolher individual)
    if (_listaUsuariosCache.isEmpty) {
      final snap = await FirebaseFirestore.instance.collection('users').get();
      _listaUsuariosCache = snap.docs
          .map((d) => {'id': d.id, ...d.data()})
          .toList();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
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
                    '📄 Exportar Relatório',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 1. ESCOLHA DO PERÍODO
                  Text(
                    'Período:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      LucideIcons.calendar,
                      color: Color(0xFF1E3A8A),
                    ),
                    title: Text(
                      '${_dataInicio.day}/${_dataInicio.month}/${_dataInicio.year} até ${_dataFim.day}/${_dataFim.month}/${_dataFim.year}',
                    ),
                    trailing: const Icon(LucideIcons.edit2, size: 18),
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: DateTimeRange(
                          start: _dataInicio,
                          end: _dataFim,
                        ),
                      );
                      if (picked != null) {
                        setModalState(() {
                          _dataInicio = picked.start;
                          _dataFim = picked.end;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // 2. ESCOLHA DO TIPO
                  Text(
                    'Tipo de Relatório:',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _tipoRelatorio,
                    items: const [
                      DropdownMenuItem(
                        value: 'geral',
                        child: Text('Geral (Toda a Equipa)'),
                      ),
                      DropdownMenuItem(
                        value: 'categoria',
                        child: Text('Por Categoria (Efetivos/Estudantes)'),
                      ),
                      DropdownMenuItem(
                        value: 'individual',
                        child: Text('Individual (Por Colportor)'),
                      ),
                    ],
                    onChanged: (val) =>
                        setModalState(() => _tipoRelatorio = val!),
                  ),

                  // 3. FILTROS CONDICIONAIS
                  if (_tipoRelatorio == 'categoria') ...[
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: _categoriaSelecionada,
                      items: const [
                        DropdownMenuItem(
                          value: 'estudante',
                          child: Text('🎓 Estudantes'),
                        ),
                        DropdownMenuItem(
                          value: 'efetivo',
                          child: Text('👥 Efetivos'),
                        ),
                      ],
                      onChanged: (val) =>
                          setModalState(() => _categoriaSelecionada = val!),
                    ),
                  ],

                  if (_tipoRelatorio == 'individual') ...[
                    const SizedBox(height: 10),
                    DropdownButton<String>(
                      isExpanded: true,
                      hint: const Text('Selecione o Colportor'),
                      value: _usuarioSelecionado,
                      items: _listaUsuariosCache
                          .map(
                            (u) => DropdownMenuItem<String>(
                              value: u['id'],
                              child: Text(u['nome'] ?? 'Sem nome'),
                            ),
                          )
                          .toList(),
                      onChanged: (val) =>
                          setModalState(() => _usuarioSelecionado = val),
                    ),
                  ],

                  const SizedBox(height: 30),

                  // BOTÃO GERAR
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(
                        LucideIcons.fileOutput,
                        color: Colors.white,
                      ),
                      label: Text(
                        'GERAR PDF AGORA',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Fecha o modal
                        _gerarEExportarPDF(); // Roda a tua função de PDF atualizada!
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _gerarEExportarPDF() async {
    setState(() => _isGeneratingPdf = true);
    try {
      // 1. Prepara a Query baseada no PERÍODO
      // Adicionamos 1 dia na dataFim para garantir que pega os relatórios enviados até às 23:59 do último dia
      Query query = FirebaseFirestore.instance
          .collection('reports')
          .where('data_envio', isGreaterThanOrEqualTo: _dataInicio)
          .where(
            'data_envio',
            isLessThanOrEqualTo: _dataFim.add(const Duration(days: 1)),
          );

      // 2. Aplica o filtro de TIPO (Categoria ou Individual) no Firebase
      if (_tipoRelatorio == 'categoria') {
        query = query.where('categoria', isEqualTo: _categoriaSelecionada);
      } else if (_tipoRelatorio == 'individual' &&
          _usuarioSelecionado != null) {
        query = query.where('uid', isEqualTo: _usuarioSelecionado);
      }

      final reportsSnap = await query.get();
      final relatorios = reportsSnap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();

      if (relatorios.isEmpty) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nenhum relatório encontrado para este filtro.'),
            ),
          );
        setState(() => _isGeneratingPdf = false);
        return;
      }

      // 3. Monta o Mapa de Utilizadores (para dar os nomes aos IDs)
      final usersSnap = await FirebaseFirestore.instance
          .collection('users')
          .get();
      Map<String, dynamic> usersMap = {
        for (var doc in usersSnap.docs) doc.id: doc.data(),
      };

      // 4. Define o Título dinâmico para o PDF
      String tituloPdf = 'RELATÓRIO ADMINISTRATIVO';
      String nomeArquivo = 'RELATORIO_CONSOLIDADO'; // Nome padrão
      if (_tipoRelatorio == 'categoria') {
        tituloPdf += ' (${_categoriaSelecionada.toUpperCase()})';
        nomeArquivo = 'RELATORIO_${_categoriaSelecionada.toUpperCase()}';
      } else if (_tipoRelatorio == 'individual' &&
          _usuarioSelecionado != null) {
        String nomeColportor =
            usersMap[_usuarioSelecionado]?['nome'] ?? 'COLPORTOR';

        // Coloca em CAIXA ALTA e troca espaços por sublinhados para o nome do arquivo
        nomeArquivo = nomeColportor.toUpperCase().replaceAll(' ', '_');
        tituloPdf += ' - $nomeColportor';
      }

      // 5. Chama o serviço com o novo parâmetro nomeArquivo
      await PdfService.gerarRelatorioAdmin(
        relatorios: relatorios,
        usuariosMap: usersMap,
        tituloCustomizado: tituloPdf,
        periodo:
            '${_dataInicio.day}/${_dataInicio.month}/${_dataInicio.year} a ${_dataFim.day}/${_dataFim.month}/${_dataFim.year}',
        nomeArquivo: nomeArquivo, // <-- Enviando o nome formatado
      );
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
    }
    setState(() => _isGeneratingPdf = false);
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
            // EXPORTAÇÃO DE RELATÓRIOS
            // ==========================================
            Text(
              '📊 Relatórios Administrativos',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: _isGeneratingPdf
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      onPressed: _abrirAssistenteExportacao,
                      icon: const Icon(
                        LucideIcons.fileOutput,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Exportar Consolidação Mensal (PDF)',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                      ),
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize
                              .min, // Garante que a Row não ocupe a linha toda
                          children: [
                            // 1. BOTÃO DE COPIAR
                            IconButton(
                              icon: const Icon(
                                LucideIcons.copy,
                                color: Color(0xFF1E3A8A),
                              ),
                              onPressed: () async {
                                // Texto formatado com o código da lista
                                final textoParaCopiar =
                                    "Olá! Segue o código de convite de uso exclusivo para acesso ao Sistema de Colportagem.🔑 Código: *D7AG9H* Por favor, insira este código na tela de registro do aplicativo.";
                                // Copia para a área de transferência do telemóvel/computador
                                await Clipboard.setData(
                                  ClipboardData(text: textoParaCopiar),
                                );

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Copiado para a área de transferência!',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              },
                            ),

                            // 2. BOTÃO DE EXCLUIR (O que já tinhas)
                            IconButton(
                              icon: const Icon(
                                LucideIcons.trash2,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => FirebaseFirestore.instance
                                  .collection('invite_codes')
                                  .doc(code)
                                  .delete(),
                            ),
                          ],
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
