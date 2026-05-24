import 'dart:convert';
import 'package:harvest_valley/app/save/game_state.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'package:harvest_valley/services/GeminiService.dart';

class AiQuestGenerator {
  static const String _worldContext = '''
    CONTEXTO: Jogo "Harvest Valley".
    
    NPCs DISPONÍVEIS E PERSONALIDADES:
    - Prefeito: Autoritário mas preocupado. Foca em limpeza, cidadania e reciclagem.
    - Clara (Fazendeira): Prática, mentora. Foca em plantações, regar plantas e cuidar de animais.
    - Carlos (Mercador): Pragmático, honesto. Foca em economia, vendas e diversidade de produtos.
    - Taina (Indígena): Espiritual, poética. Foca em harmonia com a terra, rotação de cultura e não poluir.
    - Gabriel (Surfista): Gírias ("vibe", "brother"), descontraído. Foca em oceano limpo e água.
    - Dr. Lucas (Cientista): Analítico, usa dados/estatística. Foca em eficiência e ecologia lógica.
    - Bianca (Cidadã): Otimista, urbana. Foca na beleza da cidade e comida saudável.
    - Violeta (Cidadã): Melancólica, sensível. Foca nos sentimentos das plantas e harmonia.

    ITENS VÁLIDOS (IDs):
    - Sementes: wheat_seed, springOnion_seed, potato_seed, strawberry_seed, garlic_seed 
    - Plantas: wheat_item, springOnion_item, potato_item, strawberry_item, garlic_item
    - Animais: egg_item, eggBig_item, milk_item, milkBig_item, wool_item, milkGoat_item
    - Outros: trash_item (Lixo)
  ''';

  Future<QuestModel?> generateDynamicQuest(GameState state) async {
    // 1. Monta os dados do jogador para a IA analisar
    final playerData =
        '''
      ESTADO ATUAL DO JOGADOR:
      - Dinheiro: ${state.money}
      - Reputação: ${state.reputacao} (0 a 100)
      - Inventário: ${state.inventory.map((s) => "${s.tipo}: ${s.quantidade}").join(', ')}
      - Reciclou hoje? ${state.reciclouHoje}
      - Vendeu hoje? ${state.vendeuHoje}
      - Animais: ${state.animalStates.length}
    ''';

    // 2. O Prompt de comando
    final prompt =
        '''
      $_worldContext
      $playerData

      TAREFA:
      Atue como um Game Master. Analise o estado do jogador e crie UMA missão para um dos NPCs.
      obs: AS SEMENTES NAO SAO ITENS ENTREGAVEIS, QUANDO UM NPC PEDIR ALGUMA COISA, ELE DEVE PEDIR O ITEM FINAL (PLANTA OU PRODUTO ANIMAL).
      
      CRITÉRIOS DE ESCOLHA:
      - Baixa Reputação (<40) ou inventário sujo (trash_item)? -> Prefeito, Gabriel ou Lucas reclamam.
      - Vendeu pouco hoje? -> Carlos pede itens específicos.
      - Tem animais? -> Clara pede produtos (mas lembresse que eles sao vendido para o Carlos).
      - Inventário cheio de um só tipo de planta? -> Taina pede rotação (traga outro item).
      - Jogador rico e boa reputação? -> Bianca ou Violeta pedem algo para celebrar.

      OUTPUT OBRIGATÓRIO (JSON):
      Retorne APENAS um JSON válido. Se não houver motivo para missão, retorne um JSON vazio {}.
      
      OBS: Os ids dos itens devem ser traduzidos caso sejam utilizados nas descricoes/dialogo dos NPCS
      'strawberry': 'Morango', 'springOnion': 'Cebolinha', 'potato': 'Batata', 'garlic': 'Alho', 'wheat': 'Trigo', 
      , 'milk_item': 'Leite de Bezerro', 'milkBig_item': 'Leite de Vaca', 'milkGoat_item': 'Leite de Cabra', 'wool_item': 'Lã de Ovelha', 'egg_item': 'Ovo de Galinha', 'eggBig_item': 'Ovo Grande de Galinha',
      'trash': 'Lixo'
      Formato:
      {
        "npcName": "Nome Exato do NPC",
        "title": "Título curto",
        "description": "Diálogo do NPC falando DIRETAMENTE com o player. IMITE A PERSONALIDADE E GÍRIAS DO NPC ESCOLHIDO.",
        "targetItem": "ID do item necessário",
        "targetAmount": Inteiro (1 a 10),
        "rewardText": "Agradecimento do NPC na personalidade dele"
      }
    ''';

    // 3. Chama o Gemini
    final jsonString = await GeminiService().generateJson(prompt);

    if (jsonString == null || jsonString == "{}" || jsonString.isEmpty) {
      return null;
    }

    try {
      final Map<String, dynamic> data = jsonDecode(jsonString);

      // Validação básica
      if (!data.containsKey('npcName') || !data.containsKey('targetItem')) {
        return null;
      }
      // Cria a missão
      return QuestModel(
        id: 'ia_quest_${DateTime.now().millisecondsSinceEpoch}',
        title: data['title'],
        description: data['description'],
        targetAmount: data['targetAmount'],
        targetItem:
            data['targetItem'], // Garanta que adicionou esse campo no QuestModel
        npcName:
            data['npcName'], // Garanta que adicionou esse campo no QuestModel
        rewardText: data['rewardText'],
        currentAmount: 0,
        status: QuestStatus.active,
      );
    } catch (e) {
      print("Erro ao parsear missão da IA: $e");
      return null;
    }
  }
}
