// lightpoint.dart
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:harvest_valley/player/human.dart';

class Lightpoint extends GameDecoration {
  static final tileSize = 16.0;

  final LightingConfig _lightConfig = LightingConfig(
    radius: tileSize * 3,
    blurBorder: tileSize*5,
    color: Color.fromARGB(255, 255, 203, 125).setOpacity(0.3),
    withPulse: true,
    pulseVariation: 0.03,
    pulseSpeed: 0.015,
    pulseCurve: Curves.bounceInOut,
  );

  bool _isLightOn = false;

  Lightpoint(Vector2 position)
    : super(
        size: Vector2.all(tileSize),
        position: position,
        lightingConfig: null,
      );

  @override
  void onMount() {
    _updateLightState(force: true);
    super.onMount();
  }

  @override
  void update(double dt) {
    _updateLightState();
    super.update(dt);
  }

  void _updateLightState({bool force = false}) {
    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    final int hora = player.minutoAtualJogo ~/ 60;

    final bool isNight = (hora >= 18 || hora < 6);

    if (isNight && (!_isLightOn || force)) {
      setupLighting(_lightConfig);
      _isLightOn = true;
    } else if (!isNight && (_isLightOn || force)) {
      setupLighting(null);
      _isLightOn = false;
    }
  }
}
