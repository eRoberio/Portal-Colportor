import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'dart:math';

import '../../constants/bible_database.dart';
import '../../constants/egw_database.dart';

// =========================================================================
// 1. Provedor que ESCUTA a lista de relatórios do usuário
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
// 2. Provedor de Estatísticas Totais do Usuário (ACUMULATIVO DO MÊS)
// =========================================================================
final userTotalStatsProvider = StreamProvider.family<Map<String, dynamic>, String>((
  ref,
  uid,
) {
  final now = DateTime.now();
  // Garante que só soma os relatórios do mês atual! (Zera automaticamente na virada do mês)
  final primeiroDiaDoMes = DateTime(now.year, now.month, 1);

  return FirebaseFirestore.instance
      .collection('reports')
      .where('uid', isEqualTo: uid)
      .where('data_envio', isGreaterThanOrEqualTo: primeiroDiaDoMes)
      .snapshots()
      .map((snap) {
        double horas = 0, valor = 0;
        int vendas = 0, ofertas = 0, interessados = 0, batismos = 0, gratis = 0;

        for (var doc in snap.docs) {
          final d = doc.data();
          horas += (d['horas_missionarias'] ?? 0).toDouble();
          valor += (d['valor_vendas'] ?? 0).toDouble();
          vendas += ((d['vendas_qtd'] ?? 0) as num).toInt();

          // Suporta o nome novo (ofertas_dadas) e o antigo para não perder histórico
          ofertas +=
              ((d['ofertas_dadas'] ?? d['ofertas_abordagens'] ?? 0) as num)
                  .toInt();

          interessados += ((d['interessados'] ?? 0) as num).toInt();
          batismos += ((d['batismos'] ?? 0) as num).toInt();
          gratis += ((d['literatura_gratis'] ?? 0) as num).toInt();
        }

        return {
          'horas': horas,
          'valor': valor,
          'vendas': vendas,
          'ofertas': ofertas, // Agora acumula perfeitamente!
          'interessados': interessados,
          'batismos': batismos,
          'gratis': gratis,
        };
      });
});

// =========================================================================
// 3. Provedor para buscar todos os usuários (Dicionário de Nomes)
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
// 4. Provedor dos Campeões do Dia (Acumulativo de HOJE)
// =========================================================================
final todaysChampionsProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final now = DateTime.now();
  final inicioHoje = DateTime(now.year, now.month, now.day);

  return FirebaseFirestore.instance
      .collection('reports')
      .where('data_envio', isGreaterThanOrEqualTo: inicioHoje)
      .snapshots()
      .map((snap) {
        final stats = <String, Map<String, dynamic>>{};
        for (var doc in snap.docs) {
          final d = doc.data();
          final uid = d['uid'];
          if (uid == null) continue;

          if (!stats.containsKey(uid)) {
            stats[uid] = {
              'uid': uid,
              'horas': 0.0,
              'vendas': 0,
              'ofertas': 0,
              'valor': 0.0,
            };
          }

          stats[uid]!['horas'] += (d['horas_missionarias'] ?? 0).toDouble();
          stats[uid]!['vendas'] += ((d['vendas_qtd'] ?? 0) as num).toInt();
          stats[uid]!['ofertas'] +=
              ((d['ofertas_dadas'] ?? d['ofertas_abordagens'] ?? 0) as num)
                  .toInt();
          stats[uid]!['valor'] += (d['valor_vendas'] ?? 0)
              .toDouble(); // Necessário para o carrossel Neon
        }
        return stats.values.toList();
      });
});

// =========================================================================
// 5. Provedor de Ranking Mensal (Tabela de Classificação)
// =========================================================================
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
              'ofertas_dadas': 0, // Atualizado para a nova regra
            };
          }

          stats[uid]!['horas'] += (d['horas_missionarias'] ?? 0).toDouble();
          stats[uid]!['vendas_qtd'] += ((d['vendas_qtd'] ?? 0) as num).toInt();
          stats[uid]!['ofertas_dadas'] +=
              ((d['ofertas_dadas'] ?? d['ofertas_abordagens'] ?? 0) as num)
                  .toInt();
        }
        return stats.values.toList();
      });
});

// =========================================================================
// 6. Provedor de Motivação (Bíblia ou EGW)
// =========================================================================
final dailyInspirationProvider = StateProvider<Map<String, String>>((ref) {
  final isBible = Random().nextBool();
  if (isBible) {
    return BibleDatabase.getRandomVerse();
  } else {
    return {
      'text': EgwDatabase.getRandomQuote(),
      'reference': 'O Colportor Evangelista',
    };
  }
});

// =========================================================================
// 7. Provedor das Metas da Campanha (Globais - Configuradas no Admin)
// =========================================================================
final campaignSettingsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return FirebaseFirestore.instance
      .collection('settings')
      .doc('campaign')
      .snapshots()
      .map((doc) => doc.data() ?? {});
});

// =========================================================================
// 8. Provedor das Metas Pessoais do Utilizador
// =========================================================================
final userPersonalGoalsProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, uid) {
      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((doc) => doc.data() ?? {});
    });
