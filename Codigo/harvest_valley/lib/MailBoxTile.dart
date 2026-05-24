import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/player/human.dart';

class MailBoxTile extends GameObject with TapGesture {
  bool _isShowingDialog = false;
  bool get isGamePaused => gameRef.paused;
  // Sprite? _portraitSprite;

  MailBoxTile(Vector2 position, Vector2 size)
    : super(
        sprite: null,
        position: position,
        size: size,
        objectPriority: LayerPriority.MAP,
      );
  @override
  Future<void> onLoad() async {
    sprite = SpriteManager.mailBoxInteracted;

    // _portraitSprite = SpriteManager.mailBoxInteracted;

    await super.onLoad();
  }

  String? collectMail() {
    return 'mail_item';
  }

  @override
  void onTap() async {
    if (isGamePaused || _isShowingDialog || !gameRef.context.mounted) {
      return; // Impede abrir vários diálogos
    }

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

    _isShowingDialog = true;

    AudioManager().playSfx("mail.mp3");

    String cartaTexto = "";
    try {
      cartaTexto = await rootBundle.loadString(
        'assets/txt/cartaInicialAvo.txt',
      );
    } catch (e) {
      cartaTexto = "Querido neto...\n(Não foi possível ler a carta)";
    }

    if (!gameRef.context.mounted) return;

    await showDialog(
      context: gameRef.context,
      barrierDismissible: true, // clicar fora para fechar
      barrierColor: Colors.black.withOpacity(0.5), // Fundo escuro
      builder: (context) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.7,
              constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),

              decoration: BoxDecoration(
                color: const Color(0xFFFDF5E6),
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(4, 4),
                  ),
                ],
                border: Border.all(
                  color: const Color(0xFF8B4513),
                  width: 2,
                ), // Borda marrom
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 20, bottom: 10),
                    child: Text(
                      "Carta da Vovó",
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF5D4037),
                        fontFamily: 'PatrickHand',
                      ),
                    ),
                  ),

                  // conteudo
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      child: Text(
                        cartaTexto,
                        style: const TextStyle(
                          fontSize: 20,
                          height: 1, // Espaçamento entre linhas
                          color: Colors.black87,
                          fontFamily: 'PatrickHand', 
                        ),
                      ),
                    ),
                  ),

                  // fechar carta
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B4513), // Marrom
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Fechar Carta"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    // 4. Ações após fechar o diálogo
    _isShowingDialog = false;

    // Lógica de coletar o item (se desejar descomentar depois)
    /*
    String? itemColetado = collectMail();
    if (itemColetado != null) {
       player.adicionarItem(itemColetado);
    }
    */
  }
}
