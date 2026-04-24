import 'dart:math';

class BibleDatabase {
  static const Map<String, List<String>> categorias = {
    'Fé e Esperança': [
      "A fé é a certeza daquilo que esperamos e a prova das coisas que não vemos. (Hebreus 11:1)",
      "Tudo é possível àquele que crê. (Marcos 9:23)",
      "Andamos por fé, e não por vista. (2 Coríntios 5:7)",
      "Aqueles que esperam no Senhor renovam as suas forças. Voam alto como águias. (Isaías 40:31)",
      "O choro pode durar uma noite, mas a alegria vem pela manhã. (Salmos 30:5)",
      "A esperança não decepciona, porque o amor de Deus foi derramado em nossos corações. (Romanos 5:5)",
      "Ora, sem fé é impossível agradar a Deus. (Hebreus 11:6)",
      "Por que você está assim tão triste, ó minha alma? Ponha a sua esperança em Deus! (Salmos 42:5)",
      "Guardemos firme a confissão da esperança, sem vacilar, pois quem fez a promessa é fiel. (Hebreus 10:23)",
      "O Senhor é bom para com aqueles cuja esperança está nele, para com aqueles que o buscam. (Lamentações 3:25)",
    ],

    'Força e Coragem': [
      "Seja forte e corajoso; não se apavore nem desanime, pois o Senhor, o seu Deus, estará com você. (Josué 1:9)",
      "No mundo tereis aflições; mas tende bom ânimo, eu venci o mundo. (João 16:33)",
      "O Senhor é a minha luz e a minha salvação; de quem terei temor? (Salmos 27:1)",
      "Deus é o nosso refúgio e a nossa fortaleza, auxílio sempre presente na adversidade. (Salmos 46:1)",
      "O Senhor é a minha força e o meu escudo; nele o meu coração confia. (Salmos 28:7)",
      "Posso todas as coisas naquele que me fortalece. (Filipenses 4:13)",
      "Não fui eu que lhe ordenei? Seja forte e corajoso! (Josué 1:9)",
      "Mas o Senhor esteve ao meu lado e me deu forças. (2 Timóteo 4:17)",
      "Sejam fortes e corajosos, todos vocês que esperam no Senhor! (Salmos 31:24)",
      "Ele fortalece o cansado e dá grande vigor ao que está sem forças. (Isaías 40:29)",
    ],

    'Sabedoria e Direção': [
      "O temor do Senhor é o princípio da sabedoria, e o conhecimento do Santo é entendimento. (Provérbios 9:10)",
      "Lâmpada para os meus pés é tua palavra, e luz para o meu caminho. (Salmos 119:105)",
      "Confie no Senhor de todo o seu coração e não se apoie em seu próprio entendimento. (Provérbios 3:5)",
      "Se algum de vocês tem falta de sabedoria, peça-a a Deus, que a todos dá livremente. (Tiago 1:5)",
      "Consagre ao Senhor tudo o que você faz, e os seus planos serão bem-sucedidos. (Provérbios 16:3)",
      "Reconheça o Senhor em todos os seus caminhos, e ele endireitará as suas veredas. (Provérbios 3:6)",
      "Ensina-nos a contar os nossos dias para que o nosso coração alcance sabedoria. (Salmos 90:12)",
      "O caminho do insensato parece-lhe justo, mas o sábio ouve os conselhos. (Provérbios 12:15)",
      "Instrua a criança segundo os objetivos que você tem para ela, e mesmo com o passar dos anos não se desviará deles. (Provérbios 22:6)",
      "A sabedoria oferece vida aos que a possuem. (Eclesiastes 7:12)",
    ],

    'Paz e Descanso': [
      "Venham a mim, todos os que estão cansados e sobrecarregados, e eu lhes darei descanso. (Mateus 11:28)",
      "Deixo-lhes a paz; a minha paz lhes dou. Não a dou como o mundo a dá. (João 14:27)",
      "A paz de Deus, que excede todo o entendimento, guardará os seus corações e as suas mentes em Cristo Jesus. (Filipenses 4:7)",
      "Em paz me deito e logo adormeço, pois só tu, Senhor, me fazes viver em segurança. (Salmos 4:8)",
      "O Senhor é o meu pastor; de nada terei falta. Em verdes pastagens me faz repousar. (Salmos 23:1-2)",
      "Entregue as suas preocupações ao Senhor, e ele o susterá; jamais permitirá que o justo venha a cair. (Salmos 55:22)",
      "O Senhor dá força ao seu povo; o Senhor dá a seu povo a bênção da paz. (Salmos 29:11)",
      "Tu, Senhor, guardarás em perfeita paz aquele cujo propósito é firme, porque em ti confia. (Isaías 26:3)",
      "E a paz de Deus, para a qual também fostes chamados em um corpo, domine em vossos corações. (Colossenses 3:15)",
      "Ele me conduz a águas tranquilas e restaura o meu vigor. (Salmos 23:2-3)",
    ],

    'Amor e Perdão': [
      "Acima de tudo, porém, revistam-se do amor, que é o elo perfeito. (Colossenses 3:14)",
      "Nós amamos porque ele nos amou primeiro. (1 João 4:19)",
      "Suportem-se uns aos outros e perdoem as queixas que tiverem uns contra os outros. Perdoem como o Senhor lhes perdoou. (Colossenses 3:13)",
      "O ódio provoca dissensão, mas o amor cobre todos os pecados. (Provérbios 10:12)",
      "Sejam bondosos e compassivos uns para com os outros, perdoando-se mutuamente, assim como Deus os perdoou em Cristo. (Efésios 4:32)",
      "Quem não ama não conhece a Deus, porque Deus é amor. (1 João 4:8)",
      "Amados, amemos uns aos outros, pois o amor procede de Deus. (1 João 4:7)",
      "O amor é paciente, o amor é bondoso. Não inveja, não se vangloria, não se orgulha. (1 Coríntios 13:4)",
      "Tudo o que fizerem, façam com amor. (1 Coríntios 16:14)",
      "Mas Deus demonstra seu amor por nós: Cristo morreu em nosso favor quando ainda éramos pecadores. (Romanos 5:8)",
    ],

    'Consolo nas Aflições': [
      "Bem-aventurados os que choram, pois serão consolados. (Mateus 5:4)",
      "O Senhor está perto dos que têm o coração quebrantado e salva os de espírito abatido. (Salmos 34:18)",
      "Lancem sobre ele toda a sua ansiedade, porque ele tem cuidado de vocês. (1 Pedro 5:7)",
      "Sabemos que Deus age em todas as coisas para o bem daqueles que o amam, dos que foram chamados de acordo com o seu propósito. (Romanos 8:28)",
      "A minha graça te basta, porque o meu poder se aperfeiçoa na fraqueza. (2 Coríntios 12:9)",
      "Mesmo quando eu andar por um vale de trevas e morte, não temerei perigo algum, pois tu estás comigo. (Salmos 23:4)",
      "Ele enxugará dos seus olhos toda lágrima. Não haverá mais morte, nem tristeza, nem choro, nem dor. (Apocalipse 21:4)",
      "Bendito seja o Deus e Pai de nosso Senhor Jesus Cristo, o Pai das misericórdias e o Deus de toda consolação. (2 Coríntios 1:3)",
      "Muitas são as aflições do justo, mas o Senhor o livra de todas. (Salmos 34:19)",
      "Deus é o nosso refúgio e a nossa fortaleza, auxílio sempre presente na adversidade. (Salmos 46:1)",
    ],

    'Oração e Comunhão': [
      "Orem continuamente. Dêem graças em todas as circunstâncias. (1 Tessalonicenses 5:17-18)",
      "Clame a mim e eu responderei e lhe direi coisas grandiosas e insondáveis que você não conhece. (Jeremias 33:3)",
      "Peçam, e lhes será dado; busquem, e encontrarão; batam, e a porta lhes será aberta. (Mateus 7:7)",
      "E tudo o que pedirem em oração, se crerem, vocês receberão. (Mateus 21:22)",
      "Assim, aproximemo-nos do trono da graça com toda a confiança, a fim de recebermos misericórdia e encontrarmos graça que nos ajude no momento da necessidade. (Hebreus 4:16)",
      "Se o meu povo, que se chama pelo meu nome, se humilhar e orar, buscar a minha face e se afastar dos seus maus caminhos, dos céus o ouvirei. (2 Crônicas 7:14)",
      "Antes de clamarem, eu responderei; ainda estarão falando, e eu os ouvirei. (Isaías 65:24)",
      "A oração de um justo é poderosa e eficaz. (Tiago 5:16)",
      "Deleite-se no Senhor, e ele atenderá aos desejos do seu coração. (Salmos 37:4)",
      "Busquem o Senhor enquanto é possível achá-lo; clamem por ele enquanto está perto. (Isaías 55:6)",
    ],

    'Obediência e Fidelidade': [
      "Se vocês me amam, obedecerão aos meus mandamentos. (João 14:15)",
      "Seja fiel até a morte, e eu lhe darei a coroa da vida. (Apocalipse 2:10)",
      "Guardei a tua palavra no meu coração para não pecar contra ti. (Salmos 119:11)",
      "Acaso tem o Senhor tanto prazer em holocaustos e em sacrifícios quanto em que se obedeça à sua palavra? A obediência é melhor do que o sacrifício. (1 Samuel 15:22)",
      "Como são felizes os que guardam os seus estatutos e o buscam de todo o coração! (Salmos 119:2)",
      "Busquem, pois, em primeiro lugar o Reino de Deus e a sua justiça, e todas essas coisas lhes serão acrescentadas. (Mateus 6:33)",
      "Aquele que tem os meus mandamentos e os guarda, esse é o que me ama. (João 14:21)",
      "Não se deixem enganar: de Deus não se zomba. Pois o que o homem semear, isso também colherá. (Gálatas 6:7)",
      "Sejam praticantes da palavra, e não apenas ouvintes, enganando-se a si mesmos. (Tiago 1:22)",
      "Aquele que é fiel no pouco, também é fiel no muito. (Lucas 16:10)",
    ],

    'Alegria e Gratidão': [
      "Alegrem-se sempre no Senhor. Novamente direi: alegrem-se! (Filipenses 4:4)",
      "Dêem graças ao Senhor, porque ele é bom; o seu amor dura para sempre. (Salmos 107:1)",
      "Este é o dia em que o Senhor agiu; alegremo-nos e exultemos neste dia. (Salmos 118:24)",
      "O coração alegre é bom remédio, mas o espírito abatido faz secar os ossos. (Provérbios 17:22)",
      "Em tudo dai graças, porque esta é a vontade de Deus em Cristo Jesus para convosco. (1 Tessalonicenses 5:18)",
      "A alegria do Senhor é a vossa força. (Neemias 8:10)",
      "Cantem ao Senhor com alegria, todas as terras. Sirvam ao Senhor com alegria. (Salmos 100:1-2)",
      "Bendiga ao Senhor a minha alma! Não esqueça nenhuma de suas bênçãos! (Salmos 103:2)",
      "Graças a Deus por seu dom inefável! (2 Coríntios 9:15)",
      "Mesmo não florescendo a figueira, nem havendo fruto na videira... ainda assim me alegrarei no Senhor. (Habacuque 3:17-18)",
    ],

    'Proteção Divina': [
      "O Senhor te abençoe e te guarde; o Senhor faça resplandecer o seu rosto sobre ti e te conceda paz. (Números 6:24-26)",
      "Aquele que habita no abrigo do Altíssimo e descansa à sombra do Todo-poderoso pode dizer ao Senhor: Tu és o meu refúgio e a minha fortaleza, o meu Deus, em quem confio. (Salmos 91:1-2)",
      "Mil poderão cair ao seu lado, dez mil à sua direita, mas nada o atingirá. (Salmos 91:7)",
      "O anjo do Senhor acampa-se ao redor dos que o temem, e os livra. (Salmos 34:7)",
      "O Senhor o protegerá de todo o mal, protegerá a sua vida. O Senhor protegerá a sua saída e a sua chegada, desde agora e para sempre. (Salmos 121:8)",
      "Nenhuma arma forjada contra você prevalecerá. (Isaías 54:17)",
      "Elevo os olhos para os montes: de onde me virá o socorro? O meu socorro vem do Senhor, que fez o céu e a terra. (Salmos 121:1-2)",
      "Se o Senhor não edificar a casa, em vão trabalham os que a edificam. (Salmos 127:1)",
      "Tu és o meu esconderijo; tu me preservas da angústia e me cercas de alegres cantos de livramento. (Salmos 32:7)",
      "O nome do Senhor é torre forte; os justos correm para ela e estão seguros. (Provérbios 18:10)",
    ],

    'Cura e Restauração': [
      "Ele cura os que têm o coração partido e pensa as suas feridas. (Salmos 147:3)",
      "Cura-me, Senhor, e serei curado; salva-me, e serei salvo, pois tu és aquele a quem eu louvo. (Jeremias 17:14)",
      "Verdadeiramente ele tomou sobre si as nossas enfermidades, e as nossas dores levou sobre si. (Isaías 53:4)",
      "Eu sou o Senhor que te sara. (Êxodo 15:26)",
      "E a oração da fé salvará o doente, e o Senhor o levantará. (Tiago 5:15)",
      "Mas para vós, os que temeis o meu nome, nascerá o sol da justiça, e cura trará nas suas asas. (Malaquias 4:2)",
      "Ele enviou a sua palavra e os curou; livrou-os da morte. (Salmos 107:20)",
      "Ele perdoa todos os meus pecados e cura todas as minhas doenças. (Salmos 103:3)",
      "Os sãos não necessitam de médico, mas, sim, os que estão doentes; eu não vim chamar os justos, mas, sim, os pecadores ao arrependimento. (Marcos 2:17)",
      "E o seu nome, pela fé no seu nome, confirmou a este que vedes e conheceis; sim, a fé que vem por ele, deu a este, na presença de todos vós, esta perfeita saúde. (Atos 3:16)",
    ],

    'Provisão e Sustento': [
      "O meu Deus suprirá todas as necessidades de vocês, de acordo com as suas gloriosas riquezas em Cristo Jesus. (Filipenses 4:19)",
      "Fui jovem e agora sou velho, mas nunca vi o justo desamparado, nem seus filhos mendigando o pão. (Salmos 37:25)",
      "Olhem para as aves do céu, que não semeiam nem colhem... e o Pai celestial as alimenta. Vocês não valem muito mais do que elas? (Mateus 6:26)",
      "O Senhor é o meu pastor; de nada terei falta. (Salmos 23:1)",
      "Deem, e lhes será dado: uma boa medida, calcada, sacudida e transbordante será dada a vocês. (Lucas 6:38)",
      "Tragam o dízimo todo ao depósito do templo, para que haja alimento em minha casa. Ponham-me à prova, diz o Senhor dos Exércitos. (Malaquias 3:10)",
      "Pois o Senhor Deus é sol e escudo; o Senhor concede favor e honra; não recusa nenhum bem aos que vivem com integridade. (Salmos 84:11)",
      "E Deus é poderoso para fazer que lhes seja acrescentada toda a graça, para que em todas as coisas, em todo o tempo, tendo tudo o que é necessário, vocês transbordem em toda boa obra. (2 Coríntios 9:8)",
      "Peçam, e lhes será dado; busquem, e encontrarão; batam, e a porta lhes será aberta. (Mateus 7:7)",
      "Em tudo o que ele fez no serviço da casa de Deus... ele buscou o seu Deus e trabalhou de todo o coração; e assim prosperou. (2 Crônicas 31:21)",
    ],

    'Justiça e Integridade': [
      "Bem-aventurados os que têm fome e sede de justiça, pois serão satisfeitos. (Mateus 5:6)",
      "O Senhor não vê como o homem: o homem vê a aparência, mas o Senhor vê o coração. (1 Samuel 16:7)",
      "O Senhor ama a justiça e não desampara os seus fiéis. Para sempre serão protegidos. (Salmos 37:28)",
      "O justo caminha na sua integridade; felizes serão os seus filhos depois dele. (Provérbios 20:7)",
      "Praticar a justiça e o direito é mais aceitável ao Senhor do que oferecer sacrifícios. (Provérbios 21:3)",
      "Não usem balanças desonestas... Usem balanças e pesos justos. (Levítico 19:35-36)",
      "Quem anda com integridade anda com segurança, mas quem perverte os seus caminhos será descoberto. (Provérbios 10:9)",
      "Deus é juiz justo, um Deus que se ira todos os dias contra os ímpios. (Salmos 7:11)",
      "A religião pura e sem mácula, para com o nosso Deus e Pai, é esta: visitar os órfãos e as viúvas nas suas tribulações, e a si mesmo guardar-se incontaminado do mundo. (Tiago 1:27)",
      "Aprendam a fazer o bem! Busquem a justiça, acabem com a opressão. Lutem pelos direitos do órfão, defendam a causa da viúva. (Isaías 1:17)",
    ],

    'Família e Casamento': [
      "Assim, eles já não são dois, mas sim uma só carne. Portanto, o que Deus uniu, ninguém o separe. (Mateus 19:6)",
      "Honra teu pai e tua mãe, a fim de que tenhas vida longa na terra que o Senhor, o teu Deus, te dá. (Êxodo 20:12)",
      "Maridos, amem suas mulheres, assim como Cristo amou a igreja e entregou-se a si mesmo por ela. (Efésios 5:25)",
      "Mulheres, sujeitem-se a seus maridos, como ao Senhor. (Efésios 5:22)",
      "Filhos, obedeçam a seus pais no Senhor, pois isso é justo. (Efésios 6:1)",
      "Pais, não irritem seus filhos; antes criem-nos segundo a instrução e o conselho do Senhor. (Efésios 6:4)",
      "E acima de tudo, tenham amor intenso uns pelos outros, porque o amor cobre multidão de pecados. (1 Pedro 4:8)",
      "Se alguém não cuida de seus parentes, e especialmente dos de sua própria família, negou a fé e é pior que um descrente. (1 Timóteo 5:8)",
      "O homem deixará pai e mãe e se unirá à sua mulher, e eles se tornarão uma só carne. (Gênesis 2:24)",
      "A mulher sábia edifica a sua casa, mas com as próprias mãos a insensata derruba a sua. (Provérbios 14:1)",
    ],

    'Salvação e Graça': [
      "Porque Deus tanto amou o mundo que deu o seu Filho Unigênito, para que todo o que nele crer não pereça, mas tenha a vida eterna. (João 3:16)",
      "Pois vocês são salvos pela graça, por meio da fé, e isto não vem de vocês, é dom de Deus; não por obras, para que ninguém se glorie. (Efésios 2:8-9)",
      "Se você confessar com a sua boca que Jesus é Senhor e crer em seu coração que Deus o ressuscitou dentre os mortos, será salvo. (Romanos 10:9)",
      "Mas Deus demonstra seu amor por nós: Cristo morreu em nosso favor quando ainda éramos pecadores. (Romanos 5:8)",
      "Respondeu Jesus: 'Eu sou o caminho, a verdade e a vida. Ninguém vem ao Pai, a não ser por mim'. (João 14:6)",
      "Porque o salário do pecado é a morte, mas o dom gratuito de Deus é a vida eterna em Cristo Jesus, nosso Senhor. (Romanos 6:23)",
      "Portanto, agora já não há condenação para os que estão em Cristo Jesus. (Romanos 8:1)",
      "Se confessarmos os nossos pecados, ele é fiel e justo para perdoar os nossos pecados e nos purificar de toda injustiça. (1 João 1:9)",
      "Todo aquele que invocar o nome do Senhor será salvo. (Romanos 10:13)",
      "Não há salvação em nenhum outro, pois, debaixo do céu não há nenhum outro nome dado aos homens pelo qual devamos ser salvos. (Atos 4:12)",
    ],
  };

  // Retorna um Map com 'text' e 'reference' separados!
  static Map<String, String> getRandomVerse() {
    final todos = categorias.values.expand((x) => x).toList();
    final fraseInteira = todos[Random().nextInt(todos.length)];

    // Divide onde tem o parêntese da referência
    final divisor = fraseInteira.lastIndexOf('(');

    if (divisor != -1) {
      final texto = fraseInteira.substring(0, divisor).trim();
      final ref = fraseInteira
          .substring(divisor + 1, fraseInteira.length - 1)
          .trim();
      return {'text': texto, 'reference': ref};
    }

    return {'text': fraseInteira, 'reference': 'Bíblia Sagrada'};
  }
}
