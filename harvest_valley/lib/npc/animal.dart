import 'package:bonfire/bonfire.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:harvest_valley/AnimalManager.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/data/crops_data.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:flame_audio/flame_audio.dart';

enum AnimalState { hungry, eating, readyToCollect, full }

enum AnimalBehavior { idle, wander }

enum WalkAxis { horizontal, vertical }

class Animal extends SimpleEnemy with TapGesture, BlockMovementCollision {
  final String id;
  final String specie;
  final AnimalBehavior behavior;
  final double wanderArea;

  late final AnimalConfig? _config;
  AnimalState _currentState = AnimalState.hungry;
  double _productionTimer = 0.0;

  PositionComponent? _emoteComponent;

  double waitTime = 0;
  final double maxWait;
  WalkAxis? _axisAtual;
  Direction? _dirAtual;
  bool _colidiu = false;
  late double minX, maxX, minY, maxY;
  Vector2? _target;
  final Random _rng = Random();

  final dynamic spriteSheet;

  bool get isGamePaused => gameRef.paused;

  Animal({
    required this.id,
    required super.position,
    required super.size,
    required this.spriteSheet,
    required SimpleDirectionAnimation super.animation,
    required this.specie,
    this.maxWait = 4,
    this.behavior = AnimalBehavior.wander,
    double super.speed = 10,
    this.wanderArea = 200,
    Direction lookDirection = Direction.down,
  }) : super(initDirection: lookDirection) {
    _config = AnimalConfig.getByType(specie);
  }

  void processTimeSkip(int minutesSkipped) {
    if (minutesSkipped <= 0 || _config == null) return;

    double secondsPassed = minutesSkipped.toDouble();
    bool mudouAlgo = false;

    if (_currentState == AnimalState.eating) {
      _productionTimer += secondsPassed;

      if (_productionTimer >= _config.productionTimeSec) {
        // ficou pronto durante a noite
        _currentState = AnimalState.readyToCollect;
        _productionTimer = 0;
        _showEmote('!');
        mudouAlgo = true;
        print("Animal $id ($specie) terminou de produzir durante a noite.");
      }
    } else if (_currentState == AnimalState.full) {
      _productionTimer += secondsPassed;
      double cooldownEmSegundos = _config.feedIntervalGameMin.toDouble();

      if (_productionTimer >= cooldownEmSegundos) {
        // a fome voltou durante a noite
        _currentState = AnimalState.hungry;
        _productionTimer = 0;
        _showEmote('?');
        mudouAlgo = true;
        print("Animal $id ($specie) ficou com fome durante a noite.");
      }
    }

    if (mudouAlgo) {
      _saveState();
    }
  }

  void _loadState() {
    final saved = AnimalManager.instance.getAnimalState(id);
    if (saved != null) {
      if (saved.currentStateIndex < AnimalState.values.length) {
        _currentState = AnimalState.values[saved.currentStateIndex];
      }
      _productionTimer = saved.productionTimer;

      _restoreVisualFeedback();
      print(
        "Animal $id carregado: Estado: $_currentState, Timer: $_productionTimer",
      );
    }

    if (_currentState == AnimalState.readyToCollect) {
      _showEmote('!');
    }
  }

  void _restoreVisualFeedback() {
    switch (_currentState) {
      case AnimalState.readyToCollect:
        _showEmote('!');
        break;
      case AnimalState.eating:
        _showEmote('...');
        break;
      case AnimalState.full:
        _showEmote('Zzz');
        break;
      case AnimalState.hungry:
        _showEmote('?');
        break;
    }
  }

  void _saveState() {
    final stateToSave = AnimalRuntimeState(
      id: id,
      specie: specie,
      currentStateIndex: _currentState.index,
      productionTimer: _productionTimer,
      x: position.x,
      y: position.y,
    );

    // 1. Atualiza na Memória (Manager)
    AnimalManager.instance.updateAnimalState(id, stateToSave);

    if (gameSession.currentState != null) {
      gameSession.currentState!.animalStates = AnimalManager.instance
          .toPersistentStates();
    }
  }

  @override
  void update(double dt) {
    if (!isGamePaused) {
      if (behavior == AnimalBehavior.wander) {
        _wander(dt);
      }
      if (_emoteComponent != null && _emoteComponent!.isMounted) {
        (_emoteComponent as PositionComponent).position =
            position + Vector2(size.x / 4, -10);
      }

      _updateProductionLogic(dt);
      _updateSfx(dt); //sfx do animal
    }

    super.update(dt);
  }

  void _updateProductionLogic(double dt) {
    if (_config == null) return;

    bool mudouAlgo = false;

    if (_currentState == AnimalState.eating) {
      _productionTimer += dt;
      mudouAlgo = true;
      if (_productionTimer >= _config.productionTimeSec) {
        _currentState = AnimalState.readyToCollect;
        _productionTimer = 0;

        _showEmote('!');
      }
    }

    if (_currentState == AnimalState.full) {
      _productionTimer += dt;
      mudouAlgo = true;
      double cooldownEmSegundos = _config.feedIntervalGameMin.toDouble();

      if (_productionTimer >= cooldownEmSegundos) {
        _currentState = AnimalState.hungry;
        _productionTimer = 0;

        _showEmote('?');
      }
    }

    if (mudouAlgo) {
      _saveState();
    }
  }

  @override
  void onTap() {
    if (isGamePaused || !gameRef.context.mounted) return;

    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    // Verifica distância
    final double distancia = player.center.distanceTo(center);
    if (distancia > 48)
      return; // Distância aumentada um pouco para facilitar o toque

    // Para player e Animal para interagir
    player.stopMove();
    player.idle();
    stopMove();
    idle();
    _target = null;
    lookToPlayer();

    // Executa ação baseada no estado atual
    _handleInteraction(player);
  }

  void _handleInteraction(HumanPlayer player) {
    if (_config == null) return;

    switch (_currentState) {
      case AnimalState.readyToCollect:
        _collectProduct(player);
        break;

      case AnimalState.hungry:
        _tryFeedAnimal(player);
        break;

      case AnimalState.eating:
        int remaining = (_config.productionTimeSec - _productionTimer).ceil();
        _showSnack("Digerindo... Faltam ${remaining}s.", Colors.orange);
        break;

      case AnimalState.full:
        _showSnack("${specie} está satisfeito por enquanto.", Colors.blueGrey);
        break;
    }
  }

  void _tryFeedAnimal(HumanPlayer player) {
    final slot = player.slotAtivo;
    int custo = _config!.wheatAmountForFeed;

    if (slot != null && slot.tipo == 'wheat_item' && slot.quantidade >= custo) {
      player.removerItemSelecionado(quantidade: custo);

      _currentState = AnimalState.eating;
      _productionTimer = 0;

      _showSnack("Alimentado! (${_config.name})", Colors.green);
      _showEmote('♥'); // Coração para mostrar que gostou

      _saveState();
    } else {
      _showSnack("Requer $custo Trigos para alimentar.", Colors.red);
      _showEmote('?'); // (Fome/Dúvida)
    }
  }

  void _collectProduct(HumanPlayer player) {
    String item = '${_config!.productItem}_item'; // Ex: 'milk_item'
    bool added = player.adicionarItem(item, quantidade: 1);

    if (added) {
      _currentState = AnimalState.full;
      _productionTimer =
          0; // Resetamos o timer para usar na contagem do intervalo

      _removeEmote();

      _showSnack("Coletado: ${_config.productName}", Colors.blue);
      player.ganharReputacao(_config.reputationGain);

      // Feedback visual de que está satisfeito/dormindo
      _showEmote('Zzz');

      _saveState();
    } else {
      _showSnack("Inventário Cheio!", Colors.red);
    }
  }

  void _showSnack(String text, Color color) {
    ScaffoldMessenger.of(gameRef.context).clearSnackBars(); // Limpa anteriores
    ScaffoldMessenger.of(gameRef.context).showSnackBar(
      SnackBar(
        content: Text(text, textAlign: TextAlign.center),
        backgroundColor: color,
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showEmote(String text) {
    _removeEmote();
    print("remove emoji antigo");

    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 6,
        fontWeight: FontWeight.bold,
        shadows: [
          Shadow(color: Colors.black, blurRadius: 2, offset: Offset(1, 1)),
        ],
      ),
    );

    _emoteComponent = TextComponent(
      text: text,
      textRenderer: textPaint,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, -10),
      priority: 100,
    );

    gameRef.add(_emoteComponent!);
  }

  void _removeEmote() {
    if (_emoteComponent != null) {
      _emoteComponent!.removeFromParent();
      _emoteComponent = null;
    }
  }

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

  @override
  bool onBlockMovement(Set<Vector2> intersectionPoints, GameComponent other) {
    _colidiu = true;
    return super.onBlockMovement(intersectionPoints, other);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _loadState();

    final hitboxSize = size * 0.6;

    anchor = Anchor.center;

    add(
      RectangleHitbox(
        size: hitboxSize,
        position: (size - hitboxSize) / 2,
        collisionType: CollisionType.active,
      ),
    );

    final half = wanderArea / 2;
    minX = position.x - half;
    maxX = position.x + half;
    minY = position.y - half;
    maxY = position.y + half;

    if (_currentState == AnimalState.readyToCollect) {
      _showEmote('!');
    }
  }

  @override
  void onMount() {
    super.onMount();
    _resetSfxTimer(); // iniciar timer de audio
  }

  // --- Controle de SFX ---
  double _sfxTimer = 0.0;
  double _nextSfxInterval = 0.0;

  void _resetSfxTimer() {
    // intervalo aleatório entre 5 e 20 segundos
    _nextSfxInterval = 5 + _rng.nextDouble() * 20;
    _sfxTimer = 0.0;
  }

  void _updateSfx(double dt) {
    _sfxTimer += dt;
    if (_sfxTimer >= _nextSfxInterval) {
      _playAnimalSound();
      _resetSfxTimer();
    }
  }

  void _playAnimalSound() {
    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    // distância player ←→ animal
    final double distanceInPixels = player.center.distanceTo(center);

    const double hearingRadius = 400.0;

    if (distanceInPixels > hearingRadius) return;

    // atenuação simples pela distância
    double fatorDistancia = 1 - (distanceInPixels / hearingRadius);
    fatorDistancia = fatorDistancia.clamp(0.0, 1.0);

    // volume final (use a mesma fonte global de SFX do seu jogo)
    final double baseVolume =
        AudioManager().sfxVolume; // ou gameSession.settings.sfxVolume
    final double volumeFinal = baseVolume * fatorDistancia;

    // arquivo do som
    final String? file = _getSpecieSound();
    if (file == null || file.isEmpty) return;

    FlameAudio.play(file, volume: volumeFinal);
    print("tocou som $specie");
  }

  String _getSpecieSound() {
    final lower = specie.toLowerCase();

    // --- VACA ---
    if (lower.contains('cow') || lower.contains('calf')) {
      return 'cow.mp3';
    }

    // --- GALINHA ---
    if (lower.contains('chicken')) {
      final sons = ['chicken_1.mp3', 'chicken_3.mp3', 'chicken_4.mp3'];
      return sons[_rng.nextInt(sons.length)];
    }

    // --- OUTROS ---
    if (lower.contains('goat')) {
      return 'goat.mp3';
    }
    if (lower.contains('sheep')) {
      return 'sheep.mp3';
    }
    if (lower.contains('pintinho')) {
      return 'chicken_2.mp3';
    }
    if (lower.contains('dog')) {
      return 'dog.mp3';
    }
    if (lower.contains('cat')) {
      return 'cat.mp3';
    }

    // fallback
    return '';
  }
}
