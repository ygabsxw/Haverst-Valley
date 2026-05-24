import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/SpriteManager.dart';
import 'package:harvest_valley/app/save/animal_state.dart';
import 'package:harvest_valley/app/save/farm_state.dart';
import 'package:harvest_valley/app/save/quest_state.dart';
import 'pages/menu.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app/save/game_state.dart';
import 'auth/firebase_options.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:flame_audio/flame_audio.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await SpriteManager.load();

  // inicializar o Hive para carregar o jogo
  await Hive.initFlutter();
  Hive.registerAdapter(GameStateAdapter());
  Hive.registerAdapter(InventorySlotStateAdapter());
  Hive.registerAdapter(FarmTileStatePersistentAdapter());
  Hive.registerAdapter(QuestModelAdapter());
  Hive.registerAdapter(QuestStatusAdapter());
  Hive.registerAdapter(AnimalStatePersistentAdapter());

  // carrega preferências de volume salvas 
  await AudioManager().init();

  // pré-carregar todos os sons
  await FlameAudio.audioCache.loadAll([
    'beach_ambience',
    'beach_bgm',
    'button_press.mp3',
    'farm_bgm',
    'nature_loop.mp3',
    'seagulls_sfx',
    'southfarm_bgm',
    'button_back.mp3',
    'cat_1.mp3',
    'chicken_1.mp3',
    'chicken_2.mp3',
    'chicken_3.mp3',
    'chicken_4.mp3',
    'city_ambience.mp3',
    'cow.mp3',
    'day_start.mp3',
    'dig.mp3',
    'dog.mp3',
    'farm_ambience.mp3',
    'goat.mp3',
    'mail.mp3',
    'money.mp3',
    'night_ambience.mp3',
    'night_start.mp3',
    'pickup.mp3',
    'sheep.mp3',
    'trash.mp3',
    'walk_1.mp3',
    'walk_2.mp3',
    'walk_3.mp3',
    'watering.mp3',
]);


  runApp(const MyAppRoot());
}

class MyAppRoot extends StatelessWidget {
  const MyAppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      debugShowCheckedModeBanner: false,
      home: const MainMenu(),
    );
  }
}
