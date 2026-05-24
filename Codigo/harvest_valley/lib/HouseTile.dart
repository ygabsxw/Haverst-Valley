import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/player/human.dart';

class HouseTile extends GameDecoration with TapGesture {
  bool get isGamePaused => gameRef.paused;

  HouseTile(Vector2 position, Vector2 size)
    : super(position: position, size: size);

  @override
  void onTap() {
    if (isGamePaused) return;

    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    final double distancia = player.center.distanceTo(center);

    if (distancia > 32) {
      _showFeedback("Chegue mais perto para entrar.");
      return;
    }

    _showSleepDialog();
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(gameRef.context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSleepDialog() {
    (gameRef.player as HumanPlayer).stopMove();
    (gameRef.player as HumanPlayer).idle();

    showDialog(
      context: gameRef.context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Fim do dia"),
          content: const Text(
            "Deseja dormir e avançar para o próximo dia às 06:00?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Não", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final player = gameRef.player as HumanPlayer;
                await player.dormirCasa();

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Você descansou. Um novo dia começa!"),
                      backgroundColor: Colors.blueGrey,
                    ),
                  );
                }
              },
              child: const Text("Sim (Dormir)"),
            ),
          ],
        );
      },
    );
  }
}