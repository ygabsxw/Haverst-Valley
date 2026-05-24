import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/pages/menu.dart';
import 'package:harvest_valley/main.dart'; // importa o rootScaffoldMessengerKey
import 'package:harvest_valley/pages/transition.dart';
import 'package:harvest_valley/audio/audiomanager.dart';

String _getReputationStatus(int rep) {
  if (rep >= 80) return 'Excelente';
  if (rep >= 40) return 'Normal';
  return 'Ruim';
}

Color _getReputationColor(int rep) {
  if (rep >= 80) return Colors.greenAccent;
  if (rep >= 40) return Colors.yellow;
  return Colors.red;
}

//submenu de Configurações de Áudio
class AudioSettingsMenu extends StatefulWidget {
  final VoidCallback onBack;
  final double menuHeight;

  const AudioSettingsMenu({
    super.key,
    required this.onBack,
    required this.menuHeight,
  });

  @override
  State<AudioSettingsMenu> createState() => _AudioSettingsMenuState();
}

class _AudioSettingsMenuState extends State<AudioSettingsMenu> {
  double _bgmVolume = AudioManager().bgmVolume;
  double _sfxVolume = AudioManager().sfxVolume;
  double _ambienceVolume = AudioManager().ambienceVolume;
  bool _isMuted = AudioManager().isMuted;

  @override
  Widget build(BuildContext context) {
    // mesma altura do menu principal para calcular tamanhos consistentes
    final double menuHeight = widget.menuHeight;
    final double titleFontSize = menuHeight * 0.05;

    final double bodyFontSize = menuHeight * 0.04;
    final double spacingSmall = menuHeight * 0.015;
    final double spacingMedium = menuHeight * 0.03;
    final double buttonImageSize = menuHeight * 0.1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Configurações de Áudio',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Colors.white,
            shadows: const [
              Shadow(offset: Offset(1, 1), blurRadius: 1, color: Colors.black),
              Shadow(
                offset: Offset(-1, -1),
                blurRadius: 1,
                color: Colors.black,
              ),
            ],
          ),
        ),
        SizedBox(height: spacingSmall),
        // Botão Mute/Unmute dinâmico
        _ImageButton(
          imagePath: _isMuted
              ? 'assets/images/hud/switch_off.png'
              : 'assets/images/hud/switch_on.png',
          size: buttonImageSize * 1.5, //switch maior
          onPressed: () {
            setState(() {
              if (_isMuted) {
                AudioManager().unmuteAll();
              } else {
                AudioManager().muteAll();
              }
              AudioManager().playSfx("button_press.mp3");
              _isMuted = AudioManager().isMuted;
            });
          },
          tooltip: _isMuted ? 'Ativar Som' : 'Desativar Som',
        ),

        SizedBox(height: spacingMedium),
        // Sliders
        _AudioSlider(
          label: "Música",
          value: _bgmVolume,
          onChanged: (v) {
            setState(() {
              _bgmVolume = v;
              AudioManager().setBgmVolume(v);
            });
          },
        ),
        SizedBox(height: spacingSmall),
        _AudioSlider(
          label: "Efeitos",
          value: _sfxVolume,
          onChanged: (v) {
            setState(() {
              _sfxVolume = v;
              AudioManager().setSfxVolume(v);
              AudioManager().playSfx("button_press.mp3"); //comparar o som atual
            });
          },
        ),
        SizedBox(height: spacingSmall),
        _AudioSlider(
          label: "Ambiente",
          value: _ambienceVolume,
          onChanged: (v) {
            setState(() {
              _ambienceVolume = v;
              AudioManager().setAmbienceVolume(v);
            });
          },
        ),

        SizedBox(height: spacingSmall),

        // Botão Voltar
        _ImageButton(
          imagePath: 'assets/images/hud/button_back.png',
          size: buttonImageSize * 1.3,
          onPressed: () {
            AudioManager().playSfx("button_back.mp3");
            widget.onBack();
          },
          tooltip: 'Voltar ao Menu de Pausa',
        ),
      ],
    );
  }
}

// PauseMenu PRINCIPAL
class PauseMenu extends StatefulWidget {
  final BonfireGame game;

  const PauseMenu({super.key, required this.game});

  @override
  State<PauseMenu> createState() => _PauseMenuState();
}

class _PauseMenuState extends State<PauseMenu> {
  bool _showAudioMenu = false;

  @override
  Widget build(BuildContext context) {
    final player = widget.game.player as HumanPlayer;

    final Size screenSize = MediaQuery.of(context).size;

    //altura do menu
    final double menuHeight = screenSize.height * 0.85;
    final double menuWidth = screenSize.width * 0.5;

    final double titleFontSize = menuHeight * 0.05;
    final double bodyFontSize = menuHeight * 0.04;

    //espaçamento do menu
    final double spacingSmall = menuHeight * 0.02;
    final double spacingLarge = menuHeight * 0.08;
    //padding vertical
    final double spacingExtraLarge = menuHeight * 0.115;

    final double buttonImageSize = menuWidth * 0.15;

    return Material(
      color: Colors.black.withOpacity(0.7),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Center(
          child: Container(
            child: Center(
              child: Container(
                width: menuWidth,
                height: menuHeight,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: const AssetImage(
                      'assets/images/hud/settingsMenu.png',
                    ),
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.none,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: menuWidth * 0.17,
                    vertical: spacingExtraLarge,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _showAudioMenu
                        ? AudioSettingsMenu(
                            key: const ValueKey('AudioMenu'),
                            menuHeight:
                                menuHeight, // Passa a altura para o submenu
                            onBack: () {
                              setState(() {
                                _showAudioMenu = false;
                              });
                            },
                          )
                        : Column(
                            key: const ValueKey('PauseMenuMain'),
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Jogo Pausado',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                  shadows: const [
                                    Shadow(
                                      offset: Offset(1, 1),
                                      blurRadius: 1,
                                      color: Colors.black,
                                    ),
                                    Shadow(
                                      offset: Offset(-1, -1),
                                      blurRadius: 1,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: spacingLarge),

                              // --- Informações do Jogador ---
                              Text(
                                'Dia: ${player.diasPassados}',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: spacingSmall),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Hora: ${player.tempoFormatado}',
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontFamily: 'monospace',
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Icon(
                                    player.isDia
                                        ? Icons.sunny
                                        : Icons.nightlight_round,
                                    size: bodyFontSize,
                                    color: player.isDia
                                        ? const Color.fromARGB(
                                            240,
                                            255,
                                            235,
                                            59,
                                          )
                                        : const Color.fromARGB(
                                            240,
                                            224,
                                            224,
                                            224,
                                          ),
                                    shadows: const [
                                      Shadow(
                                        offset: Offset(1, 1),
                                        blurRadius: 1,
                                        color: Colors.black,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: spacingSmall),
                              Text(
                                'Dinheiro: ${player.dinheiro} ₿',
                                style: TextStyle(
                                  fontSize: bodyFontSize,
                                  fontFamily: 'monospace',
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: spacingSmall),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Reputação: ',
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontFamily: 'monospace',
                                      color: Colors.white,
                                    ),
                                  ),
                                  Text(
                                    '${_getReputationStatus(player.reputacao)} (${player.reputacao})',
                                    style: TextStyle(
                                      fontSize: bodyFontSize,
                                      fontFamily: 'monospace',
                                      fontWeight: FontWeight.bold,
                                      color: _getReputationColor(
                                        player.reputacao,
                                      ),
                                      shadows: const [
                                        Shadow(
                                          offset: Offset(1, 1),
                                          blurRadius: 1,
                                          color: Colors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              //Configurar Som
                              _TextualImageButton(
                                text: 'Configurar Som',
                                imagePath: 'assets/images/hud/empty_button.png',
                                onPressed: () {
                                  setState(() {
                                    AudioManager().playSfx("button_press.mp3");
                                    _showAudioMenu = true;
                                  });
                                },
                                width: menuWidth * 0.35,
                                height: menuHeight * 0.1,
                                fontSize: bodyFontSize,
                              ),
                              // Botões Retomar, Sair, Salvar
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  // Botão Retomar
                                  _ImageButton(
                                    imagePath:
                                        'assets/images/hud/button_play.png',
                                    size: buttonImageSize,
                                    onPressed: () {
                                      AudioManager().playSfx("button_back.mp3");
                                      widget.game.overlays.remove('pauseMenu');
                                      widget.game.resumeEngine();
                                    },
                                    tooltip: 'Retomar Jogo',
                                  ),

                                  // Botão Sair
                                  _ImageButton(
                                    imagePath:
                                        'assets/images/hud/button_house.png',
                                    size: buttonImageSize,
                                    onPressed: () async {
                                      AudioManager().playSfx("button_back.mp3");
                                      widget.game.resumeEngine();
                                      widget.game.overlays.remove('pauseMenu');
                                      gameSession.currentState = null;

                                      await BlackOverlayNavigator.pushReplacementWithBlackFade(
                                        context,
                                        const MainMenu(),
                                        fadeIn: const Duration(
                                          milliseconds: 600,
                                        ),
                                        hold: const Duration(milliseconds: 200),
                                        fadeOut: const Duration(
                                          milliseconds: 700,
                                        ),
                                      );
                                    },
                                    tooltip: 'Sair para o Menu Principal',
                                  ),

                                  // Botão Salvar
                                  _ImageButton(
                                    imagePath:
                                        'assets/images/hud/button_save.png',
                                    size: buttonImageSize,
                                    onPressed: () async {
                                      final player = widget.game.player;
                                      if (player is HumanPlayer) {
                                        await gameSession.save(player);
                                        if (context.mounted) {
                                          AudioManager().playSfx("mail.mp3");
                                          print("salvando jogo...");
                                          rootScaffoldMessengerKey.currentState
                                              ?.showSnackBar(
                                                SnackBar(
                                                  content: const Text(
                                                    "Jogo salvo com sucesso!",
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  backgroundColor: Colors.green
                                                      .withOpacity(0.8),
                                                  duration: const Duration(
                                                    seconds: 2,
                                                  ),
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                ),
                                              );
                                        }
                                      }
                                    },
                                    tooltip: 'Salvar Jogo',
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// WIDGETS AUXILIARES
class _ImageButton extends StatelessWidget {
  final String imagePath;
  final double size;
  final VoidCallback onPressed;
  final String? tooltip;

  const _ImageButton({
    required this.imagePath,
    required this.size,
    required this.onPressed,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Tooltip(
        message: tooltip ?? '',
        child: Image.asset(
          imagePath,
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.none,
        ),
      ),
    );
  }
}

class _AudioSlider extends StatelessWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _AudioSlider({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final double maxSliderWidth = MediaQuery.of(context).size.width * 0.35;

    return SizedBox(
      width: maxSliderWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
          ),
          Slider(
            value: value,
            min: 0,
            max: 1,
            divisions: 10,
            label: (value * 100).toInt().toString(),
            onChanged: onChanged,
            activeColor: Colors.white,
            inactiveColor: Colors.grey,
            thumbColor: Colors.white,
          ),
        ],
      ),
    );
  }
}

//widget auxiliar do botão de configurar os sons
class _TextualImageButton extends StatelessWidget {
  final String text;
  final String imagePath;
  final VoidCallback onPressed;
  final double width;
  final double height;
  final double fontSize;

  const _TextualImageButton({
    required this.text,
    required this.imagePath,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.fill,
            filterQuality: FilterQuality.none,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize * 0.65,
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}
