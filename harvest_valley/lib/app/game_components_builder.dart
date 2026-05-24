import 'dart:math';

import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/AnimalManager.dart';
// import 'package:harvest_valley/app/map/item/seed/wheat.dart';
import 'package:harvest_valley/data/dialogue_data.dart';
import 'package:harvest_valley/npc/animal.dart';
import 'package:harvest_valley/npc/animal_sprite_sheet.dart';
import 'package:harvest_valley/npc/cat.dart';
import 'package:harvest_valley/npc/dog.dart';
import 'package:harvest_valley/npc/dog_sprite_sheet.dart';
// import 'map/item/seed/strawberry.dart';
// import 'map/item/seed/springOnion.dart';
// import 'map/item/seed/potato.dart';
// import 'map/item/seed/garlic.dart';
import '../npc/npc.dart';
import '../npc/npc_sprite_sheet.dart';
import 'save/game_state.dart';

List<GameComponent> buildMapComponents(
  String mapId,
  GameState? state,
  double tileSize,
) {
  final comps = <GameComponent>[];

  // farm

  if (mapId == 'playerFarm') {
    //   if (state == null ||
    //       !state.collectedItems.contains('playerFarm:strawberry_1')) {
    //     comps.add(
    //       StrawberryItem(
    //         Vector2(tileSize * 73, tileSize * 28),
    //         'playerFarm:strawberry_1',
    //       ),
    //     );
    //   }
    //   if (state == null || !state.collectedItems.contains('playerFarm:wheat_1')) {
    //     comps.add(
    //       wheatItem(Vector2(tileSize * 73, tileSize * 27), 'playerFarm:wheat_1'),
    //     );
    //   }
    //   if (state == null ||
    //       !state.collectedItems.contains('playerFarm:springOnion_1')) {
    //     comps.add(
    //       SpringOnionItem(
    //         Vector2(tileSize * 21, tileSize * 14), // posicao armazem
    //         'playerFarm:springOnion_1',
    //       ),
    //     );
    //   }
    //   if (state == null ||
    //       !state.collectedItems.contains('playerFarm:potato_1')) {
    //     comps.add(
    //       PotatoItem(
    //         Vector2(tileSize * 73, tileSize * 30),
    //         'playerFarm:potato_1',
    //       ),
    //     );
    //   }
    //   if (state == null ||
    //       !state.collectedItems.contains('playerFarm:garlic_1')) {
    //     comps.add(
    //       GarlicItem(
    //         Vector2(tileSize * 73, tileSize * 31),
    //         'playerFarm:garlic_1',
    //       ),
    //     );
    //   }

    // if (state == null || !state.interactedNpcs.contains('playerFarm:mayor')) {
    //   comps.add(
    //     NPC(
    //       name: "Prefeito",
    //       occupation: "Prefeito",
    //       dialogues: {
    //         ReputationLevel.bad: DialogueData.prefeitoBad,
    //         ReputationLevel.neutral: DialogueData.prefeitoNeutral,
    //         ReputationLevel.good: DialogueData.prefeitoGood,
    //       },
    //       position: Vector2(tileSize * 69, tileSize * 28),
    //       size: Vector2.all(32),
    //       animation: NpcSpritesheet(path: "npc/mayor.png").simpleAnimation(),
    //       spriteSheet: NpcSpritesheet(path: "npc/mayor.png"),
    //       behavior: NpcBehavior.wander,
    //       lookDirection: Direction.down,
    //       aiTheme: "Sustentabilidade e a importância de cuidar do nosso lixo.",
    //     ),
    //   );
    // }

    if (state == null || !state.interactedAnimals.contains('playerFarm:dog')) {
      comps.add(
        Dog(
          id: "playerFarm:dog",
          position: Vector2(tileSize * 71, tileSize * 28),
          size: Vector2.all(tileSize),
          spriteSheet: DogSpriteSheet(path: "animals/dog.png"),
          specie: "dog",
          wanderArea: 100,
        ),
      );
    }

    if (state == null || !state.interactedAnimals.contains('playerFarm:cat')) {
      comps.add(
        Cat(
          id: "playerFarm:cat",
          position: Vector2(tileSize * 73, tileSize * 28),
          size: Vector2.all(tileSize * 0.8),
          speed: 20,
          spriteSheet: AnimalSpritesheet(path: "animals/cat_orange.png"),
          animation: AnimalSpritesheet(
            path: "animals/cat_orange.png",
          ).simpleAnimation(),
          specie: "cat",
          wanderArea: 100,
        ),
      );
    }

    // adiciona os animais no animaisNoCurral (map com animais comprados e mandados para o curral) e depois passa para o AnimalManager com AnimalState para cuidar das interacoes etc
    if (state != null &&
        state.animaisNoCurral.isNotEmpty &&
        AnimalManager.instance.getAnimalsToSpawn().isEmpty) {
      print("Carregando animais do save antigo...");

      for (int i = 0; i < state.animaisNoCurral.length; i++) {
        String rawSpecie = state.animaisNoCurral[i];
        String newId = "${rawSpecie}_$i";

        final newState = AnimalRuntimeState(
          id: newId,
          specie: rawSpecie,
          currentStateIndex: 0, // Nasce com fome
          productionTimer: 0,
          x: 0,
          y: 0,
        );

        AnimalManager.instance.updateAnimalState(newId, newState);
      }
    }

    var animalsToSpawn = AnimalManager.instance.getAnimalsToSpawn();

    if (animalsToSpawn.isEmpty &&
        state != null &&
        state.animaisNoCurral.isNotEmpty) {
      print("Carregando animais do save antigo...");
      for (int i = 0; i < state.animaisNoCurral.length; i++) {
        String rawSpecie = state.animaisNoCurral[i];
        String newId = "${rawSpecie}_migrated_$i";

        final newState = AnimalRuntimeState(
          id: newId,
          specie: rawSpecie,
          currentStateIndex: 0,
          productionTimer: 0,
          x: 0,
          y: 0,
        );
        AnimalManager.instance.updateAnimalState(newId, newState);
      }
      animalsToSpawn = AnimalManager.instance.getAnimalsToSpawn();
      state.animaisNoCurral.clear();
    }

    if (animalsToSpawn.isNotEmpty) {
      for (var animalState in animalsToSpawn) {
        String spritePath = "";
        String specieName = animalState.specie;
        double animalSize = 16.0;

        double minX = 0, maxX = 0, minY = 0, maxY = 0;

        if (specieName.contains('vaca')) {
          minX = 24;
          maxX = 31;
          minY = 37;
          maxY = 40;
          animalSize = 24.0;
          if (specieName.contains('marrom')) {
            spritePath = "animals/cow_brown.png";
          } else if (specieName.contains('branca')) {
            spritePath = "animals/cow_white.png";
          } else if (specieName.contains('malhada')) {
            spritePath = "animals/cow_holstein.png";
          }
        } else if (specieName.contains('bezerro')) {
          minX = 24;
          maxX = 31;
          minY = 37;
          maxY = 40;
          animalSize = 16.0;
          if (specieName.contains('marrom')) {
            spritePath = "animals/calf_brown.png";
          } else if (specieName.contains('branco')) {
            spritePath = "animals/calf_white.png";
          } else if (specieName.contains('malhado')) {
            spritePath = "animals/calf_holstein.png";
          }
        } else if (specieName.contains('galinha') ||
            specieName.contains('pintinho')) {
          minX = 13;
          maxX = 18;
          minY = 24;
          maxY = 26;
          animalSize = 16.0;
          if (specieName.contains('pintinho')) {
            spritePath = "animals/chicken_chick.png";
          } else {
            spritePath = "animals/chicken_hen.png";
          }
        } else if (specieName.contains('ovelha')) {
          minX = 11;
          maxX = 18;
          minY = 37;
          maxY = 40;
          spritePath = "animals/sheep.png";
          animalSize = 16.0;
        } else if (specieName.contains('cabra')) {
          minX = 27;
          maxX = 31;
          minY = 23;
          maxY = 25;
          spritePath = "animals/goat.png";
          animalSize = 16.0;
        }

        if (spritePath.isNotEmpty) {
          Vector2 finalPosition;

          if (animalState.x != 0 && animalState.y != 0) {
            finalPosition = Vector2(animalState.x, animalState.y);
          } else {
            final Random rng = Random();
            double areaWidth = maxX - minX;
            double areaHeight = maxY - minY;
            double spawnX =
                (minX * tileSize) + (rng.nextDouble() * areaWidth * tileSize);
            double spawnY =
                (minY * tileSize) + (rng.nextDouble() * areaHeight * tileSize);

            finalPosition = Vector2(spawnX, spawnY);

            animalState.x = spawnX;
            animalState.y = spawnY;
            AnimalManager.instance.updateAnimalState(
              animalState.id,
              animalState,
            );
          }

          comps.add(
            Animal(
              id: animalState.id,
              position: finalPosition,
              size: Vector2.all(animalSize),
              spriteSheet: AnimalSpritesheet(
                path: spritePath,
                frameSize: Vector2.all(animalSize),
              ),
              animation: AnimalSpritesheet(
                path: spritePath,
                frameSize: Vector2.all(animalSize),
              ).simpleAnimation(),
              specie: specieName,
              wanderArea: 80,
            ),
          );
        }
      }
    }
  }

  // city
  if (mapId == 'cityMap') {
    if (state == null || !state.interactedNpcs.contains('cityMap:mayor')) {
      comps.add(
        NPC(
          name: "Prefeito",
          occupation: "Prefeito",
          dialogues: {
            ReputationLevel.bad: DialogueData.prefeitoBad,
            ReputationLevel.neutral: DialogueData.prefeitoNeutral,
            ReputationLevel.good: DialogueData.prefeitoGood,
          },
          position: Vector2(tileSize * 44.5, tileSize * 33),
          size: Vector2.all(32),
          animation: NpcSpritesheet(path: "npc/mayor.png").simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/mayor.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme: "Sustentabilidade e a importância de cuidar do nosso lixo.",
        ),
      );
    }

    if (state == null || !state.interactedNpcs.contains('cityMap:market')) {
      comps.add(
        NPC(
          name: "Carlos",
          occupation: "Mercador",
          dialogues: {
            ReputationLevel.bad: DialogueData.carlosBad,
            ReputationLevel.neutral: DialogueData.carlosNeutral,
            ReputationLevel.good: DialogueData.carlosGood,
          },
          position: Vector2(tileSize * 8, tileSize * 23),
          size: Vector2.all(32),
          animation: NpcSpritesheet(path: "npc/market.png").simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/market.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A importância do comércio justo e do apoio aos produtores locais.",
        ),
      );
    }

    if (state == null ||
        !state.interactedNpcs.contains('cityMap:native_american')) {
      comps.add(
        NPC(
          name: "Taina",
          occupation: "Indígena",
          dialogues: {
            ReputationLevel.bad: DialogueData.tainaBad,
            ReputationLevel.neutral: DialogueData.tainaNeutral,
            ReputationLevel.good: DialogueData.tainaGood,
          },
          position: Vector2(tileSize * 94, tileSize * 11.5),
          size: Vector2.all(32),
          animation: NpcSpritesheet(
            path: "npc/native_american.png",
          ).simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/native_american.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A conexão espiritual com a terra e a importância da agricultura sustentável.",
        ),
      );
    }

    if (state == null || !state.interactedNpcs.contains('cityMap:women')) {
      comps.add(
        NPC(
          name: "Bianca",
          occupation: "",
          dialogues: {
            ReputationLevel.bad: DialogueData.biancaBad,
            ReputationLevel.neutral: DialogueData.biancaNeutral,
            ReputationLevel.good: DialogueData.biancaGood,
          },
          position: Vector2(tileSize * 49, tileSize * 11),
          size: Vector2.all(32),
          animation: NpcSpritesheet(path: "npc/women.png").simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/women.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A vida urbana moderna e os desafios de manter conexões genuínas.",
        ),
      );
    }

    if (state == null || !state.interactedNpcs.contains('cityMap:women2')) {
      comps.add(
        NPC(
          name: "Violeta",
          occupation: "",
          dialogues: {
            ReputationLevel.bad: DialogueData.violetaBad,
            ReputationLevel.neutral: DialogueData.violetaNeutral,
            ReputationLevel.good: DialogueData.violetaGood,
          },
          position: Vector2(tileSize * 49, tileSize * 52),
          size: Vector2.all(32),
          animation: NpcSpritesheet(path: "npc/women2.png").simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/women2.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A busca por identidade pessoal e a exploração de diferentes estilos de vida.",
        ),
      );
    }
  }

  // beach

  if (mapId == 'beach') {
    if (state == null || !state.interactedNpcs.contains('beach:surf')) {
      comps.add(
        NPC(
          name: "Gabriel",
          occupation: "Surfista",
          dialogues: {
            ReputationLevel.bad: DialogueData.gabrielBad,
            ReputationLevel.neutral: DialogueData.gabrielNeutral,
            ReputationLevel.good: DialogueData.gabrielGood,
          },
          position: Vector2(tileSize * 44, tileSize * 23),
          size: Vector2.all(32),
          animation: NpcSpritesheet(path: "npc/surf.png").simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/surf.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A cultura do surf e a conexão profunda com o oceano e a natureza.",
        ),
      );
    }
  }

  // neighboring farm

  if (mapId == 'neighboringFarm') {
    if (state == null ||
        !state.interactedNpcs.contains('neighboringFarm:womenFarm')) {
      comps.add(
        NPC(
          name: "Clara",
          occupation: "Agricultora",
          dialogues: {
            ReputationLevel.bad: DialogueData.claraBad,
            ReputationLevel.neutral: DialogueData.claraNeutral,
            ReputationLevel.good: DialogueData.claraGood,
          },
          position: Vector2(tileSize * 77, tileSize * 20),
          size: Vector2.all(32),
          animation: NpcSpritesheet(
            path: "npc/womenFarm.png",
          ).simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/womenFarm.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A dedicação à agricultura sustentável e a importância da comunidade rural.",
        ),
      );
    }

    if (state == null ||
        !state.interactedNpcs.contains('neighboringFarm:scientist')) {
      comps.add(
        NPC(
          name: "Dr. Lucas",
          occupation: "Cientista Ambiental",
          dialogues: {
            ReputationLevel.bad: DialogueData.lucasBad,
            ReputationLevel.neutral: DialogueData.lucasNeutral,
            ReputationLevel.good: DialogueData.lucasGood,
          },
          position: Vector2(tileSize * 4, tileSize * 16),
          size: Vector2.all(32),
          animation: NpcSpritesheet(
            path: "npc/scientist.png",
          ).simpleAnimation(),
          spriteSheet: NpcSpritesheet(path: "npc/scientist.png"),
          behavior: NpcBehavior.idle,
          lookDirection: Direction.down,
          aiTheme:
              "A importância da pesquisa científica na conservação ambiental e na sustentabilidade.",
        ),
      );
    }

    if (state == null ||
        !state.interactedAnimals.contains('neighboringFarm:sheep')) {
      comps.add(
        Animal(
          id: "neighboringFarm:sheep",
          position: Vector2(tileSize * 81, tileSize * 28),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/sheep.png"),
          specie: "sheep",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/sheep.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:sheep",
          position: Vector2(tileSize * 82, tileSize * 30),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/sheep.png"),
          specie: "sheep",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/sheep.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:sheep",
          position: Vector2(tileSize * 85, tileSize * 28),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/sheep.png"),
          specie: "sheep",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/sheep.png",
          ).simpleAnimation(),
        ),
      );
    }

    if (state == null ||
        !state.interactedAnimals.contains('neighboringFarm:calf')) {
      comps.add(
        Animal(
          id: "neighboringFarm:calf_holstein",
          position: Vector2(tileSize * 68, tileSize * 27),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/calf_holstein.png"),
          specie: "calf",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/calf_holstein.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:calf_brown",
          position: Vector2(tileSize * 73, tileSize * 28),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/calf_brown.png"),
          specie: "calf",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/calf_brown.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:calf_white",
          position: Vector2(tileSize * 72, tileSize * 30),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/calf_white.png"),
          specie: "calf",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/calf_white.png",
          ).simpleAnimation(),
        ),
      );
    }

    if (state == null ||
        !state.interactedAnimals.contains('neighboringFarm:cow')) {
      comps.add(
        Animal(
          id: "neighboringFarm:cow_holstein",
          position: Vector2(tileSize * 68, tileSize * 27),
          size: Vector2.all(24),
          spriteSheet: AnimalSpritesheet(
            path: "animals/cow_holstein.png",
            frameSize: Vector2.all(24),
          ),
          specie: "cow",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/cow_holstein.png",
            frameSize: Vector2.all(24),
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:cow_brown",
          position: Vector2(tileSize * 73, tileSize * 28),
          size: Vector2.all(24),
          spriteSheet: AnimalSpritesheet(
            path: "animals/cow_brown.png",
            frameSize: Vector2.all(24),
          ),
          specie: "cow",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/cow_brown.png",
            frameSize: Vector2.all(24),
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:cow_white",
          position: Vector2(tileSize * 72, tileSize * 30),
          size: Vector2.all(24),
          spriteSheet: AnimalSpritesheet(
            path: "animals/cow_white.png",
            frameSize: Vector2.all(24),
          ),
          specie: "cow",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/cow_white.png",
            frameSize: Vector2.all(24),
          ).simpleAnimation(),
        ),
      );
    }

    if (state == null ||
        !state.interactedAnimals.contains('neighboringFarm:goat')) {
      comps.add(
        Animal(
          id: "neighboringFarm:goat",
          position: Vector2(tileSize * 94, tileSize * 6),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/goat.png"),
          specie: "goat",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/goat.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:goat",
          position: Vector2(tileSize * 95, tileSize * 9),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/goat.png"),
          specie: "goat",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/goat.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:goat",
          position: Vector2(tileSize * 97, tileSize * 7),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/goat.png"),
          specie: "goat",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/goat.png",
          ).simpleAnimation(),
        ),
      );
    }

    if (state == null ||
        !state.interactedAnimals.contains('neighboringFarm:chicken_chick')) {
      comps.add(
        Animal(
          id: "neighboringFarm:chicken_chick",
          position: Vector2(tileSize * 110, tileSize * 26),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/chicken_chick.png"),
          specie: "pintinho",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/chicken_chick.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:chicken_chick",
          position: Vector2(tileSize * 108, tileSize * 29),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/chicken_chick.png"),
          specie: "pintinho",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/chicken_chick.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:chicken_chick",
          position: Vector2(tileSize * 116, tileSize * 24),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/chicken_chick.png"),
          specie: "pintinho",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/chicken_chick.png",
          ).simpleAnimation(),
        ),
      );
    }

    if (state == null ||
        !state.interactedAnimals.contains('neighboringFarm:chicken_hen')) {
      comps.add(
        Animal(
          id: "neighboringFarm:chicken_hen",
          position: Vector2(tileSize * 112, tileSize * 29),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/chicken_hen.png"),
          specie: "chicken_hen",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/chicken_hen.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:chicken_hen",
          position: Vector2(tileSize * 111, tileSize * 27),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/chicken_hen.png"),
          specie: "chicken_hen",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/chicken_hen.png",
          ).simpleAnimation(),
        ),
      );
      comps.add(
        Animal(
          id: "neighboringFarm:chicken_hen",
          position: Vector2(tileSize * 117, tileSize * 26),
          size: Vector2.all(16),
          spriteSheet: AnimalSpritesheet(path: "animals/chicken_hen.png"),
          specie: "chicken_hen",
          wanderArea: 80,
          animation: AnimalSpritesheet(
            path: "animals/chicken_hen.png",
          ).simpleAnimation(),
        ),
      );
    }
  }

  return comps;
}
