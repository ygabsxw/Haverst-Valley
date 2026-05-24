import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:flutter/material.dart';

class ReputationBarComponent extends PositionComponent with HasGameReference {
  final HumanPlayer player;

  // Variáveis de estado
  bool isVisible = false;
  double reputationValue = 0.5; // 50/100
  String displayMessage = '';
  Color barColor = Colors.grey;

  // Renderização
  late final TextPaint textPaint;
  late final TextPaint barTextPaint;

  // Dimensões
  final double barWidth = 400;
  final double barHeight = 40;
  final double containerPadding = 12;
  final double borderRadius = 10;
  final double bottomMargin = 30;

  ReputationBarComponent(this.player)
    : super(
        priority:
            10, // Prioridade alta para ficar acima de outros elementos do HUD
        anchor: Anchor.bottomCenter,
      ) {
    textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );

    barTextPaint = TextPaint(
      style: TextStyle(
        color: Colors.white,
        fontSize: 14,
        shadows: [
          const Shadow(
            offset: Offset(1, 1),
            blurRadius: 1,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  void updateReputationState() {
    isVisible = player.reputationNotificationText != null;

    displayMessage = player.reputationNotificationText ?? '';
    barColor = player.reputationNotificationColor ?? Colors.grey;

    reputationValue = player.reputacao / 100.0;
  }

  @override
  void render(Canvas canvas) {
    if (!isVisible) return;

    final currentRep = (player.reputacao);

    // 1. Definição da cor do preenchimento da barra (NOVA LÓGICA)
    Color getBarFillColor(int rep) {
      if (rep >= 80) {
        return const Color.fromARGB(255, 102, 187, 106); // VERDE (80+)
      } else if (rep >= 40) {
        return Colors.yellow; // AMARELO (40 a 79)
      } else {
        return const Color.fromARGB(
          255,
          255,
          82,
          82,
        ); // VERMELHO (abaixo de 40)
      }
    }

    final Color fillBarColor = getBarFillColor(currentRep);

    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Radius.circular(borderRadius),
    );
    canvas.drawRRect(rect, Paint()..color = barColor);

    final Rect progressBarRect = Rect.fromLTWH(
      containerPadding,
      containerPadding + 30,
      size.x - (containerPadding * 2),
      10,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(progressBarRect, const Radius.circular(5)),
      Paint()..color = Colors.white30,
    );

    final double filledWidth =
        (size.x - (containerPadding * 2)) * reputationValue;
    final Rect filledBarRect = Rect.fromLTWH(
      progressBarRect.left,
      progressBarRect.top,
      filledWidth,
      progressBarRect.height,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(filledBarRect, const Radius.circular(5)),
      Paint()..color = fillBarColor,
    );

    textPaint.render(
      canvas,
      displayMessage,
      Vector2(size.x / 2, containerPadding + 5),
      anchor: Anchor.topCenter,
    );

    barTextPaint.render(
      canvas,
      '$currentRep / 100',
      Vector2(size.x / 2, progressBarRect.top + 1),
      anchor: Anchor.topCenter,
    );
  }

  @override
  void onGameResize(Vector2 gameSize) {
    final double responsiveBarWidth = (barWidth).clamp(0, gameSize.x * 0.9);

    size = Vector2(responsiveBarWidth, barHeight + containerPadding * 2 + 10);

    double x = gameSize.x / 2;
    double y = gameSize.y - bottomMargin;

    position = Vector2(x, y);

    super.onGameResize(gameSize);
  }
}

class PlayerInterface extends GameInterface {
  final List<InterfaceComponent> _slots = [];
  final List<SpriteComponent> _icones = [];
  final List<TextComponent> _quantidades = [];
  int? _slotSelecionado;

  //pré carregar sprites
  late Sprite _spriteSlotVazio;
  late Sprite _spriteCoin;

  late InterfaceComponent _settingsButton;

  late TextComponent _moneyTextComponent;
  late TextComponent _clockTextComponent;
  late SpriteComponent _clockBackground;
  late SpriteComponent _coinBackground;
  late SpriteComponent _coinIcon;
  late TextComponent _solIcon;
  late TextComponent _luaIcon;

  // CORREÇÃO: Removido 'final' para permitir reatribuição no resize
  late TextPaint _iconSolAceso;
  late TextPaint _iconLuaAceso;
  late TextPaint _iconApagado;

  final double _slotBaseSize = 90;
  final double _slotSpacing = 110;

  double _scaleFactor = 1.0;

  bool? _isDiaCache;

  bool _componentesCarregados = false;
  late ReputationBarComponent _reputationBarComponent;

  @override
  Future<void> onLoad() async {
    _spriteSlotVazio = await Sprite.load(
      'hud/vazio.png',
    ); //placeholder para testes
    _spriteCoin = await Sprite.load('hud/coin.png');

    // Inicialização padrão para evitar erros antes do primeiro resize
    const iconShadows = [
      Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.black),
      Shadow(offset: Offset(-1, -1), color: Colors.black),
      Shadow(offset: Offset(1, -1), color: Colors.black),
      Shadow(offset: Offset(-1, 1), color: Colors.black),
    ];

    _iconSolAceso = TextPaint(
      style: const TextStyle(
        fontFamily: 'MaterialIcons',
        fontSize: 22,
        color: Color.fromARGB(240, 255, 235, 59),
        shadows: iconShadows,
      ),
    );

    _iconLuaAceso = TextPaint(
      style: const TextStyle(
        fontFamily: 'MaterialIcons',
        fontSize: 22,
        color: Color.fromARGB(240, 224, 224, 224),
        shadows: iconShadows,
      ),
    );

    _iconApagado = TextPaint(
      style: const TextStyle(
        fontFamily: 'MaterialIcons',
        fontSize: 22,
        color: Color.fromARGB(240, 97, 97, 97),
        shadows: iconShadows,
      ),
    );

    super.onLoad();
  }

  @override
  void onMount() async {
    _scaleFactor = (gameRef.size.x / 1200.0).clamp(0.7, 1.0);

    for (int i = 0; i < 4; i++) {
      //slot de fundo
      final index = i; 
      final slotSize = Vector2.all(_slotBaseSize * _scaleFactor);
      final slot = InterfaceComponent(
        spriteUnselected: Sprite.load(
          'hud/inventario_slotvazio.png',
        ), //placeholder para testes
        spriteSelected: Sprite.load(
          'hud/inventario_slotselecionado.png',
        ), //placeholder para testes
        size: slotSize,
        id: index,
        position: Vector2.zero(),
        selectable:
            false, //não é "selecionavel" no bonfire, mas possui a mesma lógica
        onTapComponent: (_) {
          final player = gameRef.player;
          if (player is HumanPlayer) {
            if (_slotSelecionado == index) {
              _slotSelecionado = 5; //slot inválido/vazio (mãos)
              player.selecionarSlot(5);
              _slots[index].selected = false;
            } else {
              _desmarcarTodos(); //apenas 1 slot pode ser selecionado por vez
              _slotSelecionado = index;
              player.selecionarSlot(index);
              _slots[index].selected = true;
            }
          }
        },
      )..priority = 0; //prioridade baixa, mais ao fundo da tela

      _slots.add(slot);
      await add(slot);

      //icone do item (inicialmente com placeholder vazio)
      final icone =
          SpriteComponent(
              sprite: _spriteSlotVazio,
              size: slotSize * 0.7,
              position: Vector2.zero(),
            )
            ..priority =
                slot.priority +
                50 //prioridade superior, ou seja, acima do slot de fundo
            ..anchor = Anchor.topLeft;

      _icones.add(icone);
      await add(icone);

      //texto da quantidade
      final quantidade = TextComponent(
        text: '0',
        textRenderer: TextPaint(
          style: TextStyle(
            fontFamily: 'monospace',
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(246, 255, 255, 255),
            shadows: [
              Shadow(
                offset: Offset(1, 1), // deslocamento da sombra
                blurRadius: 0, // sem borrado → fica pixelado
                color: Colors.black, // cor da borda
              ),
              Shadow(offset: Offset(-1, -1), color: Colors.black),
              Shadow(offset: Offset(1, -1), color: Colors.black),
              Shadow(offset: Offset(-1, 1), color: Colors.black),
            ],
          ),
        ),
        position: Vector2.zero(),
      )..priority = icone.priority + 1;

      _quantidades.add(quantidade);
      await add(quantidade);
      await add(FpsTextComponent());
    }

    _settingsButton =
        InterfaceComponent(
            spriteUnselected: Sprite.load('hud/settingsButton.png'),
            spriteSelected: Sprite.load(
              'hud/settingsButton.png',
            ), // Pode usar um sprite de "clicado" se tiver
            size: Vector2.all(60 * _scaleFactor),
            position: Vector2.zero(),
            id: 5, // Um ID único (slots são 0-3)
            onTapComponent: (_) {
              AudioManager().playSfx("button_press.mp3");
              // AÇÃO: Pausa o jogo e abre o overlay
              gameRef.pauseEngine();
              gameRef.overlays.add('pauseMenu');
            },
          )
          ..priority = 0
          ..anchor = Anchor.topLeft;

    await add(_settingsButton);

    _clockBackground =
        SpriteComponent(
            sprite: await Sprite.load('hud/backgroundClock.png'),
            size: Vector2.all(220 * _scaleFactor),
            position: Vector2.zero(),
          )
          ..priority =
              0 // Prioridade abaixo do ícone e do texto
          ..anchor = Anchor.topLeft;
    await add(_clockBackground);

    _solIcon =
        TextComponent(
            text: String.fromCharCode(Icons.sunny.codePoint),
            textRenderer: _iconSolAceso,
            position: Vector2.zero(),
          )
          ..priority = _clockBackground.priority + 1
          ..anchor = Anchor.topLeft;
    await add(_solIcon);

    _luaIcon =
        TextComponent(
            text: String.fromCharCode(Icons.nightlight_round.codePoint),
            textRenderer: _iconApagado,
            position: Vector2.zero(),
          )
          ..priority = _clockBackground.priority + 1
          ..anchor = Anchor.topLeft;
    await add(_luaIcon);

    _clockTextComponent =
        TextComponent(
            text: '00:00',
            textRenderer: TextPaint(
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(246, 255, 255, 255),
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 0,
                    color: Colors.black,
                  ),
                  Shadow(offset: Offset(-1, -1), color: Colors.black),
                  Shadow(offset: Offset(1, -1), color: Colors.black),
                  Shadow(offset: Offset(-1, 1), color: Colors.black),
                ],
              ),
            ),
            position: Vector2.zero(),
          )
          ..priority = 1
          ..anchor = Anchor.topLeft;

    await add(_clockTextComponent);

    _coinBackground =
        SpriteComponent(
            sprite: await Sprite.load('hud/backgroundCoin.png'),
            size: Vector2.all(220 * _scaleFactor),
            position: Vector2.zero(),
          )
          ..priority =
              -1 // Prioridade abaixo do ícone e do texto
          ..anchor = Anchor.topLeft;
    await add(_coinBackground);

    _coinIcon =
        SpriteComponent(
            sprite: _spriteCoin,
            size: Vector2.all(60 * _scaleFactor),
            position: Vector2.zero(),
          )
          ..priority = 0
          ..anchor = Anchor.topLeft;
    await add(_coinIcon);

    _moneyTextComponent =
        TextComponent(
            text: '', // Valor inicial // max dinheiro 9.999.999
            textRenderer: TextPaint(
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(246, 255, 255, 255),
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 0,
                    color: Colors.black,
                  ),
                  Shadow(offset: Offset(-1, -1), color: Colors.black),
                  Shadow(offset: Offset(1, -1), color: Colors.black),
                  Shadow(offset: Offset(-1, 1), color: Colors.black),
                ],
              ),
            ),
            position: Vector2.zero(),
          )
          ..priority =
              1 // Prioridade acima do ícone
          ..anchor = Anchor.topLeft;

    await add(_moneyTextComponent);

    if (gameRef.player is HumanPlayer) {
      _reputationBarComponent = ReputationBarComponent(
        gameRef.player as HumanPlayer,
      );
      await add(_reputationBarComponent);
    }
    _componentesCarregados = true;
    
    onGameResize(gameRef.size);
    super.onMount();

    if (gameRef.player is HumanPlayer) {
      _reputationBarComponent = ReputationBarComponent(
        gameRef.player as HumanPlayer,
      );
      await add(_reputationBarComponent);

      Future.delayed(const Duration(milliseconds: 100), () {
        atualizarInventario(gameRef.player as HumanPlayer);
      });
    }
  }

  @override
  void onGameResize(Vector2 newSize) {
    _scaleFactor = (newSize.x / 1200.0).clamp(0.7, 1.0);
    final double HUDScale = _scaleFactor;

    if (_componentesCarregados) {
      final double _slotSpacing = 110;
      final double _slotBaseSize = 90;

      final double startX = 40.0 * _scaleFactor;

      for (int i = 0; i < _slots.length; i++) {
        final slotSize = Vector2.all(_slotBaseSize * _scaleFactor);
        final currentX = startX + (i * _slotSpacing * _scaleFactor);

        _slots[i].size = slotSize;
        _slots[i].position = Vector2(currentX, 20 * _scaleFactor);

        final iconSize = slotSize * 0.7;
        final iconX = currentX + (slotSize.x - iconSize.x) / 2;
        final iconY = (20 * _scaleFactor) + (slotSize.y - iconSize.y) / 2;

        _icones[i].size = iconSize;
        _icones[i].position = Vector2(iconX, iconY);

        final TextPaint currentQuantPaint =
            _quantidades[i].textRenderer as TextPaint;
        _quantidades[i].textRenderer = TextPaint(
          style: currentQuantPaint.style.copyWith(fontSize: 28 * _scaleFactor),
        );

        _quantidades[i].position = Vector2(
          currentX + slotSize.x - (10 * _scaleFactor),
          (20 * _scaleFactor) + slotSize.y - (10 * _scaleFactor),
        );
        _quantidades[i].anchor = Anchor.bottomRight;
      }

      _settingsButton.size = Vector2.all(60 * _scaleFactor);
      _settingsButton.position = Vector2(
        newSize.x - (100 * _scaleFactor),
        13 * _scaleFactor,
      );

      _clockBackground.size = Vector2.all(220 * HUDScale);
      _clockBackground.position = Vector2(
        newSize.x - (308 * HUDScale),
        15 * HUDScale,
      );

      _coinBackground.size = Vector2.all(220 * HUDScale);
      _coinBackground.position = Vector2(
        newSize.x - (310 * HUDScale),
        -44 * HUDScale,
      );

      _coinIcon.size = Vector2.all(60 * HUDScale);
      _coinIcon.position = Vector2(newSize.x - (290 * HUDScale), 36 * HUDScale);

      // Textos
      _moneyTextComponent.position = Vector2(
        newSize.x - (230 * HUDScale),
        51 * HUDScale,
      );
      final TextPaint currentMoneyPaint =
          _moneyTextComponent.textRenderer as TextPaint;
      _moneyTextComponent.textRenderer = TextPaint(
        style: currentMoneyPaint.style.copyWith(fontSize: 28 * HUDScale),
      );

      _clockTextComponent.position = Vector2(
        newSize.x - (233 * HUDScale),
        112 * HUDScale,
      );
      final TextPaint currentClockPaint =
          _clockTextComponent.textRenderer as TextPaint;
      _clockTextComponent.textRenderer = TextPaint(
        style: currentClockPaint.style.copyWith(fontSize: 24 * HUDScale),
      );

      const iconShadows = [
        Shadow(offset: Offset(1, 1), blurRadius: 0, color: Colors.black),
        Shadow(offset: Offset(-1, -1), color: Colors.black),
        Shadow(offset: Offset(1, -1), color: Colors.black),
        Shadow(offset: Offset(-1, 1), color: Colors.black),
      ];

      _iconSolAceso = TextPaint(
        style: TextStyle(
          fontFamily: 'MaterialIcons',
          fontSize: 22 * HUDScale,
          color: const Color.fromARGB(240, 255, 235, 59),
          shadows: iconShadows,
        ),
      );

      _iconLuaAceso = TextPaint(
        style: TextStyle(
          fontFamily: 'MaterialIcons',
          fontSize: 22 * HUDScale,
          color: const Color.fromARGB(240, 224, 224, 224),
          shadows: iconShadows,
        ),
      );

      _iconApagado = TextPaint(
        style: TextStyle(
          fontFamily: 'MaterialIcons',
          fontSize: 22 * HUDScale,
          color: const Color.fromARGB(240, 97, 97, 97),
          shadows: iconShadows,
        ),
      );

      _solIcon.position = Vector2(newSize.x - (267 * HUDScale), 114 * HUDScale);
      _luaIcon.position = Vector2(newSize.x - (152 * HUDScale), 114 * HUDScale);

      _solIcon.textRenderer = _iconSolAceso;
      _luaIcon.textRenderer = _iconApagado;

      _reputationBarComponent.onGameResize(newSize);
    }

    super.onGameResize(newSize);
  }

  void atualizarReputacao(HumanPlayer player) {
    if (!_componentesCarregados) return;
    _reputationBarComponent.updateReputationState();
  }

  //percorre os slots e "deseleciona" todos
  void _desmarcarTodos() {
    for (final comp in _slots) {
      comp.selected = false;
    }
  }

  ///metodo chamado pelo Player quando o inventário mudar
  void atualizarInventario(HumanPlayer player) {
    if (!_componentesCarregados) return;
    final double slotBaseSize = _slotBaseSize * _scaleFactor;
    final double slotSpacing = _slotSpacing * _scaleFactor;
    final double startX = 40.0 * _scaleFactor;
    final double startY = 20.0 * _scaleFactor;

    for (int i = 0; i < _icones.length; i++) {
      final slot = player.slots[i];
      final iconeComponent = _icones[i];
      final quantidadeComponent = _quantidades[i];

      // Posição base do slot atual (igual a _slots[i].position)
      final currentX = startX + (i * slotSpacing);
      final slotCurrentSize = Vector2.all(slotBaseSize);

      if (slot.tipo != null &&
          SpriteManager.itemSprites.containsKey(slot.tipo)) {
        iconeComponent.sprite = SpriteManager.itemSprites[slot.tipo]!;
        quantidadeComponent.text = slot.quantidade > 0
            ? slot.quantidade.toString()
            : '';

        double itemBaseSize = slotCurrentSize.x * 0.7; // 70% do tamanho do slot
        double itemCurrentSize = itemBaseSize;
        iconeComponent.paint = Paint(); // Reseta para itens normais

        // Lógica específica para o item 'trash_item'
        if (slot.tipo == 'trash_item') {
          iconeComponent.paint = SpriteManager.greyPaint;
          // Reduz mais o ícone do lixo para destacá-lo (ex: 60% do slot base)
          itemCurrentSize = slotCurrentSize.x * 0.6;
        }

        double diff = (slotCurrentSize.x - itemCurrentSize) / 2;
        double itemXPos = currentX + diff;
        double itemYPos = startY + diff;

        iconeComponent.size = Vector2.all(itemCurrentSize);
        iconeComponent.position = Vector2(itemXPos, itemYPos);
      } else {
        iconeComponent.sprite = _spriteSlotVazio;
        iconeComponent.paint = Paint();

        double placeholderSize = slotCurrentSize.x * 0.7;
        double diff = (slotCurrentSize.x - placeholderSize) / 2;

        iconeComponent.size = Vector2.all(placeholderSize);
        iconeComponent.position = Vector2(currentX + diff, startY + diff);

        quantidadeComponent.text = '';
      }
    }

    atualizarDinheiro(player);
  }

  void atualizarDinheiro(HumanPlayer player) {
    if (!_componentesCarregados) return;
    _moneyTextComponent.text = player.dinheiro.toString();
  }

  @override
  void update(double dt) {
    if (!_componentesCarregados) return;

    if (gameRef.player is HumanPlayer) {
      final player = gameRef.player as HumanPlayer;

      if (player.tempoFormatado != _clockTextComponent.text) {
        _clockTextComponent.text = player.tempoFormatado;
      }

      final bool isDiaAtual = player.isDia;

      if (_isDiaCache != isDiaAtual) {
        _isDiaCache = isDiaAtual;
        if (isDiaAtual) {
          _solIcon.textRenderer = _iconSolAceso;
          _luaIcon.textRenderer = _iconApagado;
        } else {
          _solIcon.textRenderer = _iconApagado;
          _luaIcon.textRenderer = _iconLuaAceso;
        }
      }

      if (player.tempoFormatado != _clockTextComponent.text) {
        _clockTextComponent.text = player.tempoFormatado;
      }
    }

    super.update(dt);
  }
}
