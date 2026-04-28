import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> gerarRelatorioAdmin({
    required List<Map<String, dynamic>> relatorios,
    required Map<String, dynamic> usuariosMap,
    required String tituloCustomizado,
    required String periodo,
    required String nomeArquivo, // <-- Novo parâmetro
  }) async {
    final pdf = pw.Document();
    final formatadorMoeda = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
    );
    final dataGeral = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    final titulo =
        tituloCustomizado ?? 'RELATÓRIO ADMINISTRATIVO DE COLPORTAGEM';

    // 1. Processar e Somar os Dados
    double totalHoras = 0, totalValor = 0;
    int totalVendas = 0,
        totalOfertas = 0,
        totalInteressados = 0,
        totalGratis = 0,
        totalBatismos = 0;
    Map<String, Map<String, dynamic>> statsPorUsuario = {};

    for (var r in relatorios) {
      final uid = r['uid'] ?? '';
      if (uid.isEmpty) continue;

      if (!statsPorUsuario.containsKey(uid)) {
        statsPorUsuario[uid] = {
          'horas': 0.0,
          'vendas': 0,
          'ofertas': 0,
          'valor': 0.0,
        };
      }

      double h = (r['horas_missionarias'] ?? 0).toDouble();
      int v = (r['vendas_qtd'] ?? 0).toInt();
      int o = (r['ofertas_abordagens'] ?? 0).toInt();
      double val = (r['valor_vendas'] ?? 0).toDouble();

      statsPorUsuario[uid]!['horas'] += h;
      statsPorUsuario[uid]!['vendas'] += v;
      statsPorUsuario[uid]!['ofertas'] += o;
      statsPorUsuario[uid]!['valor'] += val;

      totalHoras += h;
      totalValor += val;
      totalVendas += v;
      totalOfertas += o;
      totalInteressados += ((r['interessados'] ?? 0) as num).toInt();
      totalGratis += ((r['literatura_gratis'] ?? 0) as num).toInt();
      totalBatismos += ((r['batismos'] ?? 0) as num).toInt();
    }

    // 2. Construir o Layout do PDF
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Cabeçalho
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    titulo,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue900,
                    ),
                  ),
                  if (periodo != null)
                    pw.Text(
                      'Período: $periodo',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey700,
                      ),
                    ),
                  pw.Text(
                    'Gerado em: $dataGeral',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Resumo Geral
            pw.Text(
              'RESUMO GERAL DA EQUIPE',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.Divider(),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                _buildStatBox(
                  'Horas Miss.',
                  '${totalHoras.toStringAsFixed(1)}h',
                ),
                _buildStatBox('Abordagens', '$totalOfertas'),
                _buildStatBox('Vendas', '$totalVendas un'),
                _buildStatBox(
                  'Valor Total',
                  formatadorMoeda.format(totalValor),
                ),
              ],
            ),
            pw.SizedBox(height: 20),

            // Impacto Espiritual
            pw.Text(
              'IMPACTO ESPIRITUAL',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.green700,
              ),
              data: <List<String>>[
                ['Indicador', 'Quantidade Total'],
                [
                  'Interessados em Estudo Bíblico',
                  '$totalInteressados pessoas',
                ],
                ['Literatura Gratuita Distribuída', '$totalGratis unidades'],
                ['Pessoas Levadas ao Batismo', '$totalBatismos pessoas'],
              ],
            ),
            pw.SizedBox(height: 30),

            // Tabela por Colportor
            pw.Text(
              'DETALHAMENTO POR COLPORTOR',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.TableHelper.fromTextArray(
              context: context,
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue900,
              ),
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerRight,
                2: pw.Alignment.centerRight,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
              data: <List<String>>[
                [
                  'Nome do Colportor',
                  'Horas',
                  'Abordagens',
                  'Vendas (Qtd)',
                  'Total (R\$)',
                ],
                ...statsPorUsuario.entries.map((entry) {
                  final uid = entry.key;
                  final s = entry.value;
                  final nome =
                      usuariosMap[uid]?['nome'] ?? 'Colportor Desconhecido';
                  return [
                    nome,
                    '${(s['horas'] as double).toStringAsFixed(1)}h',
                    '${s['ofertas']}',
                    '${s['vendas']}',
                    formatadorMoeda.format(s['valor']),
                  ];
                }),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 10),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          );
        },
      ),
    );

    // No final da função, onde o arquivo é gerado:
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      // Definimos o nome que aparecerá ao baixar/partilhar
      name: '$nomeArquivo.pdf',
    );
  }

  static pw.Widget _buildStatBox(String titulo, String valor) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
        border: pw.Border.all(color: PdfColors.grey300),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            valor,
            style: pw.TextStyle(
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue900,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            titulo,
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
}
