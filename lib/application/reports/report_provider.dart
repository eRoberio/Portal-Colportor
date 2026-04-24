import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

import '../../constants/bible_database.dart';
import '../../constants/egw_database.dart';

// 1. Controlador para SALVAR um novo relatório
class ReportController extends StateNotifier<AsyncValue<void>> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ReportController() : super(const AsyncData(null));

  Future<void> submitReport({
    required String uid,
    required double horas,
    required int oracoes,
    required double ofertas,
    required int livros,
    required String observacoes,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _firestore.collection('reports').add({
        'uid': uid,
        'horas': horas,
        'oracoes': oracoes,
        'ofertas': ofertas,
        'livros': livros,
        'observacoes': observacoes,
        'data_envio': FieldValue.serverTimestamp(),
      });
    });
  }
}

// 2. Provedor de estado do Controlador de Salvar
final reportControllerProvider =
    StateNotifierProvider<ReportController, AsyncValue<void>>((ref) {
      return ReportController();
    });

// =========================================================================
// 3. AQUI ESTÁ ELE: Provedor que ESCUTA a lista de relatórios do usuário
// =========================================================================
final userReportsProvider = StreamProvider.family<QuerySnapshot, String>((
  ref,
  String uid,
) {
  return FirebaseFirestore.instance
      .collection('reports')
      .where('uid', isEqualTo: uid)
      .orderBy('data_envio', descending: true)
      .snapshots();
});

// =========================================================================
// 4. Provedor que SOMA todas as estatísticas do usuário
// =========================================================================
final userTotalStatsProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, String uid) {
      return FirebaseFirestore.instance
          .collection('reports')
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((snapshot) {
            double totalHoras = 0.0;
            int totalOracoes = 0;
            double totalOfertas = 0.0;
            int totalLivros = 0;

            for (var doc in snapshot.docs) {
              final data = doc.data();
              totalHoras += (data['horas'] ?? 0.0).toDouble();
              totalOracoes += (data['oracoes'] ?? 0) is int
                  ? (data['oracoes'] ?? 0) as int
                  : ((data['oracoes'] ?? 0) as num).toInt();
              totalOfertas += (data['ofertas'] ?? 0.0).toDouble();
              totalLivros += (data['livros'] ?? 0) is int
                  ? (data['livros'] ?? 0) as int
                  : ((data['livros'] ?? 0) as num).toInt();
            }

            return {
              'horas': totalHoras,
              'oracoes': totalOracoes,
              'ofertas': totalOfertas,
              'livros': totalLivros,
            };
          });
    });

// =========================================================================
// 5. Provedor para buscar todos os usuários (Dicionário de Nomes)
// =========================================================================
final allUsersProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance.collection('users').snapshots().map((snap) {
    final map = <String, dynamic>{};
    for (var doc in snap.docs) {
      map[doc.id] = doc.data();
    }
    return map;
  });
});
// =========================================================================
// 6. Provedor dos Campeões do Dia (Retorna a lista bruta somada de hoje)
// =========================================================================
final todaysChampionsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final now = DateTime.now();
  final startOfToday = DateTime(now.year, now.month, now.day);

  return FirebaseFirestore.instance
      .collection('reports')
      .where('data_envio', isGreaterThanOrEqualTo: startOfToday)
      .snapshots()
      .map((snapshot) {
        final userStats = <String, Map<String, dynamic>>{};

        for (var doc in snapshot.docs) {
          final data = doc.data();
          final uid = data['uid'] as String;

          if (!userStats.containsKey(uid)) {
            userStats[uid] = {
              'uid': uid,
              'horas': 0.0,
              'ofertas': 0.0,
              'livros': 0,
            };
          }

          userStats[uid]!['horas'] += (data['horas'] ?? 0.0).toDouble();
          userStats[uid]!['ofertas'] += (data['ofertas'] ?? 0.0).toDouble();
          userStats[uid]!['livros'] += (data['livros'] ?? 0).toInt();
        }

        return userStats.values.toList();
      });
});
// =========================================================================
// 7. Provedor de Ranking Mensal (Tabela de Classificação Completa)
// =========================================================================
final monthlyRankingProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  // Pega o primeiro dia do mês atual
  final now = DateTime.now();
  final startOfMonth = DateTime(now.year, now.month, 1);

  return FirebaseFirestore.instance
      .collection('reports')
      .where('data_envio', isGreaterThanOrEqualTo: startOfMonth)
      .snapshots()
      .map((snapshot) {
        final userStats = <String, Map<String, dynamic>>{};

        // Agrupa e soma os relatórios de cada usuário no mês
        for (var doc in snapshot.docs) {
          final data = doc.data();
          final uid = data['uid'] as String;

          if (!userStats.containsKey(uid)) {
            userStats[uid] = {
              'uid': uid,
              'horas': 0.0,
              'ofertas': 0.0,
              'livros': 0,
            };
          }

          userStats[uid]!['horas'] += (data['horas'] ?? 0.0).toDouble();
          userStats[uid]!['ofertas'] += (data['ofertas'] ?? 0.0).toDouble();
          userStats[uid]!['livros'] += (data['livros'] ?? 0).toInt();
        }

        // Retorna a lista de usuários com suas pontuações totais
        return userStats.values.toList();
      });
});

// Provedor que escolhe aleatoriamente entre Bíblia e O Colportor Evangelista
final dailyInspirationProvider = StateProvider<Map<String, String>>((ref) {
  final isBible = Random().nextBool(); // Cara ou Coroa!

  if (isBible) {
    return BibleDatabase.getRandomVerse();
  } else {
    // Se caiu Coroa, usamos E.G.W
    return {
      'text': EgwDatabase.getRandomQuote(),
      'reference': 'O Colportor Evangelista',
    };
  }
});

// =========================================================================
// 9. Provedor das Metas da Campanha (Painel Admin)
// =========================================================================
final campaignGoalsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  // Lê as metas de um documento fixo chamado 'campaign' na coleção 'settings'
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('campaign')
      .snapshots()
      .map((doc) {
        if (doc.exists && doc.data() != null) {
          return doc.data()!;
        }
        // Se o Admin ainda não tiver configurado nada, retorna um valor padrão de segurança
        return {
          'horas': 100.0,
          'livros': 50.0,
          'ofertas': 2000.0,
          'oracoes': 200.0,
        };
      });
});
