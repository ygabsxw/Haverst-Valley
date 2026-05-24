import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/AnimalManager.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/data/crops_data.dart';
import 'package:harvest_valley/data/quest_manager.dart';
import 'package:harvest_valley/npc/animal_sprite_sheet.dart';
import 'dart:math';
import 'dart:convert';
import 'package:harvest_valley/services/GeminiService.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/npc/npc_sprite_sheet.dart';

enum NpcBehavior {
  idle, // parado
  wander, // vagando aleatoriamente
}

enum WalkAxis { horizontal, vertical }

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

enum ReputationLevel {
  bad, //0-39
  neutral, //40-79
  good, //80-100
}

class NPC extends SimpleEnemy with TapGesture, BlockMovementCollision {
  final String name;
  final String occupation;
  final Map<ReputationLevel, List<String>> dialogues;
  final NpcBehavior behavior;
  final double wanderArea; // area em que o NPC irá se movimentar
  final String aiTheme;

  double waitTime = 0; // quanto tempo ainda deve esperar
  final double maxWait = 3; // tempo máximo parado em segundos
  WalkAxis? _axisAtual; // eixo travado para o alvo atual
  Direction? _dirAtual; // direção atual (para evitar reconfigurar a cada frame)

  bool _colidiu = false;
  late double minX, maxX, minY, maxY; // limites da área de movimento

  Vector2? _target;
  final Random _rng = Random();
  final GeminiService _gemini = GeminiService();

  bool _isTalking = false;

  String? _proximaFalaDaIA;
  bool _estaPensando = false;

  final NpcSpritesheet spriteSheet;
  Sprite? _portraitSprite;

  bool get isGamePaused => gameRef.paused;

  NPC({
    required super.position,
    required super.size,
    required this.spriteSheet,
    required SimpleDirectionAnimation super.animation,
    required this.name,
    required this.occupation,
    required this.dialogues,
    this.behavior = NpcBehavior.idle,
    double super.speed = 25,
    this.wanderArea = 400,
    Direction lookDirection = Direction.down,
    required this.aiTheme,
  }) : super(initDirection: lookDirection);

  ReputationLevel _getReputationLevel(HumanPlayer player) {
    if (player.reputacao >= 80) {
      return ReputationLevel.good;
    } else if (player.reputacao >= 40) {
      // 40 a 79
      return ReputationLevel.neutral;
    } else {
      // 0 a 39
      return ReputationLevel.bad;
    }
  }

  @override
  void update(double dt) {
    if (behavior == NpcBehavior.wander && !_isTalking) {
      _wander(dt);
    }
    super.update(dt);
  }

  // --- LÓGICA DE MOVIMENTO ---

  void _pararEModularEspera() {
    stopMove();
    idle();
    _target = null;
    _axisAtual = null;
    _dirAtual = null;
    waitTime = _rng.nextDouble() * maxWait;
  }

  void _wander(double dt) {
    if (waitTime > 0) {
      waitTime -= dt;
      idle();
      return;
    }

    if (_colidiu) {
      _colidiu = false;
      _pararEModularEspera();
      return;
    }

    if (_target == null) {
      _escolherNovoDestino();
    }

    if (_target == null) {
      idle();
      return;
    }

    if (_axisAtual == WalkAxis.horizontal) {
      final dx = _target!.x - position.x;
      if (dx.abs() <= 1) {
        _pararEModularEspera();
        return;
      }
      _andarNaDirecao(dx > 0 ? Direction.right : Direction.left);
    } else {
      final dy = _target!.y - position.y;
      if (dy.abs() <= 1) {
        _pararEModularEspera();
        return;
      }
      _andarNaDirecao(dy > 0 ? Direction.down : Direction.up);
    }
  }

  void _escolherNovoDestino() {
    final bool escolheHorizontal = _rng.nextBool();
    _axisAtual = escolheHorizontal ? WalkAxis.horizontal : WalkAxis.vertical;

    if (_axisAtual == WalkAxis.horizontal) {
      final double destinoX = _rng.nextDouble() * (maxX - minX) + minX;
      _target = Vector2(destinoX, position.y);
      _dirAtual = destinoX > position.x ? Direction.right : Direction.left;
    } else {
      final double destinoY = _rng.nextDouble() * (maxY - minY) + minY;
      _target = Vector2(position.x, destinoY);
      _dirAtual = destinoY > position.y ? Direction.down : Direction.up;
    }
  }

  void _andarNaDirecao(Direction dir) {
    if (_dirAtual != dir) {
      _dirAtual = dir;
    }
    switch (dir) {
      case Direction.right:
        moveRight();
        break;
      case Direction.left:
        moveLeft();
        break;
      case Direction.up:
        moveUp();
        break;
      case Direction.down:
        moveDown();
        break;
      default:
        break;
    }
  }

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    _colidiu = true;
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(
      RectangleHitbox(
        size: size / 2,
        position: size / 4,
        collisionType: CollisionType.active,
      ),
    );

    final spriteAnim = await spriteSheet.idleDown;
    _portraitSprite = spriteAnim.frames.first.sprite;

    _buscarNovaFalaDaIA();

    final half = wanderArea / 2;
    minX = position.x - half;
    maxX = position.x + half;
    minY = position.y - half;
    maxY = position.y + half;
  }

  Future<void> _buscarNovaFalaDaIA() async {
    if (_estaPensando) return;
    _estaPensando = true;

    try {
      final player = gameRef.player;
      List<String> currentList = [];
      if (player is HumanPlayer) {
        ReputationLevel rep = _getReputationLevel(player);
        currentList = dialogues[rep] ?? dialogues[ReputationLevel.neutral]!;
      } else {
        currentList = dialogues[ReputationLevel.neutral]!;
      }
      final String dialogueContext = currentList.join(" ");
      final String prompt =
          "Você é um NPC em um jogo de fazenda. Seu nome é $name e ocupacao $occupation. "
          "A reputação do jogador com você é ${player is HumanPlayer ? player.reputacao : 'desconhecida'}. "
          "Suas falas normais são: '$dialogueContext'. "
          "Seu interesse atual é: '$aiTheme'. "
          "Gere uma nova fala curta (1-2 frases) que soe como uma continuação natural. "
          "Não se apresente novamente."
          "IMPORTANTE: Responda APENAS o texto da fala. NÃO use JSON, NÃO use aspas.";

      String generatedLine = await _gemini.generateDialogue(prompt);

      if (generatedLine.trim().isNotEmpty) {
        _proximaFalaDaIA = generatedLine;
      } else {
        _proximaFalaDaIA = "Hmm... esqueci o que ia dizer.";
      }
    } catch (e) {
      print("Erro ao buscar diálogo IA: $e");
      _proximaFalaDaIA = null;
    } finally {
      _estaPensando = false;
    }
  }

  /// Filtra e adiciona falas baseadas no inventário do jogador
  List<String> _getRelevantDialogues() {
    final player = gameRef.player;

    // Se não for player humano, retorna lista neutra padrão
    if (player is! HumanPlayer) return dialogues[ReputationLevel.neutral]!;
    List<String> specialDialogues = [];

    bool hasTrash = player.inventory.any((slot) => slot.tipo == 'trash_item');

    if (hasTrash) {
      switch (name) {
        case "Prefeito":
          specialDialogues.add(
            "Vejo que recolheu lixo! Leve para a reciclagem, por favor.",
          );
          break;
        case "Gabriel":
          specialDialogues.add("Boa, tirou esse lixo da rua! O mar agradece.");
          break;
        case "Taina India":
          specialDialogues.add(
            "O lixo atrapalha a natureza. Obrigada por ajudar!",
          );
          break;
        case "Bianca":
          specialDialogues.add(
            "Eca, lixo! Por favor, jogue isso na lixeira adequada.",
          );
          break;
      }
    }

    if (name == "Clara") {
      final claraResponses = {
        'strawberry_item':
            "Oh, morangos! Eles são meus favoritos! Tão doces e vermelhos...",
        'potato_item':
            "Batatas! Tão versáteis. Você pode cozinhar, amassar, fritar...",
        'garlic_item':
            "Isso é alho? É ótimo para temperar, mas o cheiro fica nos dedos...",
        'springOnion_item':
            "Cebolinhas! Elas dão um toque especial em sopas e saladas...",
        'wheat_item': "Trigo! O alimento dos animais! Eles vão adorar isso.",
      };

      for (var entry in claraResponses.entries) {
        if (player.inventory.any((s) => s.tipo == entry.key)) {
          specialDialogues.add(entry.value);
        }
      }
    }

    const cropsList = [
      'strawberry',
      'potato',
      'garlic',
      'springOnion',
      'wheat',
    ];
    bool hasCrops = player.inventory.any(
      (slot) => cropsList.contains(slot.tipo?.replaceAll('_item', '')),
    );

    if (hasCrops && name.contains("Carlos")) {
      specialDialogues.add(
        "Vegetais frescos! Fale comigo de novo para vendê-los.",
      );
    }

    if (specialDialogues.isNotEmpty) {
      return specialDialogues;
    }

    ReputationLevel rep = _getReputationLevel(player);
    return dialogues[rep] ?? dialogues[ReputationLevel.neutral]!;
  }

  void _mostrarMenuInteracao(
    BuildContext context,
    HumanPlayer player, {
    String? hint,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Column(
            children: [
              Text("Conversar com $name"),
              if (hint != null) ...[
                const SizedBox(height: 8),
                Text(
                  hint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.deepOrange,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // OPÇÃO 1: LOJA
              if (name.contains("Carlos"))
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.brown),
                  title: const Text("Ver Sementes"),
                  onTap: () {
                    Navigator.pop(context); // Fecha o menu
                    _mostrarFalaEspecifica(2, () {
                      _abrirLojaDeSementes(gameRef.context, player);
                    });
                  },
                ),
              if (name.contains("Clara"))
                ListTile(
                  leading: const Icon(Icons.store, color: Colors.brown),
                  title: const Text("Ver Animais"),
                  onTap: () {
                    Navigator.pop(context); // Fecha o menu
                    _mostrarFalaEspecifica(2, () {
                      _abrirLojaDeAnimais(gameRef.context, player);
                    });
                  },
                ),
              const Divider(color: Colors.black),

              // OPÇÃO 2: CONVERSAR
              ListTile(
                leading: const Icon(Icons.chat_bubble, color: Colors.blue),
                title: const Text("Bater papo"),
                onTap: () {
                  Navigator.pop(context); // Fecha o menu
                  bool teveMissao = QuestManager.checkInteraction(
                    name,
                    gameRef.context,
                    player,
                    () {
                      _isTalking = false;
                    },
                    portrait: _portraitSprite,
                    occupation: occupation,
                  );
                  // Inicia a lógica de frases aleatórias/IA
                  if (!teveMissao) {
                    _iniciarConversaAleatoria();
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _isTalking = false; // Libera o NPC se cancelar
              },
              child: const Text("Sair", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    ).then((_) {
      // Se o menu fechar sem escolher nada (clicar fora), libera o NPC
      if (_isTalking) _isTalking = false;
    });
  }

  void _iniciarConversaAleatoria() {
    final currentContext = gameRef.context;
    final relevantDialogues = _getRelevantDialogues();

    final randomLine =
        relevantDialogues[_rng.nextInt(relevantDialogues.length)];

    List<Say> falasParaMostrar = [_createSay(randomLine)];

    if (_proximaFalaDaIA != null) {
      falasParaMostrar.add(_createSay(_proximaFalaDaIA!));
      _proximaFalaDaIA = null;
      _buscarNovaFalaDaIA();
    } else if (!_estaPensando) {
      _buscarNovaFalaDaIA();
    }

    TalkDialog.show(
      currentContext,
      falasParaMostrar,
      onClose: () => _isTalking = false,
    );
  }

  @override
  void onTap() {
    if (isGamePaused || !gameRef.context.mounted) return;

    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    // Verifica distância
    final double distancia = player.center.distanceTo(center);
    if (distancia > 32) return;

    // Para player e NPC
    player.stopMove();
    player.idle();
    _isTalking = true;
    stopMove();
    idle();
    _target = null;
    _axisAtual = null;
    _dirAtual = null;
    lookToPlayer();

    // ve se tem missao
    bool deveChecarMissaoAgora = true;
    // se for carlos ou clara (vendedores) voce consegue abrir menu de compra tambem
    bool isShopOwner = name.contains("Carlos") || name.contains("Clara");
    String? dicaMissao;

    if (isShopOwner && gameSession.currentState != null) {
      final questAtiva = gameSession.currentState!.activeQuests.firstWhere(
        (q) => q.npcName == name && q.status != QuestStatus.finished,
        orElse: () => QuestModel(id: '', title: '', description: ''),
      );

      if (questAtiva.id.isNotEmpty) {
        int qtdNoInventario = 0;
        if (questAtiva.targetItem != null) {
          try {
            final slot = player.inventory.firstWhere(
              (s) => s.tipo == questAtiva.targetItem,
              orElse: () => InventorySlot(),
            );
            qtdNoInventario = slot.quantidade;
          } catch (_) {}
        }

        // Se não tem itens suficientes e a missão não está pronta para entrega
        if (questAtiva.status != QuestStatus.ready &&
            qtdNoInventario < questAtiva.targetAmount) {
          deveChecarMissaoAgora =
              false; // Pula a checagem de missão para abrir a loja

          if (questAtiva.targetItem != null) {
            dicaMissao = _getDicaDeCompra(questAtiva.targetItem!);
          }
        }
      }
    }

    if (deveChecarMissaoAgora) {
      bool teveMissao = QuestManager.checkInteraction(
        name,
        gameRef.context,
        player,
        () {
          _isTalking = false;
        },
        portrait: _portraitSprite,
        occupation: occupation,
      );

      if (teveMissao) {
        Future.delayed(const Duration(seconds: 1), () {});
        return;
      }
    }

    final slot = player.slotAtivo;
    bool isMerchant = name.contains("Carlos");
    bool isMerchantAnimal = name.contains("Clara");

    // Lógica de Venda
    if (isMerchant && slot != null && (slot.tipo?.endsWith('_item') ?? false)) {
      _mostrarFalaEspecifica(3, () {
        String itemType = slot.tipo!.replaceFirst('_item', '');
        _trySellItens(player, slot, itemType);
      });
      return;
    }
    // Lógica de Mãos Vazias
    else if (slot != null && slot.isEmpty) {
      TalkDialog.show(gameRef.context, [
        _createSay("Você está com as mãos vazias! Não tenho interesse nisso."),
      ], onClose: () => _isTalking = false);
      return;
    }
    // Lógica de Item Invalido / Lixo
    else if (slot != null && !slot.isEmpty) {
      String itemType;
      if (slot.tipo!.endsWith('_seed')) {
        itemType = slot.tipo!.replaceFirst('_seed', '');
      } else {
        itemType = slot.tipo!.replaceFirst('_item', '');
      }

      String displayName = _displayNames[itemType] ?? itemType;

      if (itemType == 'trash') {
        TalkDialog.show(gameRef.context, [
          _createSay(
            "Que nojo! Jogue esse lixo fora! Não quero nada com isso.",
          ),
        ], onClose: () => _isTalking = false);
        player.perderReputacao(15);
        return;
      }

      TalkDialog.show(gameRef.context, [
        _createSay("Desculpe, não estou interessado em comprar $displayName."),
      ], onClose: () => _isTalking = false);
      return;
    }

    if (isMerchant && slot == null) {
      _mostrarMenuInteracao(gameRef.context, player, hint: dicaMissao);
      return;
    } else if (isMerchantAnimal && slot == null) {
      _mostrarMenuInteracao(gameRef.context, player, hint: dicaMissao);
      return;
    }

    _getRelevantDialogues();
    _iniciarConversaAleatoria();
  }

  String? _getDicaDeCompra(String targetItem) {
    // --- Lógica para CLARA (Animais) ---
    if (targetItem == 'eggBig_item') {
      return "Dica: Para conseguir Ovos Grandes, você talvez precise de uma Galinha.";
    }
    if (targetItem == 'egg_item') {
      return "Dica: Para conseguir Ovos, você talvez precise de um Pintinho.";
    }
    if (targetItem == 'wool_item') {
      return "Dica: Para conseguir Lã, você talvez precise de uma Ovelha.";
    }
    if (targetItem == 'milkGoat_item') {
      return "Dica: Para conseguir Leite de Cabra, você talvez precise de uma Cabra.";
    }
    if (targetItem == 'milkBig_item') {
      return "Dica: Para conseguir Leite Grande, você talvez precise de uma Vaca.";
    }
    if (targetItem == 'milk_item') {
      return "Dica: Para conseguir Leite, você talvez precise de um Bezerro.";
    }

    // --- Lógica para CARLOS (Sementes) ---
    String cropName = targetItem.replaceAll('_item', '');

    if (_displayNames.containsKey(cropName)) {
      return "Dica: Você talvez precise de sementes de ${_displayNames[cropName]}.";
    }

    return "Dica: Veja se tenho algo na loja que ajude.";
  }

  void _mostrarFalaEspecifica(int index, VoidCallback onFinish) {
    final player = gameRef.player;
    final ReputationLevel rep = player is HumanPlayer
        ? _getReputationLevel(player)
        : ReputationLevel.neutral;
    final List<String> currentDialogueList =
        dialogues[rep] ?? dialogues[ReputationLevel.neutral]!;

    String fala = (index >= 0 && index < currentDialogueList.length)
        ? currentDialogueList[index]
        : currentDialogueList.isNotEmpty
        ? currentDialogueList[0]
        : "...";

    TalkDialog.show(
      gameRef.context,
      [_createSay(fala)],
      onClose: () {
        _isTalking = false;
        Future.delayed(Duration.zero, () {
          onFinish();
        });
      },
    );
  }

  void _trySellItens(HumanPlayer player, InventorySlot slot, String itemType) {
    _isTalking = true;
    idle();

    int price = 0;
    int repPerUnit = 0;
    bool isInterested = false;

    if (CropConfig.data.containsKey(itemType)) {
      final config = CropConfig.data[itemType]!;
      price = config.getDynamicSellPrice(player.reputacao);
      AudioManager().playSfx("money.mp3");
      repPerUnit = config.reputationGain;
      isInterested = true;
    } else {
      try {
        final animalConfig = AnimalConfig.data.values.firstWhere(
          (config) => config.productItem == itemType,
        );

        price = animalConfig.getDynamicProductPrice(player.reputacao);
        repPerUnit = animalConfig.reputationGain;
        isInterested = true;
      } catch (e) {
        isInterested = false;
      }
    }

    String message;

    String displayName = _displayNames[itemType] ?? itemType;

    if (isInterested && price > 0) {
      int total = price * slot.quantidade;
      int totalReputation = repPerUnit * slot.quantidade;

      player.dinheiro += total;
      player.removerItemSelecionado(quantidade: slot.quantidade);
      if (!player.vendeuHoje) {
        player.registrarVenda();
      }
      player.ganharReputacao(totalReputation);

      if (player.reputacao >= 80) {
        message =
            "Como é você, vou pagar muito bem! $total moedas por ${slot.quantidade} $displayName.";
      } else if (player.reputacao < 40) {
        message =
            "A qualidade dos seus produtos não me agrada. Dou $total moedas por ${slot.quantidade} $displayName.";
      } else {
        message =
            "Obrigado! Aqui estão $total moedas por ${slot.quantidade} $displayName.";
      }
    } else {
      message =
          "Desculpe, não tenho interesse em comprar $displayName no momento.";
    }

    TalkDialog.show(
      gameRef.context,
      [_createSay(message)],
      onClose: () {
        _isTalking = false;
      },
    );
  }

  Say _createSay(String line) {
    return Say(
      text: [
        if (occupation.isNotEmpty)
          TextSpan(
            text: "$name ($occupation): $line",
            style: const TextStyle(color: Colors.white),
          )
        else
          TextSpan(
            text: "$name: $line",
            style: const TextStyle(color: Colors.white),
          ),
      ],
      person: SizedBox(
        width: 100,
        height: 100,
        child: _portraitSprite != null
            ? SpriteWidget(sprite: _portraitSprite!)
            : Container(color: Colors.black),
      ),
      personSayDirection: PersonSayDirection.LEFT,
    );
  }

  void lookToPlayer() {
    final player = gameRef.player;
    if (player == null) return;
    final diff = player.center - center;
    if (diff.x.abs() > diff.y.abs()) {
      lastDirection = diff.x > 0 ? Direction.right : Direction.left;
    } else {
      lastDirection = diff.y > 0 ? Direction.down : Direction.up;
    }
  }

  //loja de comprar semente
  void _abrirLojaDeSementes(BuildContext context, HumanPlayer player) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(
              color: Colors.brown,
              width: 2,
            ), // Borda rústica
          ),
          title: Text("Armazém do $name"),
          content: SizedBox(
            width: size.width * 0.6,
            height: size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      _buildShopItem(
                        context,
                        player,
                        "Semente de Morango",
                        "strawberry_seed",
                        CropConfig.data['strawberry']!,
                      ),
                      _buildShopItem(
                        context,
                        player,
                        "Semente de Batata",
                        "potato_seed",
                        CropConfig.data['potato']!,
                      ),
                      _buildShopItem(
                        context,
                        player,
                        "Semente de Alho",
                        "garlic_seed",
                        CropConfig.data['garlic']!,
                      ),
                      _buildShopItem(
                        context,
                        player,
                        "Semente de Cebolinha",
                        "springOnion_seed",
                        CropConfig.data['springOnion']!,
                      ),
                      _buildShopItem(
                        context,
                        player,
                        "Semente de Trigo",
                        "wheat_seed",
                        CropConfig.data['wheat']!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Sair", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShopItem(
    BuildContext context,
    HumanPlayer player,
    String nome,
    String itemId,
    CropConfig config,
  ) {
    int precoFinal = config.getDynamicSeedPrice(player.reputacao);
    int precoOriginal = config.seedPrice;
    bool temDesconto = precoFinal < precoOriginal;
    bool taCaro = precoFinal > precoOriginal;

    return StatefulBuilder(
      builder: (context, setState) {
        final bool podeComprar = player.dinheiro >= precoFinal;
        Sprite? spriteDoItem = SpriteManager.itemSprites[itemId];
        return ListTile(
          leading: SizedBox(
            width: 32, // Tamanho visual no menu (zoom)
            height: 32,
            child: spriteDoItem != null
                ? SpriteWidget(sprite: spriteDoItem)
                : const Icon(
                    Icons.help_outline,
                    color: Colors.red,
                  ), // Fallback se não achar
          ),
          title: Text(nome),
          subtitle: Row(
            children: [
              Text("$precoFinal moedas"),
              if (temDesconto)
                const Text(
                  "(Promoção!)",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              if (taCaro)
                const Text(
                  "(Taxa alta)",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: podeComprar
                ? () {
                    if (player.adicionarItem(itemId, quantidade: 1)) {
                      setState(() {
                        player.dinheiro -= precoFinal;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Comprou 1 $nome"),
                          duration: const Duration(milliseconds: 500),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Inventário Cheio!")),
                      );
                    }
                  }
                : null,
            child: const Text("Comprar"),
          ),
        );
      },
    );
  }

  //loja de comprar animal
  void _abrirLojaDeAnimais(BuildContext context, HumanPlayer player) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final size = MediaQuery.of(context).size;
        return AlertDialog(
          backgroundColor: const Color.fromARGB(
            255,
            255,
            255,
            255,
          ).withValues(alpha: 0.9),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Colors.brown, width: 2),
          ),
          title: Text("Curral da $name"),
          content: SizedBox(
            width: size.width * 0.6,
            height: size.height * 0.3,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Pintinho
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Pintinho",
                        "pintinho",
                        "animals/chicken_chick.png",
                        AnimalConfig.data['pintinho']!,
                        16.0,
                      ),

                      // Galinha
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Galinha",
                        "galinha",
                        "animals/chicken_hen.png",
                        AnimalConfig.data['galinha']!,
                        16.0,
                      ),

                      // Bezerros
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Bezerro Marrom",
                        "bezerro_marrom",
                        "animals/calf_brown.png",
                        AnimalConfig.data['bezerro']!,
                        16.0,
                      ),
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Bezerro Branco",
                        "bezerro_branco",
                        "animals/calf_white.png",
                        AnimalConfig.data['bezerro']!,
                        16.0,
                      ),
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Bezerro Malhado",
                        "bezerro_malhado",
                        "animals/calf_holstein.png",
                        AnimalConfig.data['bezerro']!,
                        16.0,
                      ),

                      // Vacas
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Vaca Marrom",
                        "vaca_marrom",
                        "animals/cow_brown.png",
                        AnimalConfig.data['vaca']!,
                        24.0,
                      ),
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Vaca Branca",
                        "vaca_branca",
                        "animals/cow_white.png",
                        AnimalConfig.data['vaca']!,
                        24.0,
                      ),
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Vaca Malhada",
                        "vaca_malhada",
                        "animals/cow_holstein.png",
                        AnimalConfig.data['vaca']!,
                        24.0,
                      ),

                      // Cabra
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Cabra",
                        "cabra",
                        "animals/goat.png",
                        AnimalConfig.data['cabra']!,
                        16.0,
                      ),

                      // Ovelha
                      _buildAnimalShopItem(
                        context,
                        player,
                        "Ovelha",
                        "ovelha",
                        "animals/sheep.png",
                        AnimalConfig.data['ovelha']!,
                        16.0,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Sair", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAnimalShopItem(
    BuildContext context,
    HumanPlayer player,
    String nome,
    String animalId,
    String assetPath,
    AnimalConfig config,
    double tamanhoSprite,
  ) {
    int precoFinal = config.getDynamicPurchasePrice(player.reputacao);
    int precoOriginal = config.purchasePrice;
    bool temDesconto = precoFinal < precoOriginal;
    bool taCaro = precoFinal > precoOriginal;

    return StatefulBuilder(
      builder: (context, setState) {
        final bool podeComprar = player.dinheiro >= precoFinal;
        return ListTile(
          leading: SizedBox(
            width: 48,
            height: 48,
            child: FutureBuilder<SpriteAnimation>(
              future: AnimalSpritesheet(
                path: assetPath,
                frameSize: Vector2.all(tamanhoSprite),
              ).idleDown,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  return SpriteWidget(
                    sprite: snapshot.data!.frames.first.sprite,
                  );
                } else {
                  return const CircularProgressIndicator(strokeWidth: 2);
                }
              },
            ),
          ),
          title: Text(nome),
          subtitle: Row(
            children: [
              Text("$precoFinal moedas"),
              if (temDesconto)
                const Text(
                  "(Promoção!)",
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              if (taCaro)
                const Text(
                  "(Taxa alta)",
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: podeComprar
                ? () {
                    setState(() {
                      player.dinheiro -= precoFinal;
                    });

                    String specieKey = animalId;
                    String newId =
                        "${specieKey}_${DateTime.now().millisecondsSinceEpoch}";

                    final newAnimalState = AnimalRuntimeState(
                      id: newId,
                      specie: specieKey,
                      currentStateIndex: 0, // Nasce com fome (hungry)
                      productionTimer: 0,
                      x: 0,
                      y: 0,
                    );

                    AnimalManager.instance.updateAnimalState(
                      newId,
                      newAnimalState,
                    );

                    if (gameSession.currentState != null) {
                      gameSession.currentState!.animalStates = AnimalManager
                          .instance
                          .toPersistentStates();
                    }

                    print(
                      "Comprado e registrado no Manager: $newId ($specieKey)",
                    );

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("$nome enviado para a fazenda!"),
                        duration: const Duration(milliseconds: 1000),
                      ),
                    );
                  }
                : null,
            child: const Text("Adotar"),
          ),
        );
      },
    );
  }
}
