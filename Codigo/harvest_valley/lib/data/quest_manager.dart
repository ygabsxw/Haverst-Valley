import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'package:harvest_valley/player/human.dart';

final Map<String, String> _displayNames = {
  'strawberry': 'Morango',
  'springOnion': 'Cebolinha',
  'potato': 'Batata',
  'garlic': 'Alho',
  'wheat': 'Trigo',
  'trash': 'Lixo',
  'milk_item': 'Leite de Bezerro',
  'milkBig_item': 'Leite de Vaca',
  'milkGoat_item': 'Leite de Cabra',
  'wool_item': 'Lã de Ovelha',
  'egg_item': 'Ovo de Galinha',
  'eggBig_item': 'Ovo Grande de Galinha',
};

class QuestManager {
  static bool checkInteraction(
    String npcName,
    BuildContext context,
    HumanPlayer player,
    VoidCallback onFinish, {
    Sprite? portrait,
    String occupation = '',
  }) {
    if (npcName == "Prefeito") {
      if (_handlePrefeitoQuest(context, player, portrait, occupation))
        return true;
    } // missao tutorial

    if (npcName == "Clara") {
      if (_handleClaraQuest(context, player, portrait, occupation)) return true;
    } // cap 1

    if (npcName == "Carlos") {
      if (_handleCarlosQuest(context, player, portrait, occupation))
        return true;
    } // ainda nada

    if (npcName == "Gabriel") {
      if (_handleGabrielQuest(context, player, portrait, occupation))
        return true;
    } // ainda nada

    if (npcName == "Taina") {
      if (_handleTainaQuest(context, player, portrait, occupation)) return true;
    } // ainda nada

    if (npcName == "Bianca") {
      if (_handleBiancaQuest(context, player, portrait, occupation))
        return true;
    } // ainda nada

    if (npcName == "Violeta") {
      if (_handleVioletaQuest(context, player, portrait, occupation))
        return true;
    } // ainda nada

    if (npcName == "Dr. Lucas") {
      if (_handleDrLucasQuest(context, player, portrait, occupation))
        return true;
    } // ainda nada

    if (_handleDynamicQuest(npcName, context, player, portrait, occupation)) {
      return true;
    }

    return false;
  }

  // missoes do prefeito
  static bool _handlePrefeitoQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    if (gameSession.currentState == null) return false;

    final quest = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (quest.id.isEmpty) {
      TalkDialog.show(
        context,
        [
          _say(
            "Prefeito",
            "Bem-vindo a cidade de Harvest Valley! Sua avó me avisou que você chegaria.",
            portrait,
            occupation,
          ),
          _say(
            "Prefeito",
            "A cidade está um pouco suja ultimamente...",
            portrait,
            occupation,
          ),
          _say(
            "Prefeito",
            "Se você puder recolher 5 sacos de lixo, eu lhe darei uma recompensa.",
            portrait,
            occupation,
          ),
        ],
        onClose: () {
          int lixosNoInventario = 0;
          try {
            final slot = player.inventory.firstWhere(
              (s) => s.tipo == 'trash_item',
            );
            lixosNoInventario = slot.quantidade;
          } catch (_) {}

          final novaQuest = QuestModel(
            id: 'tutorial_lixo',
            title: 'Limpeza da Cidade',
            description: 'Recolha 5 lixos.',
            targetAmount:
                2, // deixar 2 apenas para teste /// para o jogo ficara 5
            currentAmount: lixosNoInventario,
            status: QuestStatus.active,
          );

          if (novaQuest.currentAmount >= novaQuest.targetAmount) {
            novaQuest.currentAmount = novaQuest.targetAmount;
            novaQuest.status = QuestStatus.ready;
          }

          gameSession.currentState!.activeQuests.add(novaQuest);

          _showSnack(context, "Nova Missão: Limpeza da Cidade!");
        },
      );
      return true;
    }

    if (quest.status == QuestStatus.ready) {
      TalkDialog.show(
        context,
        [
          _say(
            "Prefeito",
            "Incrível! Você recolheu todo o lixo.",
            portrait,
            occupation,
          ),
          _say(
            "Prefeito",
            "Uma dica valiosa: De agora em diante, tente jogar o lixo nas lixeiras de Reciclagem.",
            portrait,
            occupation,
          ),
          _say(
            "Prefeito",
            "A reciclagem tem muito mais bônus do que as lixeiras comuns!",
            portrait,
            occupation,
          ),
          _say(
            "Prefeito",
            "Agora, para dar início à sua fazenda, procure pela Clara.",
            portrait,
            occupation,
          ),
          _say(
            "Prefeito",
            "Ela entende tudo de plantações e vai te ajudar com as sementes.",
            portrait,
            occupation,
          ),
        ],
        onClose: () {
          player.dinheiro += 50;
          player.ganharReputacao(20);

          quest.status = QuestStatus.finished;

          _showSnack(
            context,
            "Missão Completa! +50 Moedas",
            color: Colors.green,
          );
        },
      );
      return true;
    }

    if (quest.status == QuestStatus.active) {
      TalkDialog.show(context, [
        _say(
          "Prefeito",
          "Progresso: ${quest.currentAmount}/${quest.targetAmount} lixos recolhidos.",
          portrait,
          occupation,
        ),
      ]);
      return true;
    }

    if (quest.status == QuestStatus.finished) {
      final String tag = 'prefeito_agradeceu_lixo';
      if (!gameSession.currentState!.interactedNpcs.contains(tag)) {
        TalkDialog.show(
          context,
          [
            _say(
              "Prefeito",
              "A cidade está muito mais limpa graças a você!",
              portrait,
              occupation,
            ),
          ],
          onClose: () {
            gameSession.currentState!.interactedNpcs.add(tag);
          },
        );
        return true;
      }
      return false;
    }

    return false;
  }

  static bool _handleClaraQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    if (gameSession.currentState == null) return false;

    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Clara",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
        _say(
          "Clara",
          "Fale com ele antes de começarmos a plantar.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    final questPlantio = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'capitulo_1_plantio',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questPlantio.id.isEmpty) {
      TalkDialog.show(
        context,
        [
          _say(
            "Clara",
            "Olá! Vejo que você já ajudou na limpeza. Muito bem!",
            portrait,
            occupation,
          ),
          _say(
            "Clara",
            "Ouvi dizer tambem que você quer começar a plantar na fazenda.",
            portrait,
            occupation,
          ),
          _say(
            "Clara",
            "Sua avó deixou algumas sementes de cebolinha para você.",
            portrait,
            occupation,
          ),
          _say(
            "Clara",
            "Plante-as para começar sua jornada como fazendeiro!",
            portrait,
            occupation,
          ),
        ],
        onClose: () {
          final novaQuest = QuestModel(
            id: 'capitulo_1_plantio',
            title: 'O Início da Fazenda',
            description: 'Plante suas primeiras sementes de cebolinha.',
            targetAmount: 5,
            currentAmount: 0,
            status: QuestStatus.active,
          );
          player.adicionarItem('springOnion_seed', quantidade: 5);
          gameSession.currentState!.activeQuests.add(novaQuest);

          _showSnack(context, "Nova Missão: O Início da Fazenda!");
        },
      );
      return true;
    }

    if (questPlantio.status == QuestStatus.ready) {
      TalkDialog.show(
        context,
        [
          _say(
            "Clara",
            "Perfeito! Essas cebolinhas estão com uma cara ótima.",
            portrait,
            occupation,
          ),
          _say(
            "Clara",
            "Você tem talento. Vá falar com o Carlos que ele compra suas colheitas.",
            portrait,
            occupation,
          ),
          _say(
            "Clara",
            "E além disso, vou avisar o Carlos para liberar a venda de outras sementes para você.",
            portrait,
            occupation,
          ),
        ],
        onClose: () {
          questPlantio.status = QuestStatus.finished;

          player.dinheiro += 20;
          player.ganharReputacao(5);

          _showSnack(
            context,
            "Capítulo 1 Concluído! +20 Moedas",
            color: Colors.green,
          );
        },
      );
      return true;
    }

    if (questPlantio.status == QuestStatus.active) {
      TalkDialog.show(context, [
        _say(
          "Clara",
          "Não esqueça de regar suas plantas todos os dias!",
          portrait,
          occupation,
        ),
        _say(
          "Clara",
          "Colhidas: ${questPlantio.currentAmount}/${questPlantio.targetAmount} Cebolinhas.",
          portrait,
          occupation,
        ),
      ]);
      return true;
    }

    if (questPlantio.status == QuestStatus.finished) {
      // sem dialogo para quando ja esta finalizada, apenas fala as falas padroes
      return false;
    }

    return false;
  }

  static bool _handleCarlosQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Carlos",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    return false;
  }

  static bool _handleGabrielQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Gabriel",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    return false;
  }

  static bool _handleTainaQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Taina",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    return false;
  }

  static bool _handleBiancaQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Bianca",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    return false;
  }

  static bool _handleVioletaQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Violeta",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    return false;
  }

  static bool _handleDrLucasQuest(
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    final questLixo = gameSession.currentState!.activeQuests.firstWhere(
      (q) => q.id == 'tutorial_lixo',
      orElse: () => QuestModel(id: '', title: '', description: ''),
    );

    if (questLixo.status != QuestStatus.finished) {
      TalkDialog.show(context, [
        _say(
          "Dr. Lucas",
          "Olá! Ouvi dizer que o Prefeito está precisando de ajuda.",
          portrait,
          occupation,
        ),
      ]);
      return true; // Bloqueia o diálogo padrão para forçar o tutorial
    }

    return false;
  }

  static bool _handleDynamicQuest(
    String npcName,
    BuildContext context,
    HumanPlayer player,
    Sprite? portrait,
    String occupation,
  ) {
    if (gameSession.currentState == null) return false;

    // Procura missão ativa para este NPC específico
    final quests = gameSession.currentState!.activeQuests
        .where(
          (q) =>
              q.npcName == npcName &&
              (q.status == QuestStatus.active || q.status == QuestStatus.ready),
        )
        .toList();

    if (quests.isEmpty) return false;

    final quest = quests.first;

    int qtdItem = 0;
    if (quest.targetItem != null) {
      try {
        final slot = player.inventory.firstWhere(
          (s) => s.tipo == quest.targetItem,
          orElse: () => InventorySlot(),
        );
        qtdItem = slot.quantidade;
      } catch (_) {
        qtdItem = 0;
      }
    }

    bool canComplete = qtdItem >= quest.targetAmount;

    if (quest.status == QuestStatus.ready || canComplete) {
      TalkDialog.show(
        context,
        [_say(npcName, quest.rewardText, portrait, occupation)],
        onClose: () {
          if (quest.targetItem != null) {
            player.removerItemPorTipo(quest.targetItem!, quest.targetAmount);
          }

          player.dinheiro += quest.targetAmount * 10;
          player.ganharReputacao(15);

          quest.status = QuestStatus.finished;

          _showSnack(
            context,
            "Missão Secundaria Concluída!",
            color: Colors.green,
          );
        },
      );
      return true;
    } else {
      final displayName =
          _displayNames[quest.targetItem?.replaceAll('_item', '') ?? ''] ??
          quest.targetItem ??
          'item';

      TalkDialog.show(context, [
        _say(npcName, quest.description, portrait, occupation),

        _say(
          npcName,
          "Preciso de ${quest.targetAmount} $displayName(s). Você tem $qtdItem",
          portrait,
          occupation,
        ),
      ]);
      return true;
    }
  }

  static Say _say(
    String person,
    String text,
    Sprite? portrait,
    String occupation,
  ) {
    return Say(
      text: [
        if (occupation.isNotEmpty)
          TextSpan(
            text: "$person ($occupation): $text",
            style: const TextStyle(color: Colors.white),
          )
        else
          TextSpan(
            text: "$person: $text",
            style: const TextStyle(color: Colors.white),
          ),
      ],
      person: SizedBox(
        width: 100,
        height: 100,
        child: portrait != null
            ? SpriteWidget(sprite: portrait)
            : Container(color: Colors.black),
      ),
      personSayDirection: PersonSayDirection.LEFT,
    );
  }

  static void _showSnack(
    BuildContext context,
    String text, {
    Color color = Colors.blue,
  }) {
    Future.delayed(Duration.zero, () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text, textAlign: TextAlign.center),
          backgroundColor: color.withValues(alpha: 0.8),
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    });
  }
}
