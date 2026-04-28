import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../application/reports/report_provider.dart';

class RankingsPage extends ConsumerStatefulWidget {
  final bool isAdmin;
  final String minhaCategoria;

  const RankingsPage({
    super.key,
    required this.isAdmin,
    required this.minhaCategoria,
  });

  @override
  ConsumerState<RankingsPage> createState() => _RankingsPageState();
}

class _RankingsPageState extends ConsumerState<RankingsPage> {
  String _categoriaSelecionada = 'estudante';

  @override
  void initState() {
    super.initState();
    _categoriaSelecionada = widget.minhaCategoria;
  }

  @override
  Widget build(BuildContext context) {
    // Escuta o provider correto: monthlyRankingProvider
    final rankingAsync = ref.watch(monthlyRankingProvider);
    final usersMapAsync = ref.watch(allUsersProvider);
    final categoriaAtiva = widget.isAdmin
        ? _categoriaSelecionada
        : widget.minhaCategoria;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Text(
            'Ranking do Mês',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: const Color(0xFF1E3A8A),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: const Color(0xFFF59E0B),
            indicatorWeight: 4,
            tabs: const [
              Tab(icon: Icon(LucideIcons.clock), text: 'Horas'),
              Tab(icon: Icon(LucideIcons.bookOpen), text: 'Livros'),
              Tab(icon: Icon(LucideIcons.users), text: 'Abordagens'),
            ],
          ),
        ),
        body: Column(
          children: [
            // SELETOR SÓ PARA ADMIN
            if (widget.isAdmin)
              Container(
                color: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildAdminTabButton('👥 Efetivos', 'efetivo'),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildAdminTabButton('🎓 Estudantes', 'estudante'),
                    ),
                  ],
                ),
              ),

            // LISTA DE RESULTADOS
            Expanded(
              child: rankingAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) =>
                    Center(child: Text('Erro ao carregar dados: $err')),
                data: (rankingList) {
                  return usersMapAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, stack) => const SizedBox.shrink(),
                    data: (usersMap) {
                      // 1. Filtra pela Categoria Ativa (Efetivo ou Estudante)
                      final listaFiltrada = rankingList.where((stats) {
                        final uid = stats['uid'];
                        return usersMap[uid]?['categoria'] == categoriaAtiva;
                      }).toList();

                      if (listaFiltrada.isEmpty) {
                        return Center(
                          child: Text(
                            'Sem relatórios para ${categoriaAtiva} este mês.',
                            style: GoogleFonts.inter(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                        );
                      }

                      // 2. Renderiza as listas.
                      // NOTA: As chaves devem bater com as geradas no monthlyRankingProvider
                      return TabBarView(
                        children: [
                          _buildLeaderboardList(
                            listaFiltrada,
                            usersMap,
                            'horas',
                            'h',
                            false,
                          ),
                          _buildLeaderboardList(
                            listaFiltrada,
                            usersMap,
                            'vendas_qtd',
                            ' un',
                            false,
                          ),
                          _buildLeaderboardList(
                            listaFiltrada,
                            usersMap,
                            'ofertas_abordagens',
                            ' abord.',
                            false,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminTabButton(String title, String value) {
    final isActive = _categoriaSelecionada == value;
    return GestureDetector(
      onTap: () => setState(() => _categoriaSelecionada = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? const Color(0xFF1E3A8A) : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(
    List<Map<String, dynamic>> filteredList,
    Map<String, dynamic> usersMap,
    String sortKey,
    String unit,
    bool isCurrency,
  ) {
    // Clona a lista para não mutar a original
    final sortedList = List<Map<String, dynamic>>.from(filteredList);

    // Ordena de forma segura (usando num para evitar erros de casting)
    sortedList.sort((a, b) {
      final valA = (a[sortKey] ?? 0) as num;
      final valB = (b[sortKey] ?? 0) as num;
      return valB.compareTo(valA);
    });

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedList.length,
      itemBuilder: (context, index) {
        final item = sortedList[index];
        final score = (item[sortKey] ?? 0) as num;

        // Se a pontuação for zero, não mostra no ranking
        if (score <= 0) return const SizedBox.shrink();

        final uid = item['uid'];
        final userData = usersMap[uid];
        final nome = userData?['nome'] ?? 'Colportor';
        final fotoUrl = userData?['fotoUrl'];

        // Medalhas e Ícones
        Widget leadingWidget;
        if (index == 0)
          leadingWidget = const Text('🥇', style: TextStyle(fontSize: 28));
        else if (index == 1)
          leadingWidget = const Text('🥈', style: TextStyle(fontSize: 28));
        else if (index == 2)
          leadingWidget = const Text('🥉', style: TextStyle(fontSize: 28));
        else {
          leadingWidget = CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 14,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          );
        }

        return Card(
          elevation: index < 3 ? 3 : 1,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: leadingWidget,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundImage:
                      (fotoUrl != null && fotoUrl.toString().isNotEmpty)
                      ? NetworkImage(fotoUrl)
                      : null,
                  backgroundColor: const Color(0xFF1E3A8A),
                  child: (fotoUrl == null || fotoUrl.toString().isEmpty)
                      ? Text(
                          nome[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    nome,
                    style: GoogleFonts.inter(
                      fontWeight: index < 3
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            trailing: Text(
              isCurrency
                  ? 'R\$ ${score.toStringAsFixed(2).replaceAll('.', ',')}'
                  : '$score$unit',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E3A8A),
              ),
            ),
          ),
        );
      },
    );
  }
}
