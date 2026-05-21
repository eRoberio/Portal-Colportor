import '../../application/constants/error_messages_pt_br.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../application/auth/auth_provider.dart';
import '../../application/reports/report_provider.dart';
import '../../constants/egw_database.dart';
import 'account_settings_page.dart';
import 'admin_page.dart';
import 'novo_relatorio_page.dart';
import 'desafios_page.dart';
import 'rankings_page.dart'; // Importação limpa e corrigida!

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  String _abaAtual = 'estudante';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await ref
          .read(authControllerProvider.notifier)
          .uploadProfilePicture(uid, bytes);
      if (!ref.read(authControllerProvider).hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Foto de perfil atualizada!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erro ao enviar a foto.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F5F5),

      drawer: userProfileAsync.when(
        data: (profile) {
          if (profile != null) return _buildDrawer(context, profile);
          return _buildLoadingDrawer();
        },
        loading: _buildLoadingDrawer,
        error: (err, stack) => _buildLoadingDrawer(),
      ),

      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 120,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 10.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      LucideIcons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '📚 Sistema de Colportagem',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Associação Espírito Santo',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 8),

                        userProfileAsync.when(
                          data: (profile) {
                            if (profile == null) return const SizedBox.shrink();
                            final nome = profile['nome'] ?? 'Usuário';
                            final role = profile['role'] == 'admin'
                                ? 'Admin'
                                : 'Colportor';

                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$nome • $role',
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            );
                          },
                          loading: () => const CircularProgressIndicator(
                            color: Colors.white,
                          ),
                          error: (e, _) => Text(
                            ErrorMessagesPtBr.errorLoading,
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut, color: Colors.white),
                    onPressed: () =>
                        ref.read(authControllerProvider.notifier).signOut(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: userProfileAsync.when(
        data: _buildBodyContent,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
          const Center(child: Text(ErrorMessagesPtBr.errorLoadingMainScreen)),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A8A),
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.fileText),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.gift),
            label: 'Aniversários',
          ),
          BottomNavigationBarItem(
            icon: Icon(LucideIcons.heart),
            label: 'Motivação',
          ),
        ],
      ),
    );
  }

  Future<void> _selecionarDataNascimento(String uid) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A),
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataEscolhida != null) {
      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'data_nascimento': dataEscolhida.toIso8601String(),
        'dia_nascimento': dataEscolhida.day,
        'mes_nascimento': dataEscolhida.month,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🎉 Data salva com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Widget _buildBodyContent(Map<String, dynamic>? profile) {
    switch (_currentIndex) {
      case 0:
        return _buildInicioTab(profile);
      case 1:
        return _buildRelatoriosTab(profile?['id']);
      case 2:
        return _buildAniversariosTab(profile);
      case 3:
        return _buildMotivacaoTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // ABA INÍCIO
  // ==========================================
  Widget _buildInicioTab(Map<String, dynamic>? profile) {
    final isAdmin = profile?['role'] == 'admin';
    final uid = profile?['id'];
    final fotoUrl = profile?['fotoUrl'];
    final needsPhoto = fotoUrl == null || fotoUrl.toString().isEmpty;

    final inspiration = ref.watch(dailyInspirationProvider);
    final totalStatsAsync = uid != null
        ? ref.watch(userTotalStatsProvider(uid))
        : const AsyncValue.loading();
    final usersMapAsync = ref.watch(allUsersProvider);
    final championsAsync = ref.watch(todaysChampionsProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (needsPhoto && uid != null)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                border: Border.all(color: Colors.red.shade200, width: 2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.camera,
                    color: Colors.red.shade700,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete seu cadastro!',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Colors.red.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adicione uma foto de perfil.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _selecionarDataNascimento(uid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(
                      'Adicionar',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '"${inspiration['text']}"',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  '— ${inspiration['reference']}',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Text(
            '🚀 Ações Rápidas',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            icon: '📝',
            title: 'Novo Relatório',
            subtitle: 'Envie seu relatório diário',
            onTap: () {
              if (uid != null)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NovoRelatorioPage(uid: uid),
                  ),
                );
            },
          ),
          _buildActionCard(
            icon: '🏆',
            title: 'Rankings',
            subtitle: 'Veja os campeões do período',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RankingsPage(
                    isAdmin: isAdmin,
                    minhaCategoria: profile?['categoria'] ?? 'estudante',
                  ),
                ),
              );
            },
          ),
          _buildActionCard(
            icon: '🎯',
            title: 'Desafios',
            subtitle: 'Confira os desafios ativos',
            onTap: () {
              if (uid != null)
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DesafiosPage(uid: uid),
                  ),
                );
            },
          ),
          if (isAdmin)
            _buildActionCard(
              icon: '⚙️',
              title: 'Painel Admin',
              subtitle: 'Aprovar colportores e gerar códigos',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminPage()),
              ),
            ),
          const SizedBox(height: 24),

          // ===========================
          // CARROSSEL NEON: DESTAQUE DO DIA
          // ===========================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.trophy, color: Color(0xFFF59E0B)),
                  const SizedBox(width: 8),
                  Text(
                    'Destaque de Hoje',
                    style: GoogleFonts.inter(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RankingsPage(
                        isAdmin: isAdmin,
                        minhaCategoria: profile?['categoria'] ?? 'estudante',
                      ),
                    ),
                  );
                },
                child: Text(
                  'Ver Ranking',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E3A8A),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Builder(
            builder: (context) {
              final minhaCategoria = profile?['categoria'] ?? 'estudante';
              final categoriaParaExibir = isAdmin ? _abaAtual : minhaCategoria;

              return Column(
                children: [
                  if (isAdmin) ...[
                    Row(
                      children: [
                        Expanded(
                          child: _buildTabButton('👥 Efetivos', 'efetivo'),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildTabButton('🎓 Estudantes', 'estudante'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  championsAsync.when(
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (err, stack) =>
                        const Text('Erro ao carregar campeões.'),
                    data: (todaysList) {
                      return usersMapAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (err, stack) => const SizedBox.shrink(),
                        data: (users) {
                          final filteredList = todaysList.where((stats) {
                            final userCategoria =
                                users[stats['uid']]?['categoria'] ??
                                'estudante';
                            return userCategoria == categoriaParaExibir;
                          }).toList();

                          if (filteredList.isEmpty) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                child: Text(
                                  'Ainda não há relatórios hoje.',
                                  style: GoogleFonts.inter(
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            );
                          }

                          Map<String, dynamic>? topHoras,
                              topOfertas,
                              topVendas,
                              topFaturamento;
                          for (var stats in filteredList) {
                            if (topHoras == null ||
                                (stats['horas'] ?? 0.0).toDouble() >
                                    (topHoras['horas'] ?? 0.0).toDouble())
                              topHoras = stats;
                            if (topOfertas == null ||
                                (stats['ofertas'] ?? 0).toInt() >
                                    (topOfertas['ofertas'] ?? 0).toInt())
                              topOfertas = stats;
                            if (topVendas == null ||
                                (stats['vendas'] ?? 0).toInt() >
                                    (topVendas['vendas'] ?? 0).toInt())
                              topVendas = stats;
                            if (topFaturamento == null ||
                                (stats['valor'] ?? 0.0).toDouble() >
                                    (topFaturamento['valor'] ?? 0.0).toDouble())
                              topFaturamento = stats;
                          }

                          List<Map<String, dynamic>> destaques = [];

                          if (topHoras != null &&
                              (topHoras['horas'] ?? 0.0).toDouble() > 0) {
                            destaques.add({
                              'titulo': 'LÍDER EM HORAS',
                              'icone': LucideIcons.clock,
                              'nome':
                                  users[topHoras['uid']]?['nome'] ??
                                  'Colportor',
                              'fotoUrl': users[topHoras['uid']]?['fotoUrl'],
                              'score':
                                  '${(topHoras['horas'] ?? 0.0).toDouble().toStringAsFixed(1)}h',
                            });
                          }
                          if (topOfertas != null &&
                              (topOfertas['ofertas'] ?? 0).toInt() > 0) {
                            destaques.add({
                              'titulo': 'LÍDER EM ABORDAGENS',
                              'icone': LucideIcons.users,
                              'nome':
                                  users[topOfertas['uid']]?['nome'] ??
                                  'Colportor',
                              'fotoUrl': users[topOfertas['uid']]?['fotoUrl'],
                              'score':
                                  '${(topOfertas['ofertas'] ?? 0).toInt()}',
                            });
                          }
                          if (topVendas != null &&
                              (topVendas['vendas'] ?? 0).toInt() > 0) {
                            destaques.add({
                              'titulo': 'LÍDER EM VENDAS',
                              'icone': LucideIcons.bookOpen,
                              'nome':
                                  users[topVendas['uid']]?['nome'] ??
                                  'Colportor',
                              'fotoUrl': users[topVendas['uid']]?['fotoUrl'],
                              'score':
                                  '${(topVendas['vendas'] ?? 0).toInt()} un',
                            });
                          }
                          if (topFaturamento != null &&
                              (topFaturamento['valor'] ?? 0.0).toDouble() > 0) {
                            destaques.add({
                              'titulo': 'MAIOR FATURAMENTO',
                              'icone': LucideIcons.coins,
                              'nome':
                                  users[topFaturamento['uid']]?['nome'] ??
                                  'Colportor',
                              'fotoUrl':
                                  users[topFaturamento['uid']]?['fotoUrl'],
                              'score':
                                  'R\$ ${(topFaturamento['valor'] ?? 0.0).toDouble().toStringAsFixed(2).replaceAll('.', ',')}',
                            });
                          }

                          if (destaques.isEmpty) return const SizedBox.shrink();

                          return DestaqueCarousel(destaques: destaques);
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // ESTATÍSTICAS TOTAIS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '📊 Minhas Estatísticas',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 16),

                totalStatsAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, stack) => Text(
                    ErrorMessagesPtBr.errorLoadingStats,
                    style: GoogleFonts.inter(color: Colors.red),
                  ),
                  data: (stats) {
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                'Horas',
                                (stats['horas'] ?? 0).toStringAsFixed(1),
                              ),
                            ),
                            Expanded(
                              child: _buildStatBox(
                                'Estudos',
                                (stats['interessados'] ?? 0).toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                'Abordagens',
                                (stats['ofertas'] ?? 0).toString(),
                              ),
                            ),
                            Expanded(
                              child: _buildStatBox(
                                'Vendas (Qtd)',
                                (stats['vendas'] ?? 0).toString(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                'Faturamento',
                                "R\$ ${(stats['valor'] ?? 0).toStringAsFixed(2).replaceAll('.', ',')}",
                              ),
                            ),
                            Expanded(
                              child: _buildStatBox(
                                'Batismos',
                                (stats['batismos'] ?? 0).toString(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // WIDGETS AUXILIARES
  Widget _buildActionCard({
    required String icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Text(icon, style: const TextStyle(fontSize: 28)),
        title: Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
      ),
    );
  }

  Widget _buildTabButton(String title, String value) {
    final isActive = _abaAtual == value;
    return GestureDetector(
      onTap: () => setState(() => _abaAtual = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : Colors.grey.shade600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingDrawer() {
    return const Drawer(
      backgroundColor: Colors.white,
      child: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
    );
  }

  Widget _buildDrawer(BuildContext context, Map<String, dynamic> profile) {
    final nome = profile['nome'] ?? 'Usuário';
    final email = profile['email'] ?? '';
    final role = profile['role'] == 'admin' ? 'Administrador' : 'Colportor';
    final fotoUrl = profile['fotoUrl'];
    final inicial = nome.toString().isNotEmpty
        ? nome.toString()[0].toUpperCase()
        : 'U';

    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              nome,
              style: GoogleFonts.inter(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(email, style: GoogleFonts.inter(fontSize: 13)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
              child: fotoUrl == null
                  ? Text(
                      inicial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    )
                  : null,
            ),
          ),
          ListTile(
            leading: const Icon(
              LucideIcons.userCircle,
              color: Color(0xFF333333),
            ),
            title: Text(
              'Minha Conta',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Editar perfil e dados',
              style: GoogleFonts.inter(fontSize: 12),
            ),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountSettingsPage(profile: profile),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            title: Text(
              'Sair do Aplicativo',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.redAccent,
              ),
            ),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Versão 1.0.0\nColportagem $role',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(fontSize: 12, color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ABA RELATÓRIOS E ANIVERSÁRIOS
  // ==========================================
  Widget _buildRelatoriosTab(String? uid) {
    if (uid == null)
      return const Center(child: Text('Usuário não identificado.'));
    final reportsAsync = ref.watch(userReportsProvider(uid));

    return reportsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Erro:\n$err',
            style: GoogleFonts.inter(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      data: (snapshot) {
        if (snapshot.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.fileX2, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Nenhum relatório enviado ainda.',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final reports = snapshot.docs;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reports.length,
          itemBuilder: (context, index) {
            final report = reports[index].data() as Map<String, dynamic>;
            final timestamp = report['data_envio'] as Timestamp?;
            final date = timestamp != null
                ? timestamp.toDate()
                : DateTime.now();
            final dataFormatada =
                '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

            return Card(
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '📅 $dataFormatada',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.green.shade200),
                          ),
                          child: Text(
                            'Enviado',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniStat(
                          '⏰',
                          '${report['horas_missionarias'] ?? 0}h',
                        ),
                        _buildMiniStat('📚', '${report['vendas_qtd'] ?? 0} un'),
                        _buildMiniStat(
                          '💰',
                          'R\$ ${report['valor_vendas'] ?? 0}',
                        ),
                        _buildMiniStat('📖', '${report['interessados'] ?? 0}'),
                      ],
                    ),
                    if (report['observacoes'] != null &&
                        report['observacoes'].toString().isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '📝 Obs: ${report['observacoes']}',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildMiniStat(String icon, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildAniversariosTab(Map<String, dynamic>? profile) {
    final uid = profile?['id'];
    if (uid == null)
      return const Center(child: Text('Usuário não identificado.'));
    final bool precisaPreencherData = profile?['mes_nascimento'] == null;
    final usersMapAsync = ref.watch(allUsersProvider);
    final mesAtual = DateTime.now().month;
    const nomesMeses = [
      '',
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🎂 Aniversariantes',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          Text(
            'Celebre a vida com a equipe em ${nomesMeses[mesAtual]}',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          if (precisaPreencherData)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    LucideIcons.gift,
                    color: Color(0xFFF59E0B),
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Quando é o seu?',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Adicione sua data para a equipe celebrar com você.',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _selecionarDataNascimento(uid),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Definir',
                      style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

          usersMapAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Text(
              ErrorMessagesPtBr.errorLoading,
              style: GoogleFonts.inter(color: Colors.red),
            ),
            data: (usersMap) {
              final aniversariantes = usersMap.values
                  .where((u) => u['mes_nascimento'] == mesAtual)
                  .toList();
              aniversariantes.sort(
                (a, b) => (a['dia_nascimento'] as int).compareTo(
                  b['dia_nascimento'] as int,
                ),
              );

              if (aniversariantes.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0),
                    child: Column(
                      children: [
                        Icon(
                          LucideIcons.calendarX2,
                          size: 60,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          ErrorMessagesPtBr.noBirthdays,
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aniversariantes.length,
                itemBuilder: (context, index) {
                  final user = aniversariantes[index];
                  final dia = user['dia_nascimento'];
                  final nome = user['nome'] ?? 'Sem nome';
                  final fotoUrl = user['fotoUrl'];
                  final isHoje = dia == DateTime.now().day;

                  return Card(
                    color: Colors.white,
                    elevation: isHoje ? 4 : 1,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isHoje
                          ? const BorderSide(color: Color(0xFF10B981), width: 2)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: CircleAvatar(
                        radius: 24,
                        backgroundImage:
                            (fotoUrl != null && fotoUrl.toString().isNotEmpty)
                            ? NetworkImage(fotoUrl)
                            : null,
                        backgroundColor: isHoje
                            ? const Color(0xFF10B981)
                            : const Color(0xFF1E3A8A),
                        child: (fotoUrl == null || fotoUrl.toString().isEmpty)
                            ? Text(
                                nome[0].toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              )
                            : null,
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              nome,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isHoje)
                            const Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text('🎉', style: TextStyle(fontSize: 18)),
                            ),
                        ],
                      ),
                      subtitle: Text(
                        isHoje ? 'É HOJE! Mande os parabéns!' : 'Dia $dia',
                        style: GoogleFonts.inter(
                          color: isHoje
                              ? const Color(0xFF10B981)
                              : Colors.grey[600],
                          fontWeight: isHoje
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          LucideIcons.messageCircle,
                          color: Color(0xFF25D366),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Integração com WhatsApp em breve!',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================
  // ABA MOTIVAÇÃO
  // ==========================================
  Widget _buildMotivacaoTab() {
    final fraseFlash = EgwDatabase.getRandomQuote();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📖 Guia de Bolso',
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          Text(
            'O Colportor Evangelista (E. G. White)',
            style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(LucideIcons.quote, color: Colors.white54, size: 40),
                const SizedBox(height: 16),
                Text(
                  '"$fraseFlash"',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(
                    LucideIcons.refreshCw,
                    color: Colors.white,
                    size: 18,
                  ),
                  label: Text(
                    'Sorteio Aleatório',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(backgroundColor: Colors.white12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Text(
            '🎯 O que você precisa agora?',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          ...EgwDatabase.categorias.keys.map((categoria) {
            IconData icone = LucideIcons.bookOpen;
            Color cor = const Color(0xFF3B82F6);
            if (categoria.contains('Consagração')) {
              icone = LucideIcons.heartHandshake;
              cor = const Color(0xFF10B981);
            } else if (categoria.contains('Abordagem')) {
              icone = LucideIcons.doorOpen;
              cor = const Color(0xFFF59E0B);
            } else if (categoria.contains('Dificuldades')) {
              icone = LucideIcons.shieldAlert;
              cor = const Color(0xFFEF4444);
            }
            return _buildTemaCard(categoria, icone, cor);
          }),
        ],
      ),
    );
  }

  Widget _buildTemaCard(String categoria, IconData icon, Color color) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          categoria,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
        onTap: () => showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (context) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                final frase = EgwDatabase.getRandomQuoteFromCategory(categoria);
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        categoria,
                        style: GoogleFonts.inter(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        '"$frase"',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black87,
                          height: 1.6,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () => setModalState(() {}),
                          icon: const Icon(
                            LucideIcons.refreshCw,
                            color: Colors.white,
                          ),
                          label: Text(
                            'Ler mais sobre isso',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET DO CARROSSEL DE DESTAQUES (NOVO)
// ==========================================
class DestaqueCarousel extends StatefulWidget {
  final List<Map<String, dynamic>> destaques;

  const DestaqueCarousel({super.key, required this.destaques});

  @override
  State<DestaqueCarousel> createState() => _DestaqueCarouselState();
}

class _DestaqueCarouselState extends State<DestaqueCarousel> {
  late PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);

    // Configura o carrossel para rodar a cada 4 segundos
    if (widget.destaques.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
        if (!mounted) return;

        _currentPage++;
        if (_currentPage >= widget.destaques.length) {
          _currentPage = 0;
          _pageController.jumpToPage(0);
        } else {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 800),
            curve: Curves.fastOutSlowIn,
          );
        }
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.destaques.length,
        onPageChanged: (int page) {
          _currentPage = page;
        },
        itemBuilder: (context, index) {
          final item = widget.destaques[index];
          final fotoUrl = item['fotoUrl'];

          return Container(
            margin: const EdgeInsets.only(bottom: 12, left: 4, right: 4),
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE65100), Color(0xFFF57C00)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF57C00).withOpacity(0.5),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icone'], color: Colors.white70, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      item['titulo'],
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        (fotoUrl != null && fotoUrl.toString().isNotEmpty)
                        ? NetworkImage(fotoUrl)
                        : null,
                    child: (fotoUrl == null || fotoUrl.toString().isEmpty)
                        ? const Icon(
                            LucideIcons.bookOpen,
                            size: 40,
                            color: Color(0xFFE65100),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  item['nome'],
                  style: GoogleFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item['score'],
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
