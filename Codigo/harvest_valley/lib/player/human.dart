import 'dart:async';
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvest_valley/FarmTile.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/TrashTile.dart';
import 'package:harvest_valley/WorldItem.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/npc/animal.dart';
import 'package:harvest_valley/player/person_sprite_sheet.dart';
import 'package:harvest_valley/player/player_interface.dart';
import 'package:harvest_valley/app/save/game_state.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/services/AI_Quest_Generator.dart';
import 'dart:math';

//classe auxiliar para um slot de inventário
//guarda o tipo do item e a quantidade
class InventorySlot {
  String? tipo;
  int quantidade;

  InventorySlot({this.tipo, this.quantidade = 0});

  bool get isEmpty =>
      tipo == null || quantidade <= 0; //testar se o slot está vazio

  void clear() {
    tipo = null;
    quantidade = 0;
  }
}

class HumanPlayer extends SimplePlayer with BlockMovementCollision, TapGesture {
  final List<InventorySlot> slots = List.generate(
    4,
    (_) => InventorySlot(),
  ); //4 slots de inventário

  int _reputacao = 50;
  int get reputacao => _reputacao;
  set reputacao(int value) {
    _reputacao = value.clamp(0, 100);
    gameSession.currentState?.reputacao = _reputacao;
    print('Reputação atualizada para: $_reputacao');
  }

  double _walkTimer = 0.0;
  final double _walkInterval = 0.8;
  final Random _rng = Random();


  void _playWalkSound() {
    // lista de sons possíveis (variação aleatória)
    final sons = [
      'walk_1.mp3',
      'walk_2.mp3',
      'walk_3.mp3',
    ];

    String file = sons[_rng.nextInt(sons.length)];
    AudioManager().playSfx(file);
  }


  void ganharReputacao(int valor) {
    reputacao += valor;
    _showReputationChangeNotification(valor, isGain: true);
  }

  // Perdas
  void perderReputacao(int valor) {
    reputacao -= valor;
    _showReputationChangeNotification(valor, isGain: false);
  }

  bool get vendeuHoje => gameSession.currentState?.vendeuHoje ?? false;
  void registrarVenda() {
    if (gameSession.currentState?.vendeuHoje == true) return;
    gameSession.currentState?.vendeuHoje = true;
    ganharReputacao(5);
    print('Venda registrada! Reputação subiu.');
  }

  bool get reciclouHoje => gameSession.currentState?.reciclouHoje ?? false;
  void registrarReciclagem() {
    if (gameSession.currentState?.reciclouHoje == true) return;
    gameSession.currentState?.reciclouHoje = true;
    ganharReputacao(5);
    print('Reciclagem registrada! Reputação subiu.');
  }

  final double _reputationNotificationDuration = 2.0;
  double _reputationNotificationTimer = 0.0;
  String? _reputationNotificationText;
  Color? _reputationNotificationColor;

  String? get reputationNotificationText => _reputationNotificationText;
  Color? get reputationNotificationColor => _reputationNotificationColor;

  void _showReputationChangeNotification(int valor, {required bool isGain}) {
    final String sign = isGain ? "+" : "-";

    _reputationNotificationColor = isGain
        ? Colors.green.withValues(alpha: 0.8)
        : Colors.red.withValues(alpha: 0.8);

    _reputationNotificationText = "$sign$valor REPUTAÇÃO (${reputacao})";

    _reputationNotificationTimer = _reputationNotificationDuration;

    _atualizarReputacaoInterface();
  }

  bool get isGamePaused => gameRef.paused;

  List<InventorySlot> get inventory => slots;

  int? slotSelecionado; //indice do slot de inventário atualmente selecionado

  int _dinheiro = 0; //quantidade de dinheiro do jogador
  int get dinheiro => _dinheiro;

  set dinheiro(int value) {
    _dinheiro = value;

    gameSession.currentState?.money = _dinheiro;

    if (gameRef.interface is PlayerInterface) {
      (gameRef.interface as PlayerInterface).atualizarDinheiro(this);
    }
  }

  final double _segundosPorMinutoJogo =
      1.0; // 1 segundo real = 1 minuto no jogo
  double _contadorTempo = 0.0;
  int _minutoAtualJogo = 360; // Começa às 6:00 AM (6 * 60 = 360)
  final int _minutosPorDia = 1440; // 24 * 60
  int diasPassados = 1;
  int get minutoAtualJogo => _minutoAtualJogo;
  int get totalGameMinutes =>
      (diasPassados - 1) * _minutosPorDia + _minutoAtualJogo;

  final GameState? initialState;

  String get tempoFormatado {
    final int horas = _minutoAtualJogo ~/ 60;
    final int minutos = _minutoAtualJogo % 60;
    return "${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}";
  }

  bool get isDia {
    final int horaAtual = _minutoAtualJogo ~/ 60;
    // É dia das 6:00 AM até 17:59 PM
    return horaAtual >= 6 && horaAtual < 18;
  }

  bool _isInteracting = false;
  bool get isInteracting => _isInteracting;

  void setInteracting(bool value) {
    _isInteracting = value;
    if (value) {
      stopMove();
    }
  }

  HumanPlayer({
    required super.position,
    Direction? initDirection,
    this.initialState,
  }) : super(
         animation: PersonSpritesheet.getAnimation(),
         size: Vector2.all(32),
         speed: 64,
       ) {
    if (initDirection != null) {
      lastDirection = initDirection;
    }

    if (initialState != null) {
      _dinheiro = initialState!.money;
      diasPassados = initialState!.diasPassados;
      _minutoAtualJogo = initialState!.horarioAtual;
      _reputacao = initialState!.reputacao;
      gameSession.currentState?.vendeuHoje = initialState!.vendeuHoje;
      gameSession.currentState?.reciclouHoje = initialState!.reciclouHoje;

      if (initialState!.inventory.isNotEmpty) {
        for (int i = 0; i < slots.length; i++) {
          if (i < initialState!.inventory.length) {
            final savedSlot = initialState!.inventory[i];
            slots[i] = InventorySlot(
              tipo: savedSlot.tipo,
              quantidade: savedSlot.quantidade,
            );
          }
        }
      }
    }
  }

  @override
  Future<void> onLoad() async {
    add(RectangleHitbox(size: size / 2, position: size / 4));

    if (initialState != null) {
      // Sincroniza o Player -> Sessão (e não o contrário)
      gameSession.currentState?.money = _dinheiro;
      gameSession.currentState?.reputacao = _reputacao;
      _syncInventoryToSession();

      // Atualiza a UI com segurança
      Future.delayed(const Duration(milliseconds: 100), () {
        _atualizarInterface();
        _atualizarReputacaoInterface();
        if (gameRef.interface is PlayerInterface) {
          (gameRef.interface as PlayerInterface).atualizarDinheiro(this);
        }
      });
    }

    return super.onLoad();
  }

  void _syncInventoryToSession() {
    gameSession.currentState?.inventory = toSlotStates();
  }

  //sistema de inventário
  void selecionarSlot(int? index) {
    slotSelecionado = index;
  }

  //devolve o slot ativo
  InventorySlot? get slotAtivo {
    if (slotSelecionado != null &&
        slotSelecionado! >= 0 &&
        slotSelecionado! < slots.length) {
      //verificar se o slot selecionado não é "mãos vazias"
      return slots[slotSelecionado!];
    }
    return null;
  }

  ///adiciona item no primeiro slot disponível ou no slot que já contém o mesmo tipo
  bool adicionarItem(String tipo, {int quantidade = 1}) {
    bool adicionado = false;

    //se já existe slot com esse tipo, incrementa a quantidade
    for (final slot in slots) {
      if (slot.tipo == tipo) {
        slot.quantidade += quantidade;
        adicionado = true;
        break;
      }
    }

    //se não existe procura pelo primeiro slot vazio
    if (!adicionado) {
      for (final slot in slots) {
        if (slot.isEmpty) {
          slot.tipo = tipo;
          slot.quantidade = quantidade;
          adicionado = true;
          break;
        }
      }
    }

    //se adicionou atualiza a interface (player_interface) com as informações do item (imagem e quantidade)
    if (adicionado) {
      AudioManager().playSfx("pickup.mp3");
      _atualizarInterface();
      _syncInventoryToSession();
      return true;
    }

    //inventario cheio
    return false;
  }

  ///remove quantidade de um item do slot selecionado
  void removerItemSelecionado({int quantidade = 1}) {
    final slot = slotAtivo;
    if (slot != null && !slot.isEmpty) {
      slot.quantidade -= quantidade;
      if (slot.quantidade <= 0) {
        slot.clear();
      }
      _atualizarInterface();
      _syncInventoryToSession();
    }
  }

  bool removerItemPorTipo(String tipo, int quantidade) {
    final index = slots.indexWhere((s) => s.tipo == tipo);

    if (index == -1) return false;

    final slot = slots[index];

    if (slot.quantidade >= quantidade) {
      slot.quantidade -= quantidade;

      if (slot.quantidade == 0) {
        slot.clear();
      }

      _atualizarInterface();
      _syncInventoryToSession();
      return true;
    }

    return false;
  }

  ///atualizar a interface (player_interface)
  void _atualizarInterface() {
    if (gameRef.interface is PlayerInterface) {
      (gameRef.interface as PlayerInterface).atualizarInventario(this);
    }
  }

  void _atualizarReputacaoInterface() {
    if (gameRef.interface is PlayerInterface) {
      (gameRef.interface as PlayerInterface).atualizarReputacao(this);
    }
  }

  @override
  void onJoystickAction(JoystickActionEvent event) {
    if (isGamePaused || _isInteracting || event.event != ActionEvent.DOWN) {
      return;
    }
    final int id = event.id;

    if (id == PlayerActionType.attackMelee.index ||
        event.id == LogicalKeyboardKey.space) {
      setInteracting(true);
      _playMeleeByDirection();
      Future.delayed(
        const Duration(milliseconds: 600),
      ).then((_) => setInteracting(false));
    } else if (id == PlayerActionType.attackRange.index ||
        event.id == LogicalKeyboardKey.keyZ) {
      setInteracting(true);
      _playRangeByDirection();
      Future.delayed(
        const Duration(milliseconds: 600),
      ).then((_) => setInteracting(false));
    } else if (id == PlayerActionType.hoeAction.index ||
        event.id == LogicalKeyboardKey.keyX) {
      _tryInteractHere().then((success) {
        if (!success) {
          setInteracting(true);
          _playHoeByDirection();
          Future.delayed(
            const Duration(milliseconds: 600),
          ).then((_) => setInteracting(false));
        }
      });
    } else if (id == PlayerActionType.wateringCanAction.index ||
        event.id == LogicalKeyboardKey.keyC) {
      _tryWaterFrontTile().then((success) {
        if (!success) {
          setInteracting(true);
          _playWateringCanDirection();
          Future.delayed(
            const Duration(milliseconds: 1050),
          ).then((_) => setInteracting(false));
        }
      });
    }
    super.onJoystickAction(event);
  }

  void _playMeleeByDirection() {
    switch (lastDirection) {
      case Direction.up:
        animation?.playOnceOther(PersonAttackEnum.meleeUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonAttackEnum.meleeDown);
        break;
      case Direction.left:
        animation?.playOnceOther(PersonAttackEnum.meleeLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonAttackEnum.meleeRight);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonAttackEnum.meleeUpRight);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonAttackEnum.meleeUpLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonAttackEnum.meleeDownRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonAttackEnum.meleeDownLeft);
        break;
    }
  }

  void _playRangeByDirection() {
    final dir = lastDirection;
    switch (dir) {
      case Direction.up:
        animation?.playOnceOther(PersonAttackEnum.rangeUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonAttackEnum.rangeDown);
        break;
      case Direction.left:
        animation?.playOnceOther(PersonAttackEnum.rangeLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonAttackEnum.rangeRight);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonAttackEnum.rangeUpRight);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonAttackEnum.rangeUpLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonAttackEnum.rangeDownRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonAttackEnum.rangeDownLeft);
        break;
    }
  }

  void _playHoeByDirection() {
    switch (lastDirection) {
      case Direction.up:
        animation?.playOnceOther(PersonHoeEnum.hoeUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonHoeEnum.hoeDown);
        break;
      case Direction.left:
        animation?.playOnceOther(PersonHoeEnum.hoeLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonHoeEnum.hoeRight);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonHoeEnum.hoeUpRight);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonHoeEnum.hoeUpLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonHoeEnum.hoeDownRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonHoeEnum.hoeDownLeft);
        break;
    }
  }

  void _playWateringCanDirection() {
    switch (lastDirection) {
      case Direction.up:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanDown);
        break;
      case Direction.left:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanRight);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanRight);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonWateringCanEnum.wateringCanLeft);
        break;
    }
  }

  void _playFaintByDirection() {
    switch (lastDirection) {
      case Direction.up:
        animation?.playOnceOther(PersonFaintEnum.faintUp);
        break;
      case Direction.down:
        animation?.playOnceOther(PersonFaintEnum.faintDown);
        break;
      case Direction.left:
        animation?.playOnceOther(PersonFaintEnum.faintLeft);
        break;
      case Direction.right:
        animation?.playOnceOther(PersonFaintEnum.faintRight);
        break;
      case Direction.upRight:
        animation?.playOnceOther(PersonFaintEnum.faintRight);
        break;
      case Direction.upLeft:
        animation?.playOnceOther(PersonFaintEnum.faintLeft);
        break;
      case Direction.downRight:
        animation?.playOnceOther(PersonFaintEnum.faintRight);
        break;
      case Direction.downLeft:
        animation?.playOnceOther(PersonFaintEnum.faintLeft);
        break;
    }
  }

  Future<bool> _tryInteractHere() async {
    bool didHarvest = await _tryHarvestHere();

    if (didHarvest) {
      return true;
    }

    bool didRemoveTrash = await _tryRemoveTrashHere();

    if (didRemoveTrash) {
      return true;
    }

    bool didPlant = await _tryPlantSeedHere(slotAtivo?.tipo ?? '');

    return didPlant;
  }

  Future<bool> _tryRemoveTrashHere() async {
    if (isGamePaused || _isInteracting) return false;

    final Vector2 targetPoint = position + size / 2;
    final Offset targetOffset = targetPoint.toOffset();

    final trashTiles = gameRef.query<TrashTile>();

    for (final trash in trashTiles) {
      final Rect trashRect = Rect.fromLTWH(
        trash.position.x,
        trash.position.y,
        trash.size.x,
        trash.size.y,
      );

      if (trashRect.contains(targetOffset)) {
        setInteracting(true);

        try {
          _playHoeByDirection();
          AudioManager().playSfx("trash.mp3");
          await Future.delayed(const Duration(milliseconds: 600));

          String? itemCollected = trash.collectTrash();

          if (itemCollected != null) {
            ganharReputacao(1);
            bool addedSuccessfully = adicionarItem(
              itemCollected,
              quantidade: 1,
            );

            if (!addedSuccessfully) {
              WorldItem itemDropped = WorldItem(
                trash.position.clone(),
                itemCollected,
              );
              if (itemCollected == 'trash_item') {
                itemDropped.sprite = SpriteManager.trashItem;
                itemDropped.paint = SpriteManager.greyPaint;
              }
              gameRef.add(itemDropped);
              print('Inventário cheio! $itemCollected dropado no chão.');
            }
          }
          return true;
        } finally {
          setInteracting(false);
        }
      }
    }
    return false;
  }

  Future<bool> _tryHarvestHere() async {
    if (isGamePaused || _isInteracting) return false;

    final Vector2 targetPoint = position + size / 2;
    final Offset targetOffset = targetPoint.toOffset();

    final farmTiles = gameRef.query<FarmTile>();

    for (final farmTile in farmTiles) {
      final Rect farmRect = Rect.fromLTWH(
        farmTile.position.x,
        farmTile.position.y,
        farmTile.size.x,
        farmTile.size.y,
      );

      if (farmRect.contains(targetOffset) &&
          farmTile.myState.cropType != null &&
          farmTile.myState.growthStage >= 5) {
        setInteracting(true);
        try {
          _playHoeByDirection();
          await Future.delayed(const Duration(milliseconds: 600));

          var result = farmTile.harvestPlantation();

          if (result != null && result.isNotEmpty) {
            String itemType = result.keys.first;
            int amount = result.values.first;

            // Tenta adicionar a quantidade total ao inventário
            bool added = adicionarItem(itemType, quantidade: amount);

            if (!added) {
              // Se o inventário encher, dropa no chão
              gameRef.add(WorldItem(farmTile.position.clone(), itemType));
              print('Inventário cheio! Dropado no chão.');
            }
          }
          return true;
        } finally {
          setInteracting(false);
        }
      }
    }
    return false;
  }

  Future<bool> _tryPlantSeedHere(String seedType) async {
    if (isGamePaused || _isInteracting) return false;

    if (!seedType.endsWith('_seed')) {
      return false;
    }

    final Vector2 targetPoint = position + size / 2;
    final Offset targetOffset = targetPoint.toOffset();

    final farmTiles = gameRef.query<FarmTile>();

    for (final farmTile in farmTiles) {
      final Rect farmRect = Rect.fromLTWH(
        farmTile.position.x,
        farmTile.position.y,
        farmTile.size.x,
        farmTile.size.y,
      );

      if (farmRect.contains(targetOffset)) {
        if (farmTile.myState.cropType != null) {
          // Tile já ocupado. Não faz nada.
          return false;
        }
        setInteracting(true);
        try {
          _playHoeByDirection();
          AudioManager().playSfx("dig.mp3");
          await Future.delayed(const Duration(milliseconds: 600));
          bool plantedSuccessfully = farmTile.plantSeed(seedType);
          if (plantedSuccessfully) {
            removerItemSelecionado(quantidade: 1);
            return true;
          } else {
            return false;
          }
        } finally {
          setInteracting(false);
        }
      }
    }
    return false;
  }

  Future<bool> _tryWaterFrontTile() async {
    if (isGamePaused || _isInteracting) return false;

    final Vector2 targetPoint = position + size / 2;
    final Offset targetOffset = targetPoint.toOffset();

    final farmTiles = gameRef.query<FarmTile>();

    for (final farmTile in farmTiles) {
      final Rect farmRect = Rect.fromLTWH(
        farmTile.position.x,
        farmTile.position.y,
        farmTile.size.x,
        farmTile.size.y,
      );

      if (farmRect.contains(targetOffset)) {
        setInteracting(true);
        try {
          _playWateringCanDirection();
          AudioManager().playSfx("watering.mp3");
          await Future.delayed(const Duration(milliseconds: 1050));
          farmTile.waterPlantation();

          return true;
        } finally {
          setInteracting(false);
        }
      }
    }
    return false;
  }

  void _timePassage(int minutesSkipped) {
    if (minutesSkipped <= 0) return;

    print("Simulando passagem de $minutesSkipped minutos no mundo...");

    // procura quais tiles da fazenda existem e verifica quais vao se alterar
    final farmTiles = gameRef.query<FarmTile>();
    for (final tile in farmTiles) {
      tile.processTimeSkip(minutesSkipped);
    }

    // procura quais animais existem e verifica quais vao se alterar
    final animals = gameRef.query<Animal>();
    for (final animal in animals) {
      animal.processTimeSkip(minutesSkipped);
    }
  }

  void _encerrarDia(bool casa) async {
    int decaimento = 0;
    if (_reputacao > 80) {
      decaimento = 5;
    } else if (_reputacao > 40) {
      decaimento = 2;
    }

    if (decaimento > 0) {
      perderReputacao(decaimento);
      print("perdeu um pouco de reputação (-$decaimento Rep).");
    }

    if (!casa) {
      perderReputacao(0);
      print(
        "Dia $diasPassados encerrado. Penalidade de -60 Reputação por dormir na rua.",
      );
    }

    if (gameSession.currentState?.vendeuHoje == false) {
      perderReputacao(0);
      print(
        "Dia $diasPassados encerrado. Penalidade de -50 Reputação por não vender.",
      );
    }
    gameSession.currentState?.vendeuHoje = false;

    if (gameSession.currentState?.reciclouHoje == false) {
      perderReputacao(0);
      print(
        "Dia $diasPassados encerrado. Penalidade de -40 Reputação por não reciclar.",
      );
    }
    gameSession.currentState?.reciclouHoje = false;

    final int missoesEmAndamento = gameSession.currentState!.activeQuests
        .where((q) => q.status != QuestStatus.finished)
        .length;

    // so gera missoes se não tiver nenhuma em andamento
    if (missoesEmAndamento == 0) {
      print("Não há missões ativas. Gerando nova missão com IA...");

      final generator = AiQuestGenerator();
      final novaMissao = await generator.generateDynamicQuest(
        gameSession.currentState!,
      );

      if (novaMissao != null) {
        gameSession.currentState!.activeQuests.add(novaMissao);
        print(
          "NOVA MISSÃO GERADA: ${novaMissao.npcName} quer ${novaMissao.targetItem}",
        );

        if (gameRef.context.mounted) {
          ScaffoldMessenger.of(gameRef.context).showSnackBar(
            SnackBar(
              content: Text(
                "${novaMissao.npcName} precisa de você! Vá até ele para mais detalhes.",
                textAlign: TextAlign.center,
              ),
              backgroundColor: Colors.purpleAccent,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        print("IA decidiu não gerar missão hoje (retornou null).");
      }
    } else {
      print(
        "Ainda existem $missoesEmAndamento missões pendentes. Nenhuma nova foi gerada.",
      );
    }

    diasPassados++;
    gameSession.currentState?.diasPassados = diasPassados;

    print("Comecou o dia $diasPassados");
  }

  Future<void> dormirCasa() async {
    if (_isInteracting) return;

    print("dormiu em casa");
    setInteracting(true);

    final sleepEffect = RectangleComponent(
      priority: 999,
      paint: Paint()..color = Colors.black,
      size: gameRef.size,
      position: Vector2.zero(),
    );
    gameRef.interface?.add(sleepEffect);

    await Future.delayed(const Duration(seconds: 2));
    int timeBeforeSleep = totalGameMinutes;
    _encerrarDia(true);
    _minutoAtualJogo = 360;
    _contadorTempo = 0;
    gameSession.currentState?.horarioAtual = _minutoAtualJogo;

    int timeAfterSleep = totalGameMinutes;
    int minutesSkipped = timeAfterSleep - timeBeforeSleep;
    _timePassage(minutesSkipped);

    sleepEffect.removeFromParent();
    setInteracting(false);
    if (gameRef.context.mounted) {
      ScaffoldMessenger.of(gameRef.context).showSnackBar(
        const SnackBar(
          content: Text(
            "Você descansou e acordou renovado às 06:00!",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.blueGrey,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> dormirRua() async {
    if (_isInteracting) return;

    print("dormiu na rua");
    setInteracting(true);

    _playFaintByDirection();

    await Future.delayed(const Duration(milliseconds: 1500));
    final sleepEffect = RectangleComponent(
      priority: 999,
      paint: Paint()..color = Colors.black,
      size: gameRef.size,
      position: Vector2.zero(),
    );

    gameRef.interface?.add(sleepEffect);
    int timeBeforeSleep = totalGameMinutes;

    _encerrarDia(false);
    _minutoAtualJogo = 360; // 6 da manha (horario incial)
    _contadorTempo = 0;
    gameSession.currentState?.horarioAtual = _minutoAtualJogo;

    int timeAfterSleep = totalGameMinutes;
    int minutesSkipped = timeAfterSleep - timeBeforeSleep;
    _timePassage(minutesSkipped);

    await Future.delayed(const Duration(seconds: 2));
    sleepEffect.removeFromParent();
    setInteracting(false);

    if (gameRef.context.mounted) {
      ScaffoldMessenger.of(gameRef.context).showSnackBar(
        const SnackBar(
          content: Text(
            "Você desmaiou de exaustão e acordou às 06:00!",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.blueGrey,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void update(double dt) {

    // Atualiza timer
    _walkTimer += dt;

    // se está andando (direção ≠ none) e passou intervalo
    if (velocity.length > 0 && _walkTimer >= _walkInterval) {
      _playWalkSound();
      _walkTimer = 0.0;
    }

    if (_reputationNotificationTimer > 0) {
      _reputationNotificationTimer -= dt;

      if (_reputationNotificationTimer <= 0) {
        _reputationNotificationText = null;
        _atualizarReputacaoInterface();
      }
    }
    _contadorTempo += dt;

    if (_contadorTempo >= _segundosPorMinutoJogo) {
      _contadorTempo -= _segundosPorMinutoJogo;
      _minutoAtualJogo++;
      gameSession.currentState?.horarioAtual = _minutoAtualJogo;

      if (_minutoAtualJogo == 90) {
        dormirRua();
      }

      if (_minutoAtualJogo >= _minutosPorDia) {
        _minutoAtualJogo = 0;
      }
    }

    if (_isInteracting) {
      stopMove();

      animation?.update(dt, size);
    } else {
      super.update(dt);
    }
  }

  @override
  void onTap() {
    if (isGamePaused || _isInteracting) return;

    final slot = slotAtivo;
    if (slot != null &&
        (slot.tipo?.endsWith('_seed') ?? false) &&
        slot.quantidade > 0) {
      _tryPlantSeedHere(slot.tipo!);
    } else {
      _tryInteractHere();
    }
  }
}

extension InventoryConversion on HumanPlayer {
  List<InventorySlotState> toSlotStates() {
    return slots
        .map((s) => InventorySlotState(tipo: s.tipo, quantidade: s.quantidade))
        .toList();
  }

  void loadFromSlotStates(
    List<InventorySlotState> states, {
    bool atualizarUI = true,
  }) {
    for (int i = 0; i < slots.length && i < states.length; i++) {
      slots[i].tipo = states[i].tipo;
      slots[i].quantidade = states[i].quantidade;
    }
    if (atualizarUI && gameRef.interface is PlayerInterface) {
      _atualizarInterface();
    }
  }
}
