import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo do Versículo
class BibleVerse {
  final String text;
  final String reference;

  BibleVerse({required this.text, required this.reference});

  // Construtor que pega o JSON da API e transforma no nosso Objeto
  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    final bookName = json['book']['name'];
    final chapter = json['chapter'];
    final verseNumber = json['number'];
    final text = json['text'];

    return BibleVerse(text: text, reference: '$bookName $chapter:$verseNumber');
  }
}

// FutureProvider faz a requisição assíncrona
final dailyVerseProvider = FutureProvider<BibleVerse>((ref) async {
  try {
    // Endpoint para buscar um versículo aleatório na versão NVI
    final url = Uri.parse(
      'https://www.abibliadigital.com.br/api/verses/nvi/random',
    );
    final response = await http.get(url).timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return BibleVerse.fromJson(json);
    } else {
      throw Exception('Erro na API');
    }
  } catch (e) {
    // PLANO B: Se não tiver internet ou a API falhar, não quebramos o app.
    // Retornamos um versículo de emergência!
    return BibleVerse(
      text:
          "Não fui eu que ordenei a você? Seja forte e corajoso! Não se apavore nem desanime, pois o Senhor, o seu Deus, estará com você por onde você andar.",
      reference: "Josué 1:9",
    );
  }
});
