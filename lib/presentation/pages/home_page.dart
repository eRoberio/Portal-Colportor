import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_provider.dart';
import 'account_settings_page.dart'; // Corrigido: importando a tela
import 'admin_page.dart';
import 'package:image_picker/image_picker.dart';
import '../../application/providers/verse_provider.dart';
import 'novo_relatorio_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../application/reports/report_provider.dart';
import 'desafios_page.dart';
import 'rankings_page.dart';
import 'dart:math';
import '../../constants/egw_database.dart';

import 'rankings_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../application/auth/auth_provider.dart';
import '../../application/reports/report_provider.dart';
import '../../constants/egw_database.dart';
import 'novo_relatorio_page.dart';
import 'desafios_page.dart';
import 'admin_page.dart';

// final dashboardTabProvider = StateProvider<String>((ref) => 'estudante');

// 3. Troque StatefulWidget por ConsumerStatefulWidget
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

// 4. Troque State por ConsumerState
class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;
  String _dashboardTab = 'efetivos';
  String _abaAtual =
      'estudante'; // Controla se estamos vendo Efetivos ou Estudantes
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Função que abre a galeria e envia a foto
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
    // 5. Assista ao perfil do usuário atual em tempo real!
    final userProfileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      key: _scaffoldKey, // <-- 1. CHAVE ATRIBUÍDA AQUI
      backgroundColor: const Color(0xFFF5F5F5),

      // 2. DRAWER SEMPRE GARANTIDO (mostra carregando se precisar)
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
                  // 3. BOTÃO SIMPLIFICADO USANDO A CHAVE GLOBAL
                  IconButton(
                    icon: const Icon(
                      LucideIcons.menu,
                      color: Colors.white,
                      size: 28,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      // Abre o menu com segurança usando a chave
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                  const SizedBox(width: 8),
                  const SizedBox(width: 8),
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

                        // 6. RENDERIZAÇÃO DINÂMICA DO NOME E CARGO
                        userProfileAsync.when(
                          data: (profile) {
                            if (profile == null) return const SizedBox.shrink();

                            // Pega o nome do banco de dados (Firestore)
                            final nome = profile['nome'] ?? 'Usuário';
                            // Formata o cargo bonitinho
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
                                  '$nome • $role', // Usa as variáveis reais aqui!
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
                            'Erro ao carregar dados',
                            style: GoogleFonts.inter(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.logOut, color: Colors.white),
                    onPressed: () {
                      // 7. LIGA O BOTÃO DE LOGOUT AO FIREBASE
                      ref.read(authControllerProvider.notifier).signOut();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      // ... O RESTO DO CÓDIGO (BottomNavigationBar, e as outras funções) CONTINUA IGUAL!1
      // CORPO DA TELA
      body: userProfileAsync.when(
        data: _buildBodyContent,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) =>
            const Center(child: Text('Erro ao carregar tela principal')),
      ),

      // BARRA DE NAVEGAÇÃO INFERIOR
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
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

  // ==========================================
  // FUNÇÃO PARA SALVAR A DATA DE NASCIMENTO
  // ==========================================
  Future<void> _selecionarDataNascimento(String uid) async {
    final DateTime? dataEscolhida = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1), // Data inicial padrão
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E3A8A), // Cor do cabeçalho
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );

    if (dataEscolhida != null) {
      // Salva no banco de dados separando o mês para facilitar buscas futuras
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

  // Define qual aba central renderizar baseada no BottomNavigationBar
  Widget _buildBodyContent(Map<String, dynamic>? profile) {
    switch (_currentIndex) {
      case 0:
        return _buildInicioTab(profile);
      case 1:
        return _buildRelatoriosTab(profile?['id']);
      case 2:
        return _buildAniversariosTab(profile);
      case 3:
        return _buildMotivacaoTab(); // <--- MUDOU AQUI!
      default:
        return const SizedBox.shrink();
    }
  }
  // ==========================================
  // ABA INÍCIO (DASHBOARD PRINCIPAL)
  // ==========================================

  Widget _buildInicioTab(Map<String, dynamic>? profile) {
    // Validações
    final isAdmin = profile?['role'] == 'admin';
    final uid = profile?['id'];

    final fotoUrl = profile?['fotoUrl'];
    final needsPhoto = fotoUrl == null || fotoUrl.toString().isEmpty;

    // Observadores Riverpod
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
          // 1. BANNER DE FOTO
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
                    onPressed: () => _selecionarDataNascimento(
                      uid,
                    ), // ou _pickAndUploadImage
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

          // 2. CAIXA DE MOTIVAÇÃO (Bíblia / E.G.W)
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
                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.2),
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
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. AÇÕES RÁPIDAS
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
          // 4. CAMPEÕES DE HOJE (Visão Isolada)
          // ===========================
          // Text(
          //   '🏆 Campeões de Hoje',
          //   style: GoogleFonts.inter(
          //     fontSize: 20,
          //     fontWeight: FontWeight.bold,
          //     color: const Color(0xFF333333),
          //   ),
          // ),
          // const SizedBox(height: 12),

          // LÓGICA DE PERFIL:
          // Se for Admin, ele controla a visão pelos botões (_abaAtual).
          // Se for Colportor comum, a tela trava na categoria dele.
          Builder(
            builder: (context) {
              final minhaCategoria = profile?['categoria'] ?? 'estudante';
              final categoriaParaExibir = isAdmin ? _abaAtual : minhaCategoria;

              return Column(
                children: [
                  // OS BOTÕES SÓ APARECEM SE O USUÁRIO FOR ADMIN (O LÍDER GERAL)
                  // if (isAdmin) ...[
                  //   Row(
                  //     children: [
                  //       Expanded(
                  //         child: _buildTabButton('👥 Efetivos', 'efetivo'),
                  //       ),
                  //       const SizedBox(width: 8),
                  //       Expanded(
                  //         child: _buildTabButton('🎓 Estudantes', 'estudante'),
                  //       ),
                  //     ],
                  //   ),
                  //   const SizedBox(height: 16),
                  // ],
                  // ===========================
                  // 4. CAMPEÕES DE HOJE (Visão Isolada)
                  // ===========================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            LucideIcons.trophy,
                            color: Color(0xFFF59E0B),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Campeões de Hoje',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      // Botão VER MAIS que leva aos Rankings Completos
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RankingsPage(
                                isAdmin: isAdmin,
                                minhaCategoria:
                                    profile?['categoria'] ?? 'estudante',
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'Ver mais',
                          style: GoogleFonts.inter(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // LÓGICA DE PERFIL (Mantém a tua lógica de filtro)
                  Builder(
                    builder: (context) {
                      final minhaCategoria =
                          profile?['categoria'] ?? 'estudante';
                      final categoriaParaExibir = isAdmin
                          ? _abaAtual
                          : minhaCategoria;

                      return Column(
                        children: [
                          if (isAdmin) ...[
                            // Container para simular o contorno vermelho (opcional) que mostraste na imagem
                            // Container(
                            //   padding: const EdgeInsets.all(8),
                            //   decoration: BoxDecoration(
                            //     border: Border.all(
                            //       color: Colors.red.shade600,
                            //       width: 2,
                            //     ), // Remove se não quiseres o quadrado vermelho do print
                            //     borderRadius: BorderRadius.circular(12),
                            //   ),
                            //   child:
                            Row(
                              children: [
                                Expanded(
                                  child: _buildTabButton(
                                    '👥 Efetivos',
                                    'efetivo',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _buildTabButton(
                                    '🎓 Estudantes',
                                    'estudante',
                                  ),
                                ),
                              ],
                            ),
                            // ),
                            const SizedBox(height: 16),
                          ],

                          championsAsync.when(
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, stack) =>
                                const Text('Erro ao carregar.'),
                            data: (todaysList) {
                              return usersMapAsync.when(
                                loading: () => const SizedBox.shrink(),
                                error: (err, stack) => const SizedBox.shrink(),
                                data: (users) {
                                  final filteredList = todaysList.where((
                                    stats,
                                  ) {
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
                                          'Nenhum relatório submetido hoje para ${categoriaParaExibir == 'efetivo' ? 'Efetivos' : 'Estudantes'}.',
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
                                      topLivros;
                                  for (var stats in filteredList) {
                                    if (topHoras == null ||
                                        (stats['horas'] ?? 0) >
                                            topHoras['horas'])
                                      topHoras = stats;
                                    if (topOfertas == null ||
                                        (stats['ofertas'] ?? 0) >
                                            topOfertas['ofertas'])
                                      topOfertas = stats;
                                    if (topLivros == null ||
                                        (stats['vendas'] ?? 0) >
                                            topLivros['vendas'])
                                      topLivros = stats;
                                  }

                                  return Column(
                                    children: [
                                      // Proteção adicionada para extrair o nome de forma segura
                                      if (topHoras != null &&
                                          (topHoras['horas'] ?? 0) > 0)
                                        _buildChampionCard(
                                          title: '⏰ Horas Missionárias',
                                          icon: '📚',
                                          name:
                                              users[topHoras['uid']]?['nome'] ??
                                              'Colportor Anónimo',
                                          score:
                                              '${topHoras['horas'].toStringAsFixed(1)}h',
                                          isGold: true,
                                        ),
                                      if (topOfertas != null &&
                                          (topOfertas['ofertas'] ?? 0) > 0)
                                        _buildChampionCard(
                                          title: '🙋 Abordagens (Ofertas)',
                                          icon: '🙋',
                                          name:
                                              users[topOfertas['uid']]?['nome'] ??
                                              'Colportor Anónimo',
                                          score: '${topOfertas['ofertas']}',
                                          isGold: false,
                                        ),
                                      if (topLivros != null &&
                                          (topLivros['vendas'] ?? 0) > 0)
                                        _buildChampionCard(
                                          title: '💼 Livros/Revistas',
                                          icon: '💼',
                                          name:
                                              users[topLivros['uid']]?['nome'] ??
                                              'Colportor Anónimo',
                                          score: '${topLivros['vendas']} un',
                                          isGold: false,
                                        ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  championsAsync.when(
                    loading: () => const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, stack) => Text(
                      'Erro ao carregar campeões.',
                      style: GoogleFonts.inter(color: Colors.red),
                    ),
                    data: (todaysList) {
                      return usersMapAsync.when(
                        loading: () => const SizedBox.shrink(),
                        error: (err, stack) => const SizedBox.shrink(),
                        data: (users) {
                          // Filtra a lista usando nossa variável inteligente!
                          final filteredList = todaysList.where((stats) {
                            final userId = stats['uid'];
                            final userCategoria =
                                users[userId]?['categoria'] ?? 'estudante';
                            return userCategoria == categoriaParaExibir;
                          }).toList();

                          // Se a lista estiver vazia
                          if (filteredList.isEmpty) {
                            // Deixa o texto bonito (Efetivos ou Estudantes) dependendo do que está na tela
                            final nomeAbaFormatado =
                                categoriaParaExibir == 'efetivo'
                                ? 'Efetivos'
                                : 'Estudantes';

                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    LucideIcons.medal,
                                    size: 40,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nenhum relatório de $nomeAbaFormatado hoje.',
                                    style: GoogleFonts.inter(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    'Seja o primeiro a pontuar!',
                                    style: GoogleFonts.inter(
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1E3A8A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }

                         // Acha os campeões com proteção total contra valores Null
                          Map<String, dynamic>? topHoras, topOfertas, topLivros;
                          
                          for (var stats in filteredList) {
                            final double horas = (stats['horas'] ?? 0.0).toDouble();
                            final int ofertas = (stats['ofertas'] ?? 0).toInt();
                            final int vendas = (stats['vendas'] ?? 0).toInt();

                            if (topHoras == null || horas > (topHoras['horas'] ?? 0.0).toDouble()) topHoras = stats;
                            if (topOfertas == null || ofertas > (topOfertas['ofertas'] ?? 0).toInt()) topOfertas = stats;
                            if (topLivros == null || vendas > (topLivros['vendas'] ?? 0).toInt()) topLivros = stats;
                          }

                          return Column(
                            children: [
                              if (topHoras != null && (topHoras['horas'] ?? 0.0).toDouble() > 0)
                                _buildChampionCard(
                                  title: '⏰ Horas Missionárias', 
                                  icon: '📚', 
                                  name: users[topHoras['uid']]?['nome'] ?? 'Colportor', 
                                  score: '${(topHoras['horas'] ?? 0.0).toDouble().toStringAsFixed(1)}h', 
                                  isGold: true
                                ),
                              if (topOfertas != null && (topOfertas['ofertas'] ?? 0).toInt() > 0)
                                _buildChampionCard(
                                  title: '🙋 Abordagens', 
                                  icon: '🙋', 
                                  name: users[topOfertas['uid']]?['nome'] ?? 'Colportor', 
                                  score: '${(topOfertas['ofertas'] ?? 0).toInt()}', 
                                  isGold: false
                                ),
                              if (topLivros != null && (topLivros['vendas'] ?? 0).toInt() > 0)
                                _buildChampionCard(
                                  title: '💼 Vendas', 
                                  icon: '💼', 
                                  name: users[topLivros['uid']]?['nome'] ?? 'Colportor', 
                                  score: '${(topLivros['vendas'] ?? 0).toInt()} un', 
                                  isGold: false
                                ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // 5. ESTATÍSTICAS TOTAIS
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
                    'Erro ao carregar estatísticas.',
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
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatBox(
                                'Abordagens',
                                (stats['ofertas'] ?? 0).toString(),
                              ),
                            ), // Antigo Ofertas R$
                            Expanded(
                              child: _buildStatBox(
                                'Vendas (Qtd)',
                                (stats['vendas'] ?? 0).toString(),
                              ),
                            ), // Antigo Livros
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
  // ==========================================
  // WIDGETS AUXILIARES DA TELA
  // ==========================================

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
      onTap: () {
        setState(() {
          _abaAtual = value; // Atualiza a tela instantaneamente
        });
      },
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

  Widget _buildChampionCard({
    required String title,
    required String icon,
    required String name,
    required String score,
    required bool isGold,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGold
              ? [
                  const Color(0xFFF59E0B),
                  const Color(0xFFFBBF24),
                ] // Gradiente Dourado
              : [
                  const Color(0xFF1E3A8A),
                  const Color(0xFF3B82F6),
                ], // Gradiente Azul
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
            ),
            alignment: Alignment.center,
            child: Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ), // Aqui futuramente entra a foto do perfil
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score,
            style: GoogleFonts.inter(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
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

  // ==========================================
  // DRAWER DE CARREGAMENTO (Evita que a tela quebre)
  // ==========================================
  Widget _buildLoadingDrawer() {
    return const Drawer(
      backgroundColor: Colors.white,
      child: Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A))),
    );
  }

  // ==========================================
  // DRAWER (MENU LATERAL)
  // ==========================================
  Widget _buildDrawer(BuildContext context, Map<String, dynamic> profile) {
    final nome = profile['nome'] ?? 'Usuário';
    final email = profile['email'] ?? '';
    final role = profile['role'] == 'admin' ? 'Administrador' : 'Colportor';
    final fotoUrl = profile['fotoUrl']; // Pega a foto do banco

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
              // Se tiver foto, mostra a imagem da web. Se não, mostra a letra.
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

          // OPÇÕES DO MENU
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
              Navigator.pop(context); // Fecha o menu primeiro
              // Abre a tela de configurações passando o perfil
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
            onTap: () {
              ref.read(authControllerProvider.notifier).signOut();
            },
          ),

          const Spacer(),

          // RODAPÉ DO MENU
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
  // ABA DE RELATÓRIOS DO USUÁRIO (Blindada com Riverpod)
  // ==========================================
  Widget _buildRelatoriosTab(String? uid) {
    if (uid == null)
      return const Center(child: Text('Usuário não identificado.'));

    // 1. O Riverpod assume o controle! Ele não deixa a lista sumir nos recarregamentos da tela.
    final reportsAsync = ref.watch(userReportsProvider(uid));

    return reportsAsync.when(
      // SE ESTIVER CARREGANDO:
      loading: () => const Center(child: CircularProgressIndicator()),

      // SE DER ERRO (Isso vai mostrar na tela se faltar criar o Index no Firebase!):
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Erro ao carregar relatórios:\n$err',
            style: GoogleFonts.inter(color: Colors.redAccent),
            textAlign: TextAlign.center,
          ),
        ),
      ),

      // SE DER SUCESSO:
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
                const SizedBox(height: 8),
                Text(
                  'Vá no Início e clique em "Novo Relatório".',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: Colors.grey[500],
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

  // Widget auxiliar para desenhar os ícones com os números lado a lado
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

  // ==========================================
  // ABA DE ANIVERSÁRIOS DO MÊS
  // ==========================================
  Widget _buildAniversariosTab(Map<String, dynamic>? profile) {
    final uid = profile?['id'];
    if (uid == null)
      return const Center(child: Text('Usuário não identificado.'));

    // Verifica se o usuário atual já preencheu o próprio aniversário
    final bool precisaPreencherData = profile?['mes_nascimento'] == null;

    final usersMapAsync = ref.watch(allUsersProvider);
    final mesAtual = DateTime.now().month;

    // Nomes dos meses para exibir bonitinho
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

          // 1. BANNER PARA PREENCHER A PRÓPRIA DATA (Some automaticamente após preencher)
          if (precisaPreencherData)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
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

          // 2. LISTA DE ANIVERSARIANTES DO MÊS
          usersMapAsync.when(
            loading: () => const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            ),
            error: (err, stack) => Text(
              'Erro ao carregar dados.',
              style: GoogleFonts.inter(color: Colors.red),
            ),
            data: (usersMap) {
              // Filtra apenas quem faz aniversário neste mês
              final aniversariantes = usersMap.values
                  .where((u) => u['mes_nascimento'] == mesAtual)
                  .toList();

              // Ordena pelo dia do aniversário (do dia 1 ao 31)
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
                          'Nenhum aniversário este mês.',
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
                shrinkWrap:
                    true, // Necessário por estar dentro de um SingleChildScrollView
                physics: const NeverScrollableScrollPhysics(),
                itemCount: aniversariantes.length,
                itemBuilder: (context, index) {
                  final user = aniversariantes[index];
                  final dia = user['dia_nascimento'];
                  final nome = user['nome'] ?? 'Sem nome';
                  final fotoUrl = user['fotoUrl'];
                  final telefone =
                      user['telefone']; // Caso queira usar para um botão de WhatsApp no futuro

                  // Verifica se o aniversário é EXATAMENTE HOJE
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
                        ), // Cor do WhatsApp
                        onPressed: () {
                          // Lógica futura: Abrir url_launcher com "https://wa.me/55${telefone limpo}"
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
  // ABA DE MOTIVAÇÃO E TREINAMENTO
  // ==========================================
  // ==========================================
  // ABA DE MOTIVAÇÃO E TREINAMENTO (Guia de Bolso)
  // ==========================================
  Widget _buildMotivacaoTab() {
    // Agora puxamos direto da nossa classe EgwDatabase!
    // Como a tela reconstrói ao chamar setState, podemos usar uma variável local
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

          // 1. CARD PRINCIPAL (Sorteio Geral)
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.3),
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
                  onPressed: () => setState(
                    () {},
                  ), // Apenas recarrega a tela para sortear nova frase
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

          // 2. TEMAS DO LIVRO (Botões de Emergência)
          Text(
            '🎯 O que você precisa agora?',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 16),

          // Mapeia todas as categorias que existem lá no egw_database.dart
          ...EgwDatabase.categorias.keys.map((categoria) {
            // Define ícones e cores diferentes baseados no nome da categoria
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

  // Widget dos botões de categoria que abrem o pop-up (BottomSheet)
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
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          categoria,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
        onTap: () => _abrirConselhoPorTema(categoria, color),
      ),
    );
  }

  // O Pop-up que sobe da tela com o conselho daquele tema específico
  void _abrirConselhoPorTema(String categoria, Color cor) {
    showModalBottomSheet(
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
                      color: cor,
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
                      onPressed: () {
                        // Ao clicar, o StatefulBuilder do modal recarrega apenas o modal sorteando nova frase
                        setModalState(() {});
                      },
                      icon: const Icon(
                        LucideIcons.refreshCw,
                        color: Colors.white,
                      ),
                      label: Text(
                        'Ler mais sobre isso',
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cor,
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
    );
  }

  // Widget auxiliar para os cards de treinamento
  Widget _buildTrainingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: Colors.white,
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.inter(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
        onTap: () {
          // Lógica futura: Abrir um vídeo do YouTube ou um PDF
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Material sendo preparado pela Liderança!'),
            ),
          );
        },
      ),
    );
  }
}
