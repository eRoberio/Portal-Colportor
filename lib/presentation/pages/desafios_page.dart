import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../application/reports/report_provider.dart';

class DesafiosPage extends ConsumerStatefulWidget {
  final String uid;
  const DesafiosPage({super.key, required this.uid});

  @override
  ConsumerState<DesafiosPage> createState() => _DesafiosPageState();
}

class _DesafiosPageState extends ConsumerState<DesafiosPage> {
  YoutubePlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _initVideo(String url) {
    if (_isVideoInitialized || url.isEmpty) return;
    final videoId = YoutubePlayer.convertUrlToId(url);
    if (videoId != null) {
      _videoController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(autoPlay: false, mute: false),
      );
      _isVideoInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignAsync = ref.watch(campaignSettingsProvider);
    final statsAsync = ref.watch(userTotalStatsProvider(widget.uid));

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          'Desafios Ativos',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: campaignAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            const Center(child: Text('Erro ao carregar campanha.')),
        data: (config) {
          if (config.isEmpty)
            return const Center(
              child: Text("Nenhum desafio ativo no momento."),
            );

          // Chama a inicialização de forma segura
          _initVideo(config['video_url'] ?? '');

          return statsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, _) =>
                const Center(child: Text('Erro ao carregar seu progresso.')),
            data: (stats) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ... (Mantém o teu Container de HEADER DO DESAFIO igual) ...
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFE89A0E,
                      ), // Cor baseada na tua imagem
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (config['nome_desafio'] ?? 'OPERAÇÃO RESGATE')
                              .toString()
                              .toUpperCase(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              LucideIcons.gift,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Prêmio: ${config['premio'] ?? 'Jantar'}',
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 2. VÍDEO PROMOCIONAL (CORRIGIDO PARA REPRODUÇÃO)
                  if (_videoController != null) ...[
                    Row(
                      children: [
                        const Icon(LucideIcons.clapperboard, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Missão da Semana',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.red.shade600,
                          width: 2,
                        ), // Borda vermelha da tua imagem
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: YoutubePlayer(
                          controller: _videoController!,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: Colors.red,
                          progressColors: const ProgressBarColors(
                            playedColor: Colors.red,
                            handleColor: Colors.redAccent,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 2. VÍDEO PROMOCIONAL
                  // if (_videoController != null) ...[
                  //   Text(
                  //     '🎬 Missão da Semana',
                  //     style: GoogleFonts.inter(
                  //       fontSize: 18,
                  //       fontWeight: FontWeight.bold,
                  //     ),
                  //   ),
                  //   const SizedBox(height: 12),
                  //   ClipRRect(
                  //     borderRadius: BorderRadius.circular(12),
                  //     child: YoutubePlayer(controller: _videoController!),
                  //   ),
                  //   const SizedBox(height: 24),
                  // ],
                  Text(
                    '📊 Seu Progresso',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. BARRAS DE PROGRESSO
                  _buildProgressCard(
                    '⏱ Horas Missionárias',
                    stats['horas'],
                    config['horas'],
                    'h',
                    Colors.blue,
                  ),
                  _buildProgressCard(
                    '🙋 Abordagens (Ofertas)',
                    stats['ofertas'],
                    config['ofertas_abordagens'] ?? config['ofertas'],
                    ' pessoas',
                    Colors.orange,
                  ),
                  _buildProgressCard(
                    '📚 Qtd Vendas',
                    stats['vendas'],
                    config['vendas_qtd'],
                    ' un',
                    Colors.green,
                  ),
                  _buildProgressCard(
                    '💰 Valor Arrecadado',
                    stats['valor'],
                    config['valor_total_vendas'] ?? config['valor_vendas'],
                    ' R\$',
                    Colors.purple,
                    isMoney: true,
                  ),

                  // ... (Mantém as BARRAS DE PROGRESSO iguais) ...
                ],
              );
            },
          );
        },
      ),
    );
  }

  // Widget build(BuildContext context) {
  //   final campaignAsync = ref.watch(campaignSettingsProvider);
  //   final statsAsync = ref.watch(userTotalStatsProvider(widget.uid));

  //   return Scaffold(
  //     backgroundColor: const Color(0xFFF5F5F5),
  //     appBar: AppBar(
  //       title: Text(
  //         'Desafios Ativos',
  //         style: GoogleFonts.inter(
  //           fontWeight: FontWeight.bold,
  //           color: Colors.white,
  //         ),
  //       ),
  //       backgroundColor: const Color(0xFF1E3A8A),
  //       iconTheme: const IconThemeData(color: Colors.white),
  //     ),
  //     body: campaignAsync.when(
  //       loading: () => const Center(child: CircularProgressIndicator()),
  //       error: (err, _) =>
  //           const Center(child: Text('Erro ao carregar campanha.')),
  //       data: (config) {
  //         if (config.isEmpty)
  //           return const Center(
  //             child: Text("Nenhum desafio ativo no momento."),
  //           );

  //         _initVideo(config['video_url'] ?? '');

  //         return statsAsync.when(
  //           loading: () => const Center(child: CircularProgressIndicator()),
  //           error: (err, _) =>
  //               const Center(child: Text('Erro ao carregar seu progresso.')),
  //           data: (stats) {
  //             return ListView(
  //               padding: const EdgeInsets.all(20),
  //               children: [
  //                 // 1. HEADER DO DESAFIO (Nome e Prêmio)
  //                 Container(
  //                   padding: const EdgeInsets.all(20),
  //                   decoration: BoxDecoration(
  //                     gradient: const LinearGradient(
  //                       colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  //                     ),
  //                     borderRadius: BorderRadius.circular(16),
  //                     boxShadow: const [
  //                       BoxShadow(color: Colors.black12, blurRadius: 8),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         (config['nome_desafio'] ?? 'Desafio da Semana')
  //                             .toString()
  //                             .toUpperCase(),
  //                         style: GoogleFonts.inter(
  //                           color: Colors.white,
  //                           fontSize: 22,
  //                           fontWeight: FontWeight.w900,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 8),
  //                       Row(
  //                         children: [
  //                           const Icon(
  //                             LucideIcons.gift,
  //                             color: Colors.white,
  //                             size: 24,
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Expanded(
  //                             child: Text(
  //                               'Prêmio: ${config['premio'] ?? 'Surpresa!'}',
  //                               style: GoogleFonts.inter(
  //                                 color: Colors.white,
  //                                 fontSize: 16,
  //                                 fontWeight: FontWeight.w600,
  //                               ),
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 const SizedBox(height: 24),

  //                 // 2. VÍDEO PROMOCIONAL
  //                 if (_videoController != null) ...[
  //                   Text(
  //                     '🎬 Missão da Semana',
  //                     style: GoogleFonts.inter(
  //                       fontSize: 18,
  //                       fontWeight: FontWeight.bold,
  //                     ),
  //                   ),
  //                   const SizedBox(height: 12),
  //                   ClipRRect(
  //                     borderRadius: BorderRadius.circular(12),
  //                     child: YoutubePlayer(controller: _videoController!),
  //                   ),
  //                   const SizedBox(height: 24),
  //                 ],

  //                 Text(
  //                   '📊 Seu Progresso',
  //                   style: GoogleFonts.inter(
  //                     fontSize: 18,
  //                     fontWeight: FontWeight.bold,
  //                   ),
  //                 ),
  //                 const SizedBox(height: 16),

  //                 // 3. BARRAS DE PROGRESSO
  //                 _buildProgressCard(
  //                   '⏱ Horas Missionárias',
  //                   stats['horas'],
  //                   config['horas'],
  //                   'h',
  //                   Colors.blue,
  //                 ),
  //                 _buildProgressCard(
  //                   '🙋 Abordagens (Ofertas)',
  //                   stats['ofertas'],
  //                   config['ofertas_abordagens'] ?? config['ofertas'],
  //                   ' pessoas',
  //                   Colors.orange,
  //                 ),
  //                 _buildProgressCard(
  //                   '📚 Qtd Vendas',
  //                   stats['vendas'],
  //                   config['vendas_qtd'],
  //                   ' un',
  //                   Colors.green,
  //                 ),
  //                 _buildProgressCard(
  //                   '💰 Valor Arrecadado',
  //                   stats['valor'],
  //                   config['valor_total_vendas'] ?? config['valor_vendas'],
  //                   ' R\$',
  //                   Colors.purple,
  //                   isMoney: true,
  //                 ),
  //               ],
  //             );
  //           },
  //         );
  //       },
  //     ),
  //   );
  // }

  Widget _buildProgressCard(
    String title,
    dynamic atualDynamic,
    dynamic metaDynamic,
    String unit,
    Color color, {
    bool isMoney = false,
  }) {
    double atual = (atualDynamic ?? 0).toDouble();
    double meta = (metaDynamic ?? 1).toDouble(); // Evita divisão por zero
    if (meta == 0) meta = 1;

    double progress = (atual / meta).clamp(0.0, 1.0);
    bool isCompleted = progress >= 1.0;

    String formatadoAtual = isMoney
        ? atual.toStringAsFixed(2)
        : atual.toInt().toString();
    String formatadoMeta = isMoney
        ? meta.toStringAsFixed(2)
        : meta.toInt().toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              if (isCompleted)
                Icon(LucideIcons.checkCircle2, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$formatadoAtual / $formatadoMeta$unit',
                style: GoogleFonts.inter(color: Colors.grey[700], fontSize: 13),
              ),
              Text(
                '${(progress * 100).toInt()}%',
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
              value: progress,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

// class DesafiosPage extends ConsumerStatefulWidget {
//   final String uid;
//   const DesafiosPage({super.key, required this.uid});

//   @override
//   ConsumerState<DesafiosPage> createState() => _DesafiosPageState();
// }

// class _DesafiosPageState extends ConsumerState<DesafiosPage> {
//   YoutubePlayerController? _videoController;

// @override
// void dispose() {
//   _videoController?.dispose();
//   super.dispose();
// }

// Inicialização segura do player de vídeo
// void _initVideo(String url) {
//   if (_videoController != null || url.isEmpty) return;

//   final videoId = YoutubePlayer.convertUrlToId(url);
//   if (videoId != null) {
//     // O setState dentro do addPostFrameCallback garante que a interface atualiza após inicializar
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       setState(() {
//         _videoController = YoutubePlayerController(
//           initialVideoId: videoId,
//           flags: const YoutubePlayerFlags(
//             autoPlay: false,
//             mute: false,
//             showLiveFullscreenButton: false,
//           ),
//         );
//       });
//     });
//   }
// }

// @override
// Widget build(BuildContext context) {
//   final campaignAsync = ref.watch(campaignSettingsProvider);
//   final statsAsync = ref.watch(userTotalStatsProvider(widget.uid));

//   return Scaffold(
//     backgroundColor: const Color(0xFFF5F5F5),
//     appBar: AppBar(
//       title: Text(
//         'Desafios Ativos',
//         style: GoogleFonts.inter(
//           fontWeight: FontWeight.bold,
//           color: Colors.white,
//         ),
//       ),
//       backgroundColor: const Color(0xFF1E3A8A),
//       iconTheme: const IconThemeData(color: Colors.white),
//     ),
//     body: campaignAsync.when(
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (err, _) =>
//           const Center(child: Text('Erro ao carregar campanha.')),
//       data: (config) {
//         if (config.isEmpty)
//           return const Center(
//             child: Text("Nenhum desafio ativo no momento."),
//           );

//         // Chama a inicialização de forma segura
//         _initVideo(config['video_url'] ?? '');

//         return statsAsync.when(
//           loading: () => const Center(child: CircularProgressIndicator()),
//           error: (err, _) =>
//               const Center(child: Text('Erro ao carregar seu progresso.')),
//           data: (stats) {
//             return ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 // ... (Mantém o teu Container de HEADER DO DESAFIO igual) ...
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: const Color(
//                       0xFFE89A0E,
//                     ), // Cor baseada na tua imagem
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         (config['nome_desafio'] ?? 'OPERAÇÃO RESGATE')
//                             .toString()
//                             .toUpperCase(),
//                         style: GoogleFonts.inter(
//                           color: Colors.white,
//                           fontSize: 20,
//                           fontWeight: FontWeight.w900,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           const Icon(
//                             LucideIcons.gift,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             'Prêmio: ${config['premio'] ?? 'Jantar'}',
//                             style: GoogleFonts.inter(
//                               color: Colors.white,
//                               fontSize: 16,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 24),

//                 // 2. VÍDEO PROMOCIONAL (CORRIGIDO PARA REPRODUÇÃO)
//                 if (_videoController != null) ...[
//                   Row(
//                     children: [
//                       const Icon(LucideIcons.clapperboard, size: 20),
//                       const SizedBox(width: 8),
//                       Text(
//                         'Missão da Semana',
//                         style: GoogleFonts.inter(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 12),
//                   Container(
//                     decoration: BoxDecoration(
//                       borderRadius: BorderRadius.circular(12),
//                       border: Border.all(
//                         color: Colors.red.shade600,
//                         width: 2,
//                       ), // Borda vermelha da tua imagem
//                       boxShadow: const [
//                         BoxShadow(
//                           color: Colors.black26,
//                           blurRadius: 10,
//                           offset: Offset(0, 5),
//                         ),
//                       ],
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: YoutubePlayer(
//                         controller: _videoController!,
//                         showVideoProgressIndicator: true,
//                         progressIndicatorColor: Colors.red,
//                         progressColors: const ProgressBarColors(
//                           playedColor: Colors.red,
//                           handleColor: Colors.redAccent,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 24),
//                 ],

//                 // ... (Mantém as BARRAS DE PROGRESSO iguais) ...
//               ],
//             );
//           },
//         );
//       },
//     ),
//   );
// }

// }
