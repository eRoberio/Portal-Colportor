import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../application/reports/report_provider.dart';

class DesafiosPage extends ConsumerWidget {
  final String uid;

  const DesafiosPage({super.key, required this.uid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Agora assistimos a DOIS provedores: O que o usuário fez e o que o Admin pediu!
    final statsAsync = ref.watch(userTotalStatsProvider(uid));
    final goalsAsync = ref.watch(campaignGoalsProvider);

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
      // Mostra loading se QUALQUER UM dos dois estiver carregando
      body: (statsAsync.isLoading || goalsAsync.isLoading)
          ? const Center(child: CircularProgressIndicator())
          : statsAsync.when(
              error: (err, stack) =>
                  const Center(child: Text('Erro ao carregar dados.')),
              data: (stats) {
                // Pegamos as metas configuradas pelo Admin
                final goals =
                    goalsAsync.value ??
                    {
                      'horas': 100.0,
                      'livros': 50.0,
                      'ofertas': 2000.0,
                      'oracoes': 200.0,
                    };

                final horas = stats['horas'] ?? 0.0;
                final livros = stats['livros'] ?? 0;
                final oracoes = stats['oracoes'] ?? 0;
                final ofertas = stats['ofertas'] ?? 0.0;

                return ListView(
                  padding: const EdgeInsets.all(20.0),
                  children: [
                    Text(
                      'Metas da Campanha',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Acompanhe seu progresso atualizado.',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 24),

                    _buildChallengeCard(
                      title: 'Espírito de Profecia',
                      description:
                          'Distribua ${goals['livros']?.toInt()} livros.',
                      icon: LucideIcons.bookOpen,
                      color: const Color(0xFF3B82F6),
                      currentValue: livros.toDouble(),
                      goalValue: (goals['livros'] ?? 50).toDouble(),
                      unit: 'livros',
                    ),

                    _buildChallengeCard(
                      title: 'Trabalhador Incansável',
                      description:
                          'Alcance ${goals['horas']?.toInt()} horas de campo.',
                      icon: LucideIcons.clock,
                      color: const Color(0xFFF59E0B),
                      currentValue: horas,
                      goalValue: (goals['horas'] ?? 100).toDouble(),
                      unit: 'horas',
                    ),

                    _buildChallengeCard(
                      title: 'Guerreiro de Oração',
                      description:
                          'Ore com ${goals['oracoes']?.toInt()} famílias.',
                      icon: LucideIcons.heartHandshake,
                      color: const Color(0xFF10B981),
                      currentValue: oracoes.toDouble(),
                      goalValue: (goals['oracoes'] ?? 200).toDouble(),
                      unit: 'orações',
                    ),

                    _buildChallengeCard(
                      title: 'Semeador Fiel',
                      description:
                          'Arrecade R\$ ${goals['ofertas']?.toStringAsFixed(0)}.',
                      icon: LucideIcons.coins,
                      color: const Color(0xFF8B5CF6),
                      currentValue: ofertas,
                      goalValue: (goals['ofertas'] ?? 2000).toDouble(),
                      unit: 'reais',
                      isCurrency: true,
                    ),
                  ],
                );
              },
              loading: () {
                return const Center(child: CircularProgressIndicator());
              },
            ),
    );
  }

  // Widget visual do Card de Desafio
  Widget _buildChallengeCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required double currentValue,
    required double goalValue,
    required String unit,
    bool isCurrency = false,
  }) {
    // Calcula a porcentagem (garantindo que não passe de 100% visualmente)
    double progress = (currentValue / goalValue).clamp(0.0, 1.0);
    bool isCompleted = progress >= 1.0;

    String currentDisplay = isCurrency
        ? 'R\$ ${currentValue.toStringAsFixed(2)}'
        : currentValue.toInt().toString();
    String goalDisplay = isCurrency
        ? 'R\$ ${goalValue.toStringAsFixed(0)}'
        : goalValue.toInt().toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isCompleted
            ? Border.all(color: color, width: 2)
            : Border.all(color: Colors.transparent),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                Icon(LucideIcons.checkCircle2, color: color, size: 28),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentDisplay de $goalDisplay $unit',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
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
