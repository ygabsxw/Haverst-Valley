import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/player/human.dart';

final Map<String, String> _displayNames = {
  'strawberry_item': 'Morango',
  'springOnion_item': 'Cebolinha',
  'potato_item': 'Batata',
  'garlic_item': 'Alho',
  'wheat_item': 'Trigo',
  'trash_item': 'Lixo',

  'wheat_seed': 'Semente de Trigo',
  'strawberry_seed': 'Semente de Morango',
  'springOnion_seed': 'Semente de Cebolinha',
  'potato_seed': 'Semente de Batata',
  'garlic_seed': 'Semente de Alho',
};

class TrashCan extends GameObject with TapGesture {
  final String trashType;

  bool get isGamePaused => gameRef.paused;

  TrashCan({
    required super.position,
    required super.size,
    required this.trashType,
    required super.sprite,
  });

  @override
  void onTap() {
    // Evita múltiplos cliques
    if (isGamePaused || !gameRef.context.mounted) return;

    final player = gameRef.player;
    if (player == null || player is! HumanPlayer) {
      return;
    }

    final double distancia = player.center.distanceTo(center);
    const double distanciaMaxima = 32.0;

    if (distancia > distanciaMaxima) {
      return;
    }

    player.stopMove();
    player.idle();

    final slot = player.slotAtivo;
    if (slot == null || slot.isEmpty) {
      ScaffoldMessenger.of(gameRef.context).showSnackBar(
        SnackBar(
          content: const Text(
            "Não estou segurando nenhum lixo.",
            textAlign: TextAlign.center,
          ),
          backgroundColor: Colors.red.withValues(alpha: 0.8), // Cor de erro
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final int quantity = slot.quantidade;
    final String originalType = slot.tipo!;

    player.removerItemSelecionado(quantidade: quantity);

    final String? displayName = _displayNames[originalType] ?? originalType;
    ScaffoldMessenger.of(gameRef.context).showSnackBar(
      SnackBar(
        content: Text(
          "$displayName descartado com sucesso.",
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    AudioManager().playSfx("trash.mp3");
    
    // se foi no lixo reciclavel e não reciclou hoje, registra a reciclagem
    if (trashType == 'recyclableTrash') {
      if (player.reciclouHoje == false) {
        player.registrarReciclagem();
      }
      // se alem de reciclar, o item jogado fora foi o lixo
      if (originalType == 'trash_item') {
        player.ganharReputacao(2 * quantity);
      }
    } else {
      player.perderReputacao(2 * quantity);
    }

    return;
  }
}
