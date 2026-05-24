class DialogueData {
  // --- PREFEITO (Gestão, Guia e Reciclagem) ---
  // Voz: Autoridade responsável, preocupação com a cidade, tom oficial mas humanizado
  static const List<String> prefeitoBad = [
    "Cidadão... precisamos conversar sobre seu comportamento na cidade.", // 0: Saudação (Bad)
    "Lixo espalhado, falta de cuidado... Harvest Valley merecia melhor de você.",
    "Ouvi relatos sobre sua fazenda. A bagunça por lá está afetando a imagem de toda a cidade.",
    "Se quer progredir, comece respeitando o espaço público. Isso é básico.",
    "A irresponsabilidade tem limite, e você está chegando perto dele.",
    "Reciclar não é favor, é obrigação. Faça sua parte como cidadão.",
  ];

  static const List<String> prefeitoNeutral = [
    "Bem-vindo, cidadão. O progresso de Harvest Valley depende de cada um de nós.", // 0: Saudação
    "Viu lixo pela rua? Jogue na lixeira verde (reciclável) e ganhe mais benefícios!", // 1: Dica Ouro (Reciclagem)
    "Precisa vender colheitas ou comprar sementes? Procure o Carlos no Armazém.", // 2: Guia
    "A lixeira comum limpa a cidade, mas a reciclável ajuda o planeta.", // 3: Dica Mecânica
    "O Gabriel cuida da praia ao sul, Taina protege a floresta a leste. Visite-os!", // 4: Guia Geográfico
    "Uma cidade limpa atrai felicidade e progresso. Conto com sua ajuda nas ruas.", // 5: Comunidade
    "Sustentabilidade não é moda, é necessidade. O futuro de Harvest Valley depende disso.", // 6: Filosófico
    "Vejo que está trabalhando. Continue mantendo a cidade em ordem.", // 7: Encorajamento
  ];

  static const List<String> prefeitoGood = [
    "Excelente, cidadão! É um prazer ver seu comprometimento com a cidade.", // 0: Saudação (Good)
    "O povo inteiro nota sua responsabilidade. Parabéns pelo empenho genuíno!",
    "Pessoas como você são o alicerce desta cidade. Obrigado por fazer a diferença.",
    "Seus números de reciclagem são impressionantes. Você é um modelo de cidadania!",
    "Harvest Valley fica mais bonita e limpa graças a você. Continue inspirando os outros!",
    "É com gente como você que posso sonhar com um futuro sustentável para o vale.",
  ];

  // --- TAINA (Espiritualidade, Terra e Proteção - Indígena) ---
  // Voz: Espiritual, conectada à natureza, sábia e poética, respeito ancestral
  static const List<String> tainaBad = [
    "A terra sente seu descuido... ela está se fechando para você.", // 0: Saudação/Alerta (Bad)
    "Quando ignoramos a natureza, ela guarda um silêncio que dói. O Grande Espírito não está feliz.",
    "Sinto desequilíbrio profundo em suas ações. A floresta chora por você.",
    "As plantas não florescem para quem desrespeita o solo e o ciclo da vida.",
    "O vento traz um aviso: Harvest Valley precisa de proteção, não de mais sujeira.",
    "Você quebrou a harmonia. Precisamos restaurar o respeito com a terra.",
  ];

  static const List<String> tainaNeutral = [
    "Olá, irmão. A terra não nos pertence; nós pertencemos à terra.", // 0: Saudação/Filosofia
    "Cada semente que você planta é uma promessa de vida. Elas são sagradas, cuide bem delas.", // 1: Sobre Plantio
    "Plástico sufoca o espírito das águas. Nunca jogue lixo nos rios ou no solo.", // 2: Sobre Poluição
    "Sente o vento? Ele carrega as vozes dos ancestrais pedindo proteção à natureza.", // 3: Natureza
    "Respeite o tempo da colheita. A pressa não faz nada crescer, só causa dano.", // 4: Paciência
    "Quando você cura o solo, você cura a si mesmo e o vale inteiro.", // 5: Cura
    "Observe a lua. Ela rege as marés e o tempo de descanso da terra.", // 6: Ciclos
    "As raízes conectam tudo. Um solo vivo é um futuro vivo.", // 7: Conexão
  ];

  static const List<String> tainaGood = [
    "Seu cuidado com a natureza é inspirador, irmão. A terra sorri para você.", // 0: Saudação (Good)
    "Sinto harmonia no seu trabalho. As sementes reconhecem seu carinho e dedicação.",
    "Você caminha em sintonia com o vale. O espírito da floresta te aceita como guardião.",
    "Os ancestrais agradecem seu respeito pela vida. Você honra tudo que toca.",
    "A luz da lua brilha mais forte para quem honra o solo e o ciclo natural.",
    "Você é um com a terra. Isso é raro e precioso.",
  ];

  // --- GABRIEL (Surfista, Oceanos e Liberdade) ---
  // Voz: Descontraído, apaixonado pelo mar, gírias, tom casual mas consciente
  static const List<String> gabrielBad = [
    "Aí, cara... precisamos conversar. O mar tá sofrendo com suas escolhas.", // 0: Saudação (Bad)
    "Não dá pra surfar com lixo flutuando, mano. Ajuda aí, a vibe tá pesada demais.",
    "O oceano devolve tudo o que a gente joga nele. Isso é karma marinho, irmão!",
    "Tô vendo mais sujeira por aqui... e a maré não esconde nada, viu?",
    "Continua assim e nem onda limpa vai ter mais, só plástico e esgoto, cara.",
    "A praia tá sofrendo com descaso. Bora virar essa vibe!",
  ];

  static const List<String> gabrielNeutral = [
    "E aí, brother! A vibe da praia tá limpa hoje, graças a quem recicla.", // 0: Saudação
    "Tudo que desce pelo esgoto da cidade acaba no meu oceano. Cuidado com o que você descarta!", // 1: Consciência
    "Vi uma tartaruga hoje tentando evitar plástico... precisamos acabar com isso, urgente.", // 2: Alerta
    "Economize água na rega, mano. O mar é grande, mas água doce é rara, sacou?", // 3: Dica
    "Depois da colheita, bora pegar umas ondas pra relaxar e limpar a mente?", // 4: Social
    "Se a maré subir com sujeira, ninguém surfa. Mantenha a vibe, beleza?", // 5: Limpeza
    "O pôr do sol fica muito mais irado sem garrafa pet na areia. A natureza agradece.", // 6: Beleza
    "Você tá ajudando a manter meu playground limpo. Respeitável, manin.", // 7: Agradecimento
  ];

  static const List<String> gabrielGood = [
    "Aí sim, brother! Você é da paz, a praia tá top por sua causa!", // 0: Saudação (Good)
    "O mar agradece! Você tá salvando várias tartarugas sem nem perceber, que atitude!",
    "Com gente como você, dá até gosto surfar. A vibe está 100%!",
    "Caramba, tá tudo tão limpo que até os peixes estão fazendo festa por aqui!",
    "Valeu por cuidar da vibe da praia. Você é brabo! O oceano te respeita.",
    "Mano, você é lenda! A praia nunca esteve melhor!",
  ];

  // --- CARLOS (Mercador - Venda, Compra e Economia) ---
  // Voz: Pragmático, comerciante honesto, foco em qualidade e fair trade
  static const List<String> carlosBad = [
    "Olha... seus produtos não estão bons o suficiente para os preços que ofereço.", // 0: Saudação (Bad)
    "Se continuar descuidando da fazenda, nem posso pagar bem. A qualidade caiu bastante.",
    "Sementes? Tenho, mas não vou arriscar meu estoque com qualquer um nesse momento.", // 2: Loja (Ruim)
    "Esse preço de hoje não é bom para esse nível de produto. Sinto, mas é a verdade.", // 3: Venda (Ruim)
    "Lixo ou sujeira aqui no armazém? Não rola. Mantenha as coisas limpas, entendeu?",
    "Clientes responsáveis recebem melhores oportunidades. No momento, você não tá na lista.",
  ];

  static const List<String> carlosNeutral = [
    "Bem-vindo ao Armazém! Aqui valorizamos o produto local e a honestidade.", // 0: Saudação
    "Evite embalagens plásticas. Traga sua própria sacola! É melhor para todos.", // 1: Sustentabilidade
    "Tenho sementes de primeira: Morango, Batata, Alho e Cebolinha. O que vai levar?", // 2: LOJA (Abre menu)
    "Vejo que trouxe produtos da fazenda! Eu compro a preço justo, sempre.", // 3: VENDA (Compra itens)
    "Solo saudável = alimentos saudáveis. Cuide bem da sua terra!", // 4: Dica
    "Morango é caro, mas o retorno é garantido se você fizer a sua parte.", // 5: Dica de Venda
    "Cebolinha? Cresce num piscar de olhos. Ótimo para quem quer renda rápida.", // 6: Dica de Venda
    "Negócio justo é negócio que dura. Aqui no armazém, é assim.", // 7: Filosofia
  ];

  static const List<String> carlosGood = [
    "Que bom te ver! Seus produtos estão impecáveis como sempre.", // 0: Saudação (Good)
    "Gosto de fazer negócios com gente responsável e dedicada como você. É um prazer!",
    "Precisa de algo especial? Tenho um estoque de primeira linha só para meus melhores clientes.", // 2: Loja (Bom)
    "Me mostre o que você tem! Produtos como os seus merecem preço premium hoje.", // 3: Venda (Bom)
    "O solo da sua fazenda tá ótimo. Dá pra ver a qualidade em tudo que você traz!",
    "Posso fazer desconto camarada só para você. Você merece!",
    "Você é meu melhor fornecedor. Continue assim e vamos ficar ricos juntos!",
  ];

  // --- CLARA (Agricultora - Técnica e Dicas Práticas) ---
  // Voz: Prática, experiente, amigável com vizinhos, direta nas críticas e elogios
  static const List<String> claraBad = [
    "Vizinho... precisamos conversar sobre sua fazenda. Tá meio bagunçada.",
    "Você tá esquecendo de regar? Suas plantas tão secas demais.",
    "Olha, meus animais exigem muito cuidado e carinho. Não sei se você tá pronto, mas... quer dar uma olhada neles?", // loja
    "Seu campo tá desorganizado... assim fica difícil cultivar com eficiência.",
    "Com essa falta de cuidado, nem o melhor adubo do Carlos resolve, acredita?",
    "Lixo na fazenda? Limpa isso aí... dá até dó das sementes!",
    "Não dá pra colher coisa boa do jeito que você trata o solo. É preciso dedicação!",
  ];

  static const List<String> claraNeutral = [
    "Oi vizinho! Precisa de ajuda ou dica com as plantações?",
    "Encontrou lixo na fazenda? Limpe antes de plantar. O solo agradece.",
    "Uma fazenda de verdade precisa de vida! Tenho vacas, galinhas, ovelhas, cabras, etc. Quer ver o que tenho disponível?", // loja
    "Lembre de regar todo dia. Planta com sede não cresce e não dá lucro!",
    "Raízes precisam de espaço. Não plante muito junto ou a colheita não presta.",
    "Melhor horário pra regar? Cedo de manhã ou final da tarde. Evita desperdício.",
    "A qualidade do solo é tudo. Invista nele que ele investe em você!",
    "Viu meu canteiro? Assim é que fica uma fazenda bem cuidada.",
    "Paciência, vizinho. Agricultura não é correria, é arte.",
  ];

  static const List<String> claraGood = [
    "Vizinho! Que alegria ver sua fazenda tão bem cuidada!",
    "Suas plantas tão crescendo fortes e saudáveis. Você é um exemplo de agricultor!",
    "Sei que meus animais serão tratados como família por você. Separei os melhores do rebanho! Quer escolher?", // loja
    "Dá pra ver de longe que você sabe o que tá fazendo. Parabéns!",
    "Se continuar assim, você vira referência de agricultura na região inteira!",
    "Sua fazenda tá impecável e produtiva. Que privilégio ter vizinho assim!",
    "Você tem mão verde, vizinho. Continue assim!",
  ];

  // --- DR. LUCAS (Cientista - Dados e Lógica) ---
  // Voz: Analítico, dados-driven, tom professoral mas acessível, esperançoso
  static const List<String> lucasBad = [
    "Hmm... os dados sobre suas ações não estão nada bons. Precisamos conversar.", // 0: Saudação (Bad)
    "A ciência não mente: seus hábitos não são sustentáveis. Isso é um problema estatístico sério.",
    "Detectei aumento de resíduos no solo... e sei exatamente de onde vem essa anomalia.",
    "Essa quantidade de lixo não é aceitável para o ecossistema. É simples matemática.",
    "Se continuar assim, os índices de qualidade do vale vão despencar. É inevitável.",
    "Seus números estão no vermelho. Preciso de ação, não de promessas.",
  ];

  static const List<String> lucasNeutral = [
    "Olá! Estou coletando amostras do solo para medir o impacto ambiental aqui.", // 0: Saudação
    "Sabia que reciclar uma lata de alumínio economiza energia pra 3h de TV? É fato comprovado.", // 1: Fato Científico
    "Suas plantas absorvem carbono. Sua fazenda literalmente limpa o ar da cidade!", // 2: Incentivo
    "Plásticos levam séculos pra decompor. Reciclagem é crucial — matematicamente essencial.", // 3: Fato Triste
    "Ciência e natureza devem andar juntas para um futuro viável.", // 4: Filosófico
    "Estou desenvolvendo fertilizante natural. Nada de químicos nocivos, só biologia pura!", // 5: Projeto
    "Cada árvore plantada reduz a temperatura térmica da região. Fenômeno fascinante!", // 6: Fato Científico
    "Os dados do vale mostram tendência positiva. Continue contribuindo!", // 7: Encorajamento
  ];

  static const List<String> lucasGood = [
    "Excelente! Os dados mostram que você está fazendo um trabalho exemplar.", // 0: Saudação (Good)
    "Você está reduzindo drasticamente a pegada ecológica de toda a cidade. Impressionante!",
    "Suas práticas sustentáveis são cientificamente admiráveis e altamente eficientes!",
    "A natureza responde rápido e positivamente ao seu bom trabalho. Os gráficos comprovam!",
    "Você está contribuindo para um futuro mais limpo, verde e eficiente. Parabéns!",
    "Seus números são exemplares. Você merecia estar na minha pesquisa como case de sucesso!",
  ];

  // --- BIANCA (Cidadã - Otimismo e Comunidade) ---
  // Voz: Entusiasmada, positiva, encoraja outros, urbana e moderna
  static const List<String> biancaBad = [
    "Oi... então, ultimamente a cidade tá mais suja. Espero que não seja sua culpa.", // 0: Saudação (Bad)
    "Fico triste quando vejo lixo por aí. Isso apaga o brilho do dia, sabe?",
    "Vamos cuidar melhor da cidade? Ela merece mais carinho de todos.",
    "Se cada um fizesse sua parte, tudo melhoraria... mas você poderia se esforçar mais.",
    "Tomara que você ajude mais da próxima vez. A cidade conta com a gente!",
    "Percebi descuido em você últimamente. Vamos virar essa vibe?",
  ];

  static const List<String> biancaNeutral = [
    "Oi! Sou a Bianca! Adoro ver nossa cidade ficando mais verde e alegre!", // 0: Saudação
    "Adoro comprar vegetais frescos. Têm muito mais sabor e vitalidade!", // 1: Sobre Alimentos
    "Minha lixeira de recicláveis tá cheia hoje. Fazendo minha parte sempre!", // 2: Reciclagem
    "O dia tá lindo pra caminhar pela cidade, não acha? Que perfeição!", // 3: Social
    "Você viu como o jardim da praça está bonito e florido? Lindo demais!", // 4: Beleza
    "Sua fazenda contribui pra qualidade de vida de todos aqui. Obrigada!", // 5: Agradecimento
    "Posso perguntar? Como você consegue manter tudo tão bem organizado?", // 6: Curiosidade
  ];

  static const List<String> biancaGood = [
    "Oi! Nossa, você é incrível! A cidade tá tão linda por sua causa!", // 0: Saudação (Good)
    "Adoro ver pessoas como você cuidando do meio ambiente com tanto carinho!",
    "Obrigada por deixar tudo tão limpo e agradável. Você é demais!",
    "Se todos fossem como você, o mundo seria mais verde e feliz!",
    "Você inspira positividade por onde passa. É um prazer conviver com sua energia!",
    "Você deveria dar oficinas sobre sustentabilidade. Você é um exemplo!",
  ];

  // --- VIOLETA (Cidadã - Filosofia e Sensibilidade) ---
  // Voz: Contemplativa, poética, sensível à harmonia, profunda
  static const List<String> violetaBad = [
    "Olá... as árvores parecem tristes ultimamente. Sinto um peso no ar.", // 0: Saudação (Bad)
    "Fico desapontada ao ver lixo na rua. Quebra a harmonia do ambiente.",
    "A natureza sente quando não cuidamos dela. Ela chora em silêncio.",
    "Espero que você reflita sobre suas ações e o impacto que causam.",
    "A cidade merece mais respeito e um olhar mais cuidadoso do que isso.",
    "Há desarmonia no ar por aqui. Você sente também?",
  ];

  static const List<String> violetaNeutral = [
    "Olá, sou a Violeta. Gosto de caminhar por aqui e observar a natureza.", // 0: Saudação
    "Já viajou pra lugares sem árvores? É muito triste e quente. A vida precisa de verde.", // 1: Reflexão
    "Ouvi que o Gabriel achou lixo na praia novamente. Que pena, o oceano é tão delicado.", // 2: Conexão
    "A vida na cidade é corrida, mas não podemos esquecer nossa responsabilidade com a terra.", // 3: Responsabilidade
    "Minha avó dizia que falar com as plantas ajuda elas a crescerem mais fortes.", // 4: Sabedoria
    "Há algo especial em cultivar vida. Você sente isso também?", // 5: Filosofia
    "A beleza está nos detalhes: uma folha, uma flor, um gesto de cuidado.", // 6: Poesia
  ];

  static const List<String> violetaGood = [
    "Olá... sinto harmonia ao te ver. A cidade respira melhor graças a você.", // 0: Saudação (Good)
    "As árvores parecem mais vivas e radiantes... acho que é por sua causa.",
    "Sinto paz e equilíbrio vendo sua dedicação ao meio ambiente.",
    "Você torna Harvest Valley um lugar mais mágico e acolhedor para todos.",
    "Obrigada por cuidar da natureza com tanto carinho. Sua energia é inspiradora.",
    "Há harmonia no seu trabalho. Isso é raro e precioso de se encontrar.",
  ];
}
