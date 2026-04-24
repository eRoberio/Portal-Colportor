import 'dart:math';

class EgwDatabase {
  // O nosso banco de dados local dividido por temas
  static const Map<String, List<String>> categorias = {
    'A Importância da Obra': [
      "A obra de colportagem, devidamente dirigida, é obra missionária do mais elevado grau.",
      "Se há um trabalho mais importante que outro, é o de colocar as nossas publicações perante o público, levando-o assim a pesquisar as Escrituras.",
      "Nenhum trabalho superior há do que a colportagem evangélica; pois ela envolve a ministração da mais alta verdade.",
      "A imprensa é um poderoso meio de mover as mentes e os corações dos homens.",
    ],

    'Preparo e Consagração': [
      "Deus chama colportores que queiram aprender de Cristo como salvar almas.",
      "O colportor deve não só vender os livros, mas com espírito de oração, deixar literatura e falar de Cristo.",
      "O sucesso não depende tanto de talento, mas de sincera piedade e verdadeira consagração.",
      "A mente deve estar continuamente voltada para Deus em oração fervorosa enquanto estiverem no trabalho.",
    ],

    'A Abordagem (Na Porta)': [
      "Muitos há que, por causa de preconceitos, nunca conhecerão a verdade a menos que ela lhes seja levada à sua própria porta.",
      "Aproximem-se das pessoas com o coração cheio de simpatia e amor por elas.",
      "O obreiro deve apresentar-se com polidez, cortesia e modos agradáveis, que abram as portas para a verdade.",
      "Não falem muito sobre coisas comuns, mas levem a mente do ouvinte para a eternidade.",
    ],

    'Lidando com Dificuldades': [
      "O humilde colportor que obedece à comissão de Deus é acompanhado por anjos invisíveis aos olhos humanos.",
      "Não desanimem quando encontrarem oposição. Lembrem-se de que o próprio Cristo foi rejeitado.",
      "Quando o caminho parece fechado, confiem em Deus. Ele abrirá portas onde não vemos saída.",
      "O Senhor não os deixará sozinhos se vocês forem fiéis e perseverantes na obra que Ele lhes designou.",
    ],
    'Plenamente Preparado': [
      "O colportor deve buscar constante aperfeiçoamento e completo preparo espiritual.",
      "É essencial ter a mente enriquecida com o conhecimento profundo da Palavra de Deus.",
      "O obreiro deve conhecer perfeitamente o livro que vende para destacá-lo com clareza.",
      "O intelecto e o coração devem ser cultivados para formar um caráter equilibrado.",
      "O trabalho em duplas, unindo experientes e inexperientes, fortalece e instrui.",
      "A visão de Isaías inspira o obreiro a dizer: Eis-me aqui, envia-me a mim.",
    ],

    'Hábitos, Porte e Vestuário': [
      "A obra exige dignidade de comportamento, energia, coragem e entusiasmo.",
      "O tato, a humildade e a cortesia abrem portas e corações endurecidos.",
      "A honestidade e a integridade de caráter devem refletir-se no semblante.",
      "O vestuário asseado e sem ostentação honra a verdade e inspira respeito.",
      "A verdadeira cortesia cristã e a prestatividade revelam o caráter de Cristo.",
      "A reforma de saúde deve ser ensinada pelo exemplo prático e silencioso.",
    ],

    'Voz e Dicção': [
      "O dom da palavra é um talento precioso que deve ser cultivado com cuidado.",
      "A voz deve ser clara, distinta e eufônica para impressionar os ouvintes.",
      "A simplicidade na linguagem é mais eficaz do que o uso de palavras difíceis.",
      "Palavras brandas, bondosas e bem escolhidas cativam os corações.",
      "O colportor deve falar de Cristo com o mesmo amor e tato do próprio Salvador.",
      "A verdade ganha poder quando comunicada de forma expressiva e reverente.",
    ],

    'Diligência no Serviço': [
      "O sucesso depende mais de energia, boa vontade e fidelidade do que de talentos.",
      "Não há espaço para a indolência; o serviço requer fervor e ação perseverante.",
      "O obreiro deve cultivar hábitos de regularidade, presteza e estrita operosidade.",
      "Cada dever diário deve ser executado com exatidão e inteireza de coração.",
      "A dedicação diligente transforma o trabalho em um contínuo ato de devoção.",
      "O relato de experiências animadoras fortalece a igreja e inspira outros obreiros.",
    ],

    'O Poder da Oração': [
      "O obreiro deve orar constantemente por uma experiência mais profunda com Deus.",
      "A oração humilde e fervorosa faz mais pela obra do que qualquer outro recurso.",
      "A dependência de Deus na oração é essencial para enfrentar as investidas de Satanás.",
      "O estudo diário da Bíblia e a oração revestem o colportor com a armadura divina.",
      "Orar com as famílias visitadas quebra preconceitos e abre portas para a verdade.",
      "Cada dificuldade enfrentada deve ser vista como um chamado à oração importuna.",
    ],

    'Estratégias e Pontos de Venda': [
      "As publicações devem ser levadas proativamente ao povo, exaltando seu real valor.",
      "A circulação massiva de nossos livros aumenta o interesse e a busca pela verdade.",
      "Apresentar a literatura pelos seus próprios méritos é superior ao uso de prêmios.",
      "A prestatividade no lar e o interesse genuíno pelas famílias ganham a confiança.",
      "Conhecimentos práticos sobre tratamentos de saúde abrem caminhos missionários.",
      "O verdadeiro objetivo da venda não é o lucro, mas a salvação das almas alcançadas.",
    ],

    'Finanças e Integridade': [
      "A estrita honestidade e o pronto pagamento dos livros são princípios inegociáveis.",
      "A negligência e o endividamento desnecessário comprometem a obra e o obreiro.",
      "O dinheiro manuseado deve ser tratado com exatidão e cuidado, evitando desperdícios.",
      "O ganho financeiro jamais deve ofuscar o propósito missionário da colportagem.",
      "A economia, a renúncia e a abnegação são qualidades essenciais no campo.",
      "Negócios paralelos não devem ser misturados com a sagrada obra de espalhar a verdade.",
    ],

    'Cooperação e Evangelismo': [
      "A obra da colportagem complementa e fortalece o ministério da pregação.",
      "Os mensageiros silenciosos firmam as pessoas na verdade e as protegem de erros.",
      "O colportor deve focar no amor de Deus, evitando controvérsias doutrinárias.",
      "Oportunidades para dar estudos bíblicos devem ser aproveitadas com sabedoria.",
      "A obra médico-missionária e o ministério pastoral andam de mãos dadas no campo.",
      "O obreiro deve ser um profundo estudante da Bíblia, preparado para ensinar.",
    ],

    'Guiados pelo Espírito': [
      "A obra da colportagem deve estar sempre sob o controle do Espírito Santo.",
      "O obreiro deve orar pelo derramamento do Espírito, essencial para convencer almas.",
      "O segredo do sucesso é a união do esforço humano perseverante com o poder divino.",
      "O Espírito Santo inspira as palavras certas a serem ditas no momento oportuno.",
      "O poder transformador de Deus é o que verdadeiramente toca e muda os corações.",
      "A entrega total garante o auxílio onipotente dAquele que possui todo o poder.",
    ],

    'Acompanhados por Anjos': [
      "Os colportores fiéis têm a constante companhia e proteção dos anjos celestiais.",
      "Milhares de anjos aguardam para cooperar na iluminação e salvação de almas.",
      "Os seres celestiais vão à frente, preparando o coração do povo para a mensagem.",
      "Os anjos abrandam os corações quando o nome de Jesus é pronunciado com amor.",
      "Eles suprem as deficiências humanas e garantem o verdadeiro sucesso na obra.",
      "Trabalhar sob a visão do Céu traz uma profunda, rica e vitoriosa experiência espiritual.",
    ],

    'Enfrentando Dificuldades': [
      "Deus possui infinitos meios de prover o que necessitamos e de aplainar o caminho.",
      "O sucesso não se mede por aparências, mas pelo espírito fiel com que se trabalha.",
      "O desânimo no serviço é superado pela confiança inabalável nas promessas divinas.",
      "As dificuldades são oportunidades para fortalecer a fé e experimentar o auxílio de Deus.",
      "Devemos manter o olhar no Salvador, enfrentando os obstáculos com bravura e esperança.",
      "Nenhuma murmuração deve existir quando colocamos nossa eficiência inteiramente em Cristo.",
    ],

    'Livros da Mensagem': [
      "A missão principal é circular livros que contêm a verdade presente e as advertências finais.",
      "Livros seculares ou de especulações não devem desviar o foco da mensagem do terceiro anjo.",
      "A literatura escolhida deve preparar um povo para resistir às provas dos últimos dias.",
      "O colportor deve absorver o espírito dos livros e transmiti-los com profunda convicção.",
      "Livros que expõem as doutrinas fundamentais e a fé prática são a grande prioridade.",
      "Devemos inundar o mundo com publicações que exaltam os mandamentos de Deus e a fé de Jesus.",
    ],

    'Os Grandes Livros': [
      "Obras como O Grande Conflito e Patriarcas e Profetas são vitais para o tempo atual.",
      "Estes livros expõem a verdade de forma indelével e protegem os leitores de enganos.",
      "A influência destas obras perdurará, resultando em conversões futuras.",
      "O Grande Conflito possui valor inestimável por revelar as cenas finais da história terrena.",
      "A venda dos grandes livros deve ser impulsionada com o mesmo zelo dedicado a obras menores.",
      "Eles são a voz de Deus comunicando luz, paz e salvação a um mundo em trevas.",
    ],

    'Publicações de Saúde': [
      "A reforma de saúde é a cunha de entrada que abre mentes para verdades espirituais.",
      "A verdadeira religião e as leis de saúde caminham juntas na santificação do homem.",
      "Distribuir literatura sobre saúde remove preconceitos e alcança classes difíceis de atingir.",
      "O colportor deve atuar como missionário médico, ensinando princípios de vida saudável.",
      "As revistas e livros de saúde preparam o povo para aceitar a mensagem do terceiro anjo.",
      "A saúde e a temperança devem ser ensinadas diligentemente para vencer vícios do apetite.",
    ],

    'Equilíbrio na Literatura': [
      "Livros religiosos e de saúde são a trama e a urdidura de uma obra perfeitamente unida.",
      "Nenhum dos ramos deve ser exaltado em detrimento do outro; ambos são complementares.",
      "A mensagem do terceiro anjo é o corpo central, e a obra de saúde é o seu braço direito.",
      "Deve haver diversidade: o que não atrai uma mente pode facilmente alcançar outra.",
      "Literatura de ficção, frívola ou sensacionalista, deve ser absolutamente rejeitada.",
      "Pequenos folhetos abrem caminhos para grandes obras, completando o arsenal missionário.",
    ],

    'O Ministério das Revistas': [
      "As revistas são portadoras de verdades bíblicas benditas, com alto poder de salvação.",
      "Assinaturas anuais geram influência permanente, superando os resultados de curto prazo.",
      "A distribuição de periódicos deve anunciar claramente que o fim de todas as coisas está próximo.",
      "O trabalho com revistas educa e disciplina o obreiro, preparando-o para maiores responsabilidades.",
      "Deve haver perseverança, tato e zelo para elevar os resultados e a captação de assinaturas.",
      "A verdadeira economia, e não o desperdício, multiplica as oportunidades de expansão da obra.",
    ],

    'O Alcance das Publicações': [
      "O prelo é o instrumento determinado por Deus para alcançar todas as nações, tribos e línguas.",
      "Muitos que parecem ignorar os livros os buscarão ativamente em tempos de provação e crise.",
      "Cada página ou fragmento que contém a verdade presente é um tesouro sagrado.",
      "Nos dias finais, a semente literária brotará, e milhares se converterão num único dia.",
      "A literatura semeada produzirá uma grandiosa colheita durante a obra de encerramento.",
      "A recompensa suprema será o encontro glorioso, no Céu, com as almas resgatadas pelos livros.",
    ],
  };

  // Função auxiliar para sortear uma frase de TODAS as categorias juntas (para o card principal)
  static String getRandomQuote() {
    final todasAsFrases = categorias.values.expand((x) => x).toList();
    return todasAsFrases[Random().nextInt(todasAsFrases.length)];
  }

  // Função auxiliar para sortear uma frase de uma categoria ESPECÍFICA
  static String getRandomQuoteFromCategory(String categoria) {
    final frasesDaCategoria =
        categorias[categoria] ?? ["Nenhuma frase encontrada."];
    return frasesDaCategoria[Random().nextInt(frasesDaCategoria.length)];
  }
}
