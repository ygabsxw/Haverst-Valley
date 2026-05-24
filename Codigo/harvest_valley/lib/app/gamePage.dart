import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:harvest_valley/AnimalManager.dart';
import 'package:harvest_valley/FarmTile.dart';
import 'package:harvest_valley/HouseTile.dart'; 
import 'package:harvest_valley/MailBoxTile.dart';
import 'package:harvest_valley/TrashCan.dart';
import 'package:harvest_valley/TrashTile.dart';
import 'package:harvest_valley/app/map/decoration/lightpoint.dart';
import 'package:harvest_valley/app/map/map_sensor.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/pages/pause_menu.dart';
import 'package:harvest_valley/player/person_sprite_sheet.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/player/player_interface.dart';
import 'package:harvest_valley/app/save/game_state.dart';
import 'package:harvest_valley/app/game_components_builder.dart';
import 'package:harvest_valley/app/save/game_session.dart';
import 'package:harvest_valley/app/day_night_system.dart';

class GamePage extends StatefulWidget {
  final GameState? savedState;
  const GamePage({super.key, this.savedState});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  late HumanPlayer player;
  late Vector2 playerPosition;
  late String currentMap;

  final double tileSize = 16.0;
  final double _joystickBaseSize = 80;
  double _joystickScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);

    final savedState = widget.savedState;

    playerPosition = savedState != null
        ? Vector2(savedState.playerX, savedState.playerY)
        : Vector2(tileSize * 69, tileSize * 24); // Posição padrão

    currentMap = savedState?.currentMap ?? 'playerFarm';

    gameSession.currentState ??= GameState(
      currentMap: currentMap,
      playerX: playerPosition.x,
      playerY: playerPosition.y,
      money: savedState?.money ?? 0,
      inventory:
          savedState?.inventory ??
          List.generate(4, (_) => InventorySlotState()),
      collectedItems: savedState?.collectedItems ?? [],
      interactedNpcs: savedState?.interactedNpcs ?? [],
      diasPassados: savedState?.diasPassados ?? 1,
      horarioAtual: savedState?.horarioAtual ?? 360,
      farmTileStates: savedState?.farmTileStates ?? [],
      lastUpdated: DateTime.now().toUtc(),
      reputacao: savedState?.reputacao ?? 50,
      vendeuHoje: savedState?.vendeuHoje ?? false,
      interactedAnimals: savedState?.interactedAnimals ?? [],
      animaisNoCurral: savedState?.animaisNoCurral ?? [],
      activeQuests: savedState?.activeQuests ?? [],
      animalStates: savedState?.animalStates ?? [],
      reciclouHoje: savedState?.reciclouHoje ?? false,
    );

    if (savedState != null) {
      AnimalManager.instance.loadFromStates(savedState.animalStates);
      print("Animais carregados do Hive: ${savedState.animalStates.length}");
    } else {
      AnimalManager.instance.reset();
    }

    player = HumanPlayer(
      position: playerPosition,
      initDirection: Direction.down,
      initialState: savedState,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    gameSession.currentState = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    _joystickScaleFactor = (screenSize.height / 400.0).clamp(0.5, 1.0);
    final double buttonSize = _joystickBaseSize * _joystickScaleFactor;

    // Builder dos objetos do Tiled
    final objectBuilder = {
      'farm': (props) => FarmTile(props.position, props.size),
      'trash': (props) => TrashTile(props.position, props.size),
      'mailBox': (props) => MailBoxTile(props.position, props.size),
      'lightPoint': (props) => Lightpoint(props.position),
      'house': (props) => HouseTile(props.position, props.size),

      'recyclableTrash': (TiledObjectProperties properties) {
        return TrashCan(
          position: properties.position,
          size: properties.size,
          trashType: 'recyclableTrash',
          sprite: null,
        );
      },
      'genericTrash': (TiledObjectProperties properties) {
        return TrashCan(
          position: properties.position,
          size: properties.size,
          trashType: 'genericTrash',
          sprite: null,
        );
      },
      'map_transition': (props) {
        final parts = props.others['targetPosition'].toString().split(',');
        final position = Vector2(
          double.parse(parts[0]) * tileSize,
          double.parse(parts[1]) * tileSize,
        );
        return MapTransitionSensor(
          position: props.position,
          size: props.size,
          targetMap: props.others['targetMap'].toString(),
          targetPosition: position,
          targetDirection: Direction.fromName(
            props.others['targetDirection']?.toString() ?? 'down',
          ),
        );
      },
    };

    return Scaffold(
      body: Stack(
        children: [
          MapNavigator(
            initialMap: currentMap,
            transitionDuration: Duration.zero,

            maps: {
              'playerFarm': (context, args) => MapItem(
                id: 'playerFarm',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled/world/farmv1-0-0.tmj'),
                  objectsBuilder: objectBuilder,
                ),
              ),
              'neighboringFarm': (context, args) => MapItem(
                id: 'neighboringFarm',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset(
                    'tiled/world/neighboringFarmv1-0-0.tmj',
                  ),
                  objectsBuilder: objectBuilder,
                ),
              ),
              'cityMap': (context, args) => MapItem(
                id: 'cityMap',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled/world/cityMap.tmj'),
                  objectsBuilder: objectBuilder,
                ),
              ),
              'beach': (context, args) => MapItem(
                id: 'beach',
                map: WorldMapByTiled(
                  WorldMapReader.fromAsset('tiled/world/beach.tmj'),
                  objectsBuilder: objectBuilder,
                ),
              ),
            },

            builder: (context, arguments, map) {

              gameSession.currentState?.currentMap = map.id;

              if (arguments != null) {
                Vector2? newPosition;
                Direction? newDirection;

                if (arguments is PlayerInitArguments) {
                  newPosition = arguments.playerPosition;
                  newDirection = arguments.playerDirection;
                } else if (arguments is Map) {
                  newPosition = arguments['playerPosition'] as Vector2?;
                  newDirection = arguments['playerDirection'] as Direction?;
                }

                if (newPosition != null) {
                  player.position = newPosition;
                }
                if (newDirection != null) {
                  player.lastDirection = newDirection;
                  player.idle();
                }
              }

              final newBgm = MapTransitionSensor.mapBgm[map.id];
              if (newBgm != null) {
                AudioManager().transitionBgm(newBgm);
              }

              final newAmbience = MapTransitionSensor.mapAmbience[map.id];
              if (newAmbience != null) {
                AudioManager().transitionAmbience(newAmbience);
              } else {
                AudioManager().stopAmbience();
              }

              Future.microtask(() {
                if (mounted) {
                  _controller.reset();
                }
              });

              return BonfireWidget(
                map: map.map,
                player: player,

                onReady: (game) async {
                  game.add(DayNightSystem());

                  await Future.delayed(const Duration(milliseconds: 50));

                  await Future.delayed(const Duration(seconds: 1));

                  if (mounted) _controller.forward();
                },

                lightingColorGame: Colors.black.withValues(alpha: 0.3),
                components: buildMapComponents(
                  map.id,
                  widget.savedState,
                  tileSize,
                ),

                // Controles (Joystick + Teclado)
                playerControllers: [
                  Joystick(
                    directional: JoystickDirectional(
                      color: const Color.fromARGB(248, 217, 217, 217),
                    ),
                    actions: [
                      // Ataque / Ação
                      JoystickAction(
                        actionId: PlayerActionType.attackMelee.index,
                        sprite: Sprite.load('hud/joystick_attack.png').then((
                          sprite,
                        ) {
                          sprite.paint = Paint()
                            ..color = Colors.white.withValues(alpha: 0.8);
                          return sprite;
                        }),
                        size: buttonSize,
                        margin: EdgeInsets.only(
                          bottom: 160 * _joystickScaleFactor,
                          right: 130 * _joystickScaleFactor,
                        ),
                      ),
                      // Arco (Range)
                      JoystickAction(
                        actionId: PlayerActionType.attackRange.index,
                        sprite: Sprite.load('hud/joystick_bowandarrow.png')
                            .then((sprite) {
                              sprite.paint = Paint()
                                ..color = Colors.white.withValues(alpha: 0.8);
                              return sprite;
                            }),
                        size: buttonSize,
                        margin: EdgeInsets.only(
                          bottom: 40 * _joystickScaleFactor,
                          right: 130 * _joystickScaleFactor,
                        ),
                      ),
                      // Regador
                      JoystickAction(
                        actionId: PlayerActionType.wateringCanAction.index,
                        sprite: Sprite.load('hud/joystick_wateringcan.png')
                            .then((sprite) {
                              sprite.paint = Paint()
                                ..color = Colors.white.withValues(alpha: 0.8);
                              return sprite;
                            }),
                        size: buttonSize,
                        margin: EdgeInsets.only(
                          bottom: 100 * _joystickScaleFactor,
                          right: 60 * _joystickScaleFactor,
                        ),
                      ),
                      // Enxada (Hoe)
                      JoystickAction(
                        actionId: PlayerActionType.hoeAction.index,
                        sprite: Sprite.load('hud/joystick_hoe.png').then((
                          sprite,
                        ) {
                          sprite.paint = Paint()
                            ..color = Colors.white.withValues(alpha: 0.8);
                          return sprite;
                        }),
                        size: buttonSize,
                        margin: EdgeInsets.only(
                          bottom: 100 * _joystickScaleFactor,
                          right: 200 * _joystickScaleFactor,
                        ),
                      ),
                    ],
                  ),
                  Keyboard(
                    config: KeyboardConfig(
                      directionalKeys: [
                        KeyboardDirectionalKeys.arrows(),
                        KeyboardDirectionalKeys.wasd(),
                      ],
                      acceptedKeys: [
                        LogicalKeyboardKey.space,
                        LogicalKeyboardKey.keyZ,
                        LogicalKeyboardKey.keyX,
                        LogicalKeyboardKey.keyC,
                      ],
                    ),
                  ),
                ],
                interface: PlayerInterface(),
                overlayBuilderMap: {
                  'pauseMenu': (context, game) => PauseMenu(game: game),
                },
                cameraConfig: CameraConfig(
                  zoom: getZoomFromMaxVisibleTile(context, tileSize, 20),
                  moveOnlyMapArea: true,
                ),
                backgroundColor: const Color(0xff20a0b4),
                debugMode: false,
              );
            },
          ),

          AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return IgnorePointer(
                ignoring: _opacity.value == 0,
                child: Container(
                  color: Colors.black.withValues(alpha: _opacity.value),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
