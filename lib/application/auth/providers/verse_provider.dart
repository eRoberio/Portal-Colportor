import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo simples para o versículo
class BibleVerse {
  final String text;
  final String reference;
  BibleVerse(this.text, this.reference);
}

// Lista curada de versos motivacionais (NVI)
final _motivationalVerses = [
  BibleVerse(
    "Não fui eu que ordenei a você? Seja forte e corajoso! Não se apavore nem desanime, pois o Senhor, o seu Deus, estará com você por onde você andar.",
    "Josué 1:9",
  ),
  BibleVerse("Tudo posso naquele que me fortalece.", "Filipenses 4:13"),
  BibleVerse(
    "Consagre ao Senhor tudo o que você faz, e os seus planos serão bem-sucedidos.",
    "Provérbios 16:3",
  ),
  BibleVerse(
    "Portanto, vão e façam discípulos de todas as nações, batizando-os em nome do Pai e do Filho e do Espírito Santo.",
    "Mateus 28:19",
  ),
  BibleVerse(
    "Como são belos nos montes os pés daqueles que anunciam boas-novas, que proclamam a paz, que trazem boas notícias...",
    "Isaías 52:7",
  ),
  BibleVerse(
    "O Senhor é a minha luz e a minha salvação; de quem terei temor? O Senhor é o meu forte refúgio; de quem terei medo?",
    "Salmos 27:1",
  ),
  BibleVerse(
    "Deem graças ao Senhor, clamem pelo seu nome, divulguem entre as nações o que ele tem feito.",
    "1 Crônicas 16:8",
  ),
  BibleVerse(
    "Esforcem-se, e ele fortalecerá o coração de vocês, todos vocês que esperam no Senhor.",
    "Salmos 31:24",
  ),
  BibleVerse(
    "Pois eu sou o Senhor, o seu Deus, que o segura pela mão direita e diz a você: Não tema; eu o ajudarei.",
    "Isaías 41:13",
  ),
  BibleVerse(
    "O meu Deus suprirá todas as necessidades de vocês, de acordo com as suas gloriosas riquezas em Cristo Jesus.",
    "Filipenses 4:19",
  ),
];

// Provider que sorteia e guarda um versículo por sessão
final dailyVerseProvider = Provider<BibleVerse>((ref) {
  final random = Random();
  final index = random.nextInt(_motivationalVerses.length);
  return _motivationalVerses[index];
});
