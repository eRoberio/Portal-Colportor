import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

import '../../constants/bible_database.dart';
import '../../constants/egw_database.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
// Provedor das Metas e Vídeo (Admin)
final campaignSettingsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('campaign')
      .snapshots()
      .map((doc) => doc.data() ?? {});
});

// Provedor de Estatísticas Individuais (Ajustado para a nova especificação)
// Provedor para as estatísticas que alimentam os Desafios
final userTotalStatsProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, uid) {
      return FirebaseFirestore.instance
          .collection('reports')
          .where('uid', isEqualTo: uid)
          .snapshots()
          .map((snap) {
            double horas = 0, valor = 0;
            int vendas = 0, ofertas = 0;

            for (var doc in snap.docs) {
              final d = doc.data();
              // Use .toDouble() ou .toInt() para evitar erro de 'num'
              horas += (d['horas_missionarias'] ?? 0).toDouble();
              valor += (d['valor_vendas'] ?? 0).toDouble();
              vendas += ((d['vendas_qtd'] ?? 0) as num).toInt();
              ofertas += ((d['ofertas_abordagens'] ?? 0) as num).toInt();
              // visitas += ((d['visitas'] ?? 0) as num).toInt();
              // interessados += ((d['interessados'] ?? 0) as num).toInt();
              // batismos += ((d['batismos'] ?? 0) as num).toInt();
            }
            return {
              'horas': horas,
              'valor': valor,
              'vendas': vendas,
              'ofertas': ofertas,
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
// 6. Ranking Mensal
final monthlyRankingProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final now = DateTime.now();
  final primeiroDia = DateTime(now.year, now.month, 1);

  return FirebaseFirestore.instance
      .collection('reports')
      .where('data_envio', isGreaterThanOrEqualTo: primeiroDia)
      .snapshots()
      .map((snap) {
        final stats = <String, Map<String, dynamic>>{};

        for (var doc in snap.docs) {
          final d = doc.data();
          final uid = d['uid'];

          if (!stats.containsKey(uid)) {
            stats[uid] = {
              'uid': uid,
              'horas': 0.0,
              'vendas_qtd': 0,
              'ofertas_abordagens': 0,
            };
          }

          // Acumula os valores
          stats[uid]!['horas'] += (d['horas_missionarias'] ?? 0).toDouble();
          stats[uid]!['vendas_qtd'] += (d['vendas_qtd'] ?? 0).toInt();
          stats[uid]!['ofertas_abordagens'] += (d['ofertas_abordagens'] ?? 0)
              .toInt();
        }
        return stats.values.toList();
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
