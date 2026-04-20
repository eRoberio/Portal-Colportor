import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/auth/auth_provider.dart';
import 'account_settings_page.dart'; // Corrigido: importando a tela
import 'admin_page.dart';
import 'package:image_picker/image_picker.dart';
import '../../application/providers/verse_provider.dart';



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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();


// Função que abre a galeria e envia a foto
  Future<void> _pickAndUploadImage(String uid) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final bytes = await image.readAsBytes();
      await ref.read(authControllerProvider.notifier).uploadProfilePicture(uid, bytes);
      if (!ref.read(authControllerProvider).hasError && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Foto de perfil atualizada!'), backgroundColor: Colors.green),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('❌ Erro ao enviar a foto.'), backgroundColor: Colors.red),
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
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  
                  // 3. BOTÃO SIMPLIFICADO USANDO A CHAVE GLOBAL
                  IconButton(
                    icon: const Icon(LucideIcons.menu, color: Colors.white, size: 28),
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
                          style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Associação Espírito Santo',
                          style: GoogleFonts.inter(fontSize: 13, color: Colors.white.withOpacity(0.9)),
                        ),
                        const SizedBox(height: 8),
                        
                        // 6. RENDERIZAÇÃO DINÂMICA DO NOME E CARGO
                        userProfileAsync.when(
                          data: (profile) {
                            if (profile == null) return const SizedBox.shrink();
                            
                            // Pega o nome do banco de dados (Firestore)
                            final nome = profile['nome'] ?? 'Usuário';
                            // Formata o cargo bonitinho
                            final role = profile['role'] == 'admin' ? 'Admin' : 'Colportor';
                            
                            return Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '$nome • $role', // Usa as variáveis reais aqui!
                                  style: GoogleFonts.inter(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500),
                                ),
                              ),
                            );
                          },
                          loading: () => const CircularProgressIndicator(color: Colors.white),
                          error: (e, _) => Text('Erro ao carregar dados', style: GoogleFonts.inter(color: Colors.white)),
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
        error: (_, __) => const Center(child: Text('Erro ao carregar tela principal')),
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
        selectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.fileText), label: 'Relatórios'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.gift), label: 'Aniversários'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.heart), label: 'Motivação'),
        ],
      ),
    );
  }

  // Define qual aba central renderizar baseada no BottomNavigationBar
 Widget _buildBodyContent(Map<String, dynamic>? profile) {
    switch (_currentIndex) {
      case 0:
        return _buildInicioTab(profile);
      case 1:
        return Center(child: Text('Meus Relatórios (Em breve)', style: GoogleFonts.inter()));
      case 2:
        return Center(child: Text('Aniversariantes (Em breve)', style: GoogleFonts.inter()));
      case 3:
        return Center(child: Text('Dicas e Motivação (Em breve)', style: GoogleFonts.inter()));
      default:
        return const SizedBox.shrink();
    }
  }

  // ==========================================
  // ABA INÍCIO (DASHBOARD PRINCIPAL)
  // ==========================================
  
 Widget _buildInicioTab(Map<String, dynamic>? profile) {
    // Validações de usuário
    final isAdmin = profile?['role'] == 'admin';
    final uid = profile?['id'];
    
    // Pega o provider ASSÍNCRONO (API)
    final currentVerseAsync = ref.watch(dailyVerseProvider);
    
    // Verifica se precisa de foto
    final fotoUrl = profile?['fotoUrl'];
    final needsPhoto = fotoUrl == null || fotoUrl.toString().isEmpty;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          // ===========================
          // 1. BANNER DE FOTO (Aparece se não tiver foto)
          // ===========================
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
                  Icon(LucideIcons.camera, color: Colors.red.shade700, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Complete seu cadastro!', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.red.shade800)),
                        const SizedBox(height: 4),
                        Text('Adicione uma foto de perfil para continuar.', style: GoogleFonts.inter(fontSize: 12, color: Colors.red.shade900)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  ref.watch(authControllerProvider).isLoading
                    ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () => _pickAndUploadImage(uid),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade600,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text('Adicionar', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
                      ),
                ],
              ),
            ),

          // ===========================
          // 2. CAIXA DE MOTIVAÇÃO (DINÂMICA COM API)
          // ===========================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: const Color(0xFF1E3A8A).withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 4))],
            ),
            child: currentVerseAsync.when(
              data: (verse) => Column(
                children: [
                  Text(
                    '"${verse.text}"',
                    style: GoogleFonts.inter(fontSize: 15, fontStyle: FontStyle.italic, color: Colors.white, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '— ${verse.reference}',
                    style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
              error: (err, stack) => Text(
                'Erro ao buscar versículo.', 
                style: GoogleFonts.inter(color: Colors.white), textAlign: TextAlign.center
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ===========================
          // 3. AÇÕES RÁPIDAS (Sem duplicação)
          // ===========================
          Text('🚀 Ações Rápidas', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
          const SizedBox(height: 12),

          _buildActionCard(icon: '📝', title: 'Novo Relatório', subtitle: 'Envie seu relatório diário', onTap: () {}),
          _buildActionCard(icon: '🏆', title: 'Rankings', subtitle: 'Veja os campeões do período', onTap: () {}),
          _buildActionCard(icon: '🎯', title: 'Desafios', subtitle: 'Confira os desafios ativos', onTap: () {}),
          
          // O Botão de Admin só desenha se o usuário for admin de verdade
          if (isAdmin)
            _buildActionCard(
              icon: '⚙️', 
              title: 'Painel Admin', 
              subtitle: 'Aprovar colportores e gerar códigos', 
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPage()));
              },
            ),
            
          const SizedBox(height: 24),

          // ===========================
          // 4. CAMPEÕES E ESTATÍSTICAS
          // ===========================
          Text('🏆 Campeões de Hoje', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _buildTabButton('👥 Efetivos', 'efetivos')),
              const SizedBox(width: 8),
              Expanded(child: _buildTabButton('🎓 Estudantes', 'estudantes')),
            ],
          ),
          const SizedBox(height: 16),

          _buildChampionCard(title: '⏰ Horas Missionárias', icon: '📚', name: 'Lucas Neves', score: '8.5h', isGold: true),
          _buildChampionCard(title: '💰 Ofertas', icon: '💰', name: 'Roberio Almeida', score: '150,00', isGold: false),
          _buildChampionCard(title: '💼 Vendas', icon: '💼', name: 'Kaline Ribeiro', score: '1.250,00', isGold: false),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📊 Estatísticas Totais', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: const Color(0xFF333333))),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatBox('Horas', '45.5')),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBox('Orações', '120')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(child: _buildStatBox('Ofertas', "450")),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatBox('Livros', '32')),
                  ],
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

  Widget _buildActionCard({required String icon, required String title, required String subtitle, required VoidCallback onTap}) {
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
        title: Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF333333))),
        subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: Colors.grey[600])),
        trailing: const Icon(LucideIcons.chevronRight, color: Colors.grey),
      ),
    );
  }

  Widget _buildTabButton(String label, String value) {
    bool isActive = _dashboardTab == value;
    return InkWell(
      onTap: () {
        setState(() {
          _dashboardTab = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.white,
          border: Border.all(color: isActive ? const Color(0xFF1E3A8A) : const Color(0xFFE0E0E0), width: 2),
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey[800],
          ),
        ),
      ),
    );
  }

  Widget _buildChampionCard({required String title, required String icon, required String name, required String score, required bool isGold}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGold 
            ? [const Color(0xFFF59E0B), const Color(0xFFFBBF24)] // Gradiente Dourado
            : [const Color(0xFF1E3A8A), const Color(0xFF3B82F6)], // Gradiente Azul
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 12),
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)]),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 32)), // Aqui futuramente entra a foto do perfil
          ),
          const SizedBox(height: 12),
          Text(name, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
          const SizedBox(height: 4),
          Text(score, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatBox(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: const Color(0xFFF8F9FA), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.grey[600])),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1E3A8A))),
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
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      ),
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
    
    final inicial = nome.toString().isNotEmpty ? nome.toString()[0].toUpperCase() : 'U';

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
            accountName: Text(nome, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
            accountEmail: Text(email, style: GoogleFonts.inter(fontSize: 13)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              // Se tiver foto, mostra a imagem da web. Se não, mostra a letra.
              backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl) : null,
              child: fotoUrl == null 
                  ? Text(inicial, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A)))
                  : null,
            ),
          ),
          
          // OPÇÕES DO MENU
          ListTile(
            leading: const Icon(LucideIcons.userCircle, color: Color(0xFF333333)),
            title: Text('Minha Conta', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            subtitle: Text('Editar perfil e dados', style: GoogleFonts.inter(fontSize: 12)),
            onTap: () {
              Navigator.pop(context); // Fecha o menu primeiro
              // Abre a tela de configurações passando o perfil
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (_) => AccountSettingsPage(profile: profile)),
              );
            },
          ),
          
          const Divider(),
          
          ListTile(
            leading: const Icon(LucideIcons.logOut, color: Colors.redAccent),
            title: Text('Sair do Aplicativo', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.redAccent)),
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
          )
        ],
      ),
    );
  }
}