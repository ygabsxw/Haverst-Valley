import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/player/person_sprite_sheet.dart';
import 'package:harvest_valley/player/human.dart';
import 'package:harvest_valley/audio/audiomanager.dart';

class MapTransitionSensor extends GameDecoration with Sensor<HumanPlayer> {
  bool _hasContact = false;
  final String targetMap;
  final Vector2 targetPosition;
  final Direction targetDirection;

  // Mapeamento de BGM
  static final Map<String, String> mapBgm = {
    'playerFarm': 'farm_bgm.mp3',
    'neighboringFarm': 'southfarm_bgm.mp3',
    'cityMap': 'city_bgm.mp3',
    'beach': 'beach_bgm.mp3',
  };

  // Mapeamento de Efeitos
  static final Map<String, String> mapAmbience = const {
    'playerFarm': 'farm_ambience.mp3',
    'neighboringFarm': 'farm_ambience.mp3',
    'cityMap': 'city_ambience.mp3',
    'beach': 'beach_ambience.mp3',
  };

  MapTransitionSensor({
    required super.position,
    required super.size,
    required this.targetMap,
    required this.targetPosition,
    this.targetDirection = Direction.down,
  });

  @override
  void onContact(HumanPlayer component) {
    if (!_hasContact) {
      _hasContact = true;

      // Obtém o ID do mapa atual
      // final currentMapId = gameRef.map; // Bonfire fornece o ID do mapa atual

      // // Obtém os nomes dos arquivos BGM
      // final newBgm = mapBgm[targetMap];
      // // print("indo para id $currentMapId -> $targetMap");
      // final currentBgm = mapBgm[currentMapId];

      // if (newBgm != null && currentBgm != newBgm) {
      //   //inicia a transição de BGM de forma assíncrona
      //   AudioManager().transitionBgm(newBgm);
      // }

      // final newAmbience = mapAmbience[targetMap];
      // final currentAmbience = mapAmbience[currentMapId];

      // if (newAmbience != null && currentAmbience != newAmbience) {
      //   // Inicia a transição de ambiência
      //   AudioManager().transitionAmbience(newAmbience);
      // }
      MapNavigator.of(context).toNamed(
        targetMap,
        arguments: PlayerInitArguments(
          playerPosition: targetPosition,
          playerDirection: targetDirection,
        ),
      );
    }
    super.onContact(component);
  }
}
