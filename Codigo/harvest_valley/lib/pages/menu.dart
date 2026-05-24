import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvest_valley/AnimalManager.dart';
import 'package:harvest_valley/FarmManager.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/pages/login/accountPage.dart';
import '../app/gamePage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login/loginPage.dart';
import '../app/save/game_storage.dart';
import '../app/save/game_session.dart';
import '../app/save/game_state.dart';
import 'package:harvest_valley/pages/transition.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

  //tela de transição
  Future<void> _startGame(BuildContext context, GameState state) async {
    await BlackOverlayNavigator.pushReplacementWithBlackFade(
      context,
      GamePage(savedState: state),
      fadeIn: const Duration(milliseconds: 600),
      hold: const Duration(milliseconds: 200),
      fadeOut: const Duration(milliseconds: 700),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    AudioManager().playBgm("city_ambience.mp3");
    final double menuHeight = screenSize.height * 0.85;
    // final double menuWidth = screenSize.width * 0.5;

    final double responsiveAreaWidth = screenSize.width * 0.8;
    double buttonWidth = (responsiveAreaWidth - 20) / 2;
    buttonWidth = buttonWidth.clamp(130.0, 180.0);
    final double buttonHeight = buttonWidth * (100 / 180);

    // final double spacingSmall = menuHeight * 0.03;
    // final double spacingMedium = menuHeight * 0.05;
    final double spacingLarge = menuHeight * 0.09;
    // final double spacingExtraLarge = menuHeight * 0.115;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hud/background_menu.gif',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Expanded(flex: 1, child: SizedBox()),
                      Center(child: _styledBackgroundLogo()),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: IconButton(
                            icon: const Icon(Icons.account_circle),
                            iconSize: 60,
                            color: Colors.white,
                            onPressed: () {
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const AccountPage(),
                                  ),
                                );
                              } else {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: spacingLarge),

                  // Botões em duas colunas
                  Expanded(
                    child: SingleChildScrollView(
                      // Adicionei um padding embaixo para o último botão não colar na borda
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        alignment: WrapAlignment.center,
                        children: [
                          _styledButton(
                            text: "Novo",
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () {
                              AudioManager().playSfx("button_press.mp3");
                              FarmManager.instance.reset();
                              AnimalManager.instance.reset();

                              final newState = GameState(
                                currentMap: 'playerFarm',
                                playerX: 69 * 16,
                                playerY: 24 * 16,
                                money: 0,
                                inventory: List.generate(
                                  4,
                                  (_) => InventorySlotState(),
                                ),
                                collectedItems: [],
                                interactedNpcs: [],
                                diasPassados: 1,
                                horarioAtual: 360,
                                farmTileStates: [],
                                lastUpdated: DateTime.now().toUtc(),
                                reputacao: 50,
                                vendeuHoje: false,
                                interactedAnimals: [],
                                animaisNoCurral: [],
                                activeQuests: [],
                                animalStates: [],
                                reciclouHoje: false,
                              );
                              gameSession.currentState = newState;
                              _startGame(context, newState);
                            },
                          ),
                          _styledButton(
                            text: "Carregar",
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () async {
                              AudioManager().playSfx("button_press.mp3");
                              final saved = await GameStorage.loadGame();
                              if (saved != null) {
                                FarmManager.instance.reset();
                                AnimalManager.instance.reset();

                                if (saved.farmTileStates.isNotEmpty) {
                                  FarmManager.instance.loadFromStates(
                                    saved.farmTileStates,
                                  );
                                }
                                if (saved.animalStates.isNotEmpty) {
                                  AnimalManager.instance.loadFromStates(
                                    saved.animalStates,
                                  );
                                }

                                gameSession.currentState = saved;
                                _startGame(context, saved);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Nenhum save encontrado"),
                                  ),
                                );
                              }
                            },
                          ),
                          _styledButton(
                            text: "Créditos",
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () {
                              AudioManager().playSfx("button_press.mp3");
                              Navigator.of(
                                context,
                              ).push(_fadeRoute(const CreditsScreen()));
                            },
                          ),
                          _styledButton(
                            text: "Sair",
                            width: buttonWidth,
                            height: buttonHeight,
                            onPressed: () {
                              AudioManager().playSfx("button_press.mp3");
                              if (Platform.isAndroid || Platform.isIOS) {
                                SystemNavigator.pop();
                              } else {
                                exit(0);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledBackgroundLogo() {
    return SizedBox(
      width: 550,
      height: 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/hud/backgroundLogo.png'),
                fit: BoxFit.fill,
                filterQuality: FilterQuality.none,
              ),
            ),
            child: SizedBox.expand(),
          ),

          SizedBox(
            width: 300,
            height: 220,
            child: Image.asset(
              'assets/images/hud/newLogo.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledButton({
    required String text,
    required VoidCallback onPressed,
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: InkWell(
        onTap: onPressed,
        child: DecoratedBox(
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage('assets/images/hud/backgroundButton.png'),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Route _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}

class CreditsScreen extends StatelessWidget {
  const CreditsScreen({super.key});

  Future<void> _openGithub(String url, BuildContext context) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Não foi possível abrir o link.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final creators = [
      {
        "name": "Arthur Costa",
        "image": "https://github.com/sevak19.png",
        "github": "https://github.com/sevak19",
      },
      {
        "name": "Felipe Guerzoni",
        "image": "https://github.com/flp2113.png",
        "github": "https://github.com/flp2113",
      },
      {
        "name": "Gabriel Costa",
        "image": "https://github.com/gabriel-vianna1.png",
        "github": "https://github.com/gabriel-vianna1",
      },
      {
        "name": "Gabriel Diniz",
        "image": "https://github.com/ygabsxw.png",
        "github": "https://github.com/ygabsxw",
      },
      {
        "name": "Matheus Silva",
        "image": "https://github.com/MatheusSCxr.png",
        "github": "https://github.com/MatheusSCxr",
      },
      {
        "name": "Pedro Felix",
        "image": "https://github.com/Pedro-HFelix.png",
        "github": "https://github.com/Pedro-HFelix",
      },
    ];

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/hud/background_menu.gif',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withOpacity(0.5)),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 60),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Créditos",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 20,
                  runSpacing: 30,
                  children: creators.map((c) {
                    return SizedBox(
                      width: 170,
                      child: Card(
                        color: Colors.white.withOpacity(0.95),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 8,
                          ),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () => _openGithub(c["github"]!, context),
                                child: CircleAvatar(
                                  backgroundImage: NetworkImage(c["image"]!),
                                  radius: 60,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                c["name"]!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextButton.icon(
                                icon: const Icon(
                                  Icons.link,
                                  color: Colors.blue,
                                ),
                                label: const Text(
                                  "GitHub",
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onPressed: () =>
                                    _openGithub(c["github"]!, context),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: 200,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.brown.shade700,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.black54,
                      elevation: 6,
                      textStyle: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Voltar"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
