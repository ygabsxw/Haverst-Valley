// lib/util/sprite_manager.dart
import 'package:bonfire/bonfire.dart';
import 'package:flutter/material.dart';

class SpriteManager {
  static late Sprite dryDirt;
  static late Sprite wetDirt;

  static final List<Sprite> strawberryStages = [];
  static final List<Sprite> springOnionStages = [];
  static final List<Sprite> potatoStages = [];
  static final List<Sprite> garlicStages = [];

  static final Map<String, Sprite> itemSprites = {};

  static late Sprite trashItem;

  static late Sprite mailBoxInteracted;

  static final List<List<Sprite>> wheatStages = [];

  static final Paint greyPaint = Paint()
    ..colorFilter = const ColorFilter.matrix(<double>[
      0.26, 0.26, 0.26, 0, 0, // mistura de cinza mais neutra
      0.26, 0.26, 0.26, 0, 0,
      0.26, 0.26, 0.26, 0, 0,
      0, 0, 0, 1, 0,
    ]);

  static Future<void> load() async {
    final results = await Future.wait([
      // 0: Dry Dirt
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(0, 1088),
        srcSize: Vector2(16, 16),
      ),
      // 1: Wet Dirt
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(0, 1104),
        srcSize: Vector2(16, 16),
      ),

      // --- Morango Stages (2 a 7) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(0, 1328),
        srcSize: Vector2(16, 16),
      ), // Stage 0
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(16, 1328),
        srcSize: Vector2(16, 16),
      ), // Stage 1
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(32, 1328),
        srcSize: Vector2(16, 16),
      ), // Stage 2
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(48, 1328),
        srcSize: Vector2(16, 16),
      ), // Stage 3
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(64, 1328),
        srcSize: Vector2(16, 16),
      ), // Stage 4
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(80, 1328),
        srcSize: Vector2(16, 16),
      ), // Stage 5
      // --- Itens (8 e 9) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(112, 1328),
        srcSize: Vector2(16, 16),
      ), // 8: 'strawberry seed'
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(128, 1328),
        srcSize: Vector2(16, 16),
      ), // 9: 'strawberry item'
      // --- Cebolinha Stages (10 a 15) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(0, 1360),
        srcSize: Vector2(16, 16),
      ), // Stage 0
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(16, 1360),
        srcSize: Vector2(16, 16),
      ), // Stage 1
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(32, 1360),
        srcSize: Vector2(16, 16),
      ), // Stage 2
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(48, 1360),
        srcSize: Vector2(16, 16),
      ), // Stage 3
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(64, 1360),
        srcSize: Vector2(16, 16),
      ), // Stage 4
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(80, 1360),
        srcSize: Vector2(16, 16),
      ), // Stage 5
      // --- Cebolinha Itens (16 e 17) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(112, 1360),
        srcSize: Vector2(16, 16),
      ), // 16: 'springOnion_seed'
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(128, 1360),
        srcSize: Vector2(16, 16),
      ), // 17: 'springOnion_item'
      // --- Batata Stages (18 a 23) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(0, 1392),
        srcSize: Vector2(16, 16),
      ), // Stage 0
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(32, 1392),
        srcSize: Vector2(16, 16),
      ), // Stage 1
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(48, 1392),
        srcSize: Vector2(16, 16),
      ), // Stage 2
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(64, 1392),
        srcSize: Vector2(16, 16),
      ), // Stage 3
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(80, 1392),
        srcSize: Vector2(16, 16),
      ), // Stage 4
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(96, 1392),
        srcSize: Vector2(16, 16),
      ), // Stage 5
      // --- Batata Itens (24 e 25) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(112, 1392),
        srcSize: Vector2(16, 16),
      ), // 24: 'potato_seed'
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(128, 1392),
        srcSize: Vector2(16, 16),
      ), // 25: 'potato_item'
      // --- Alho Stages (26 a 31) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(0, 1424),
        srcSize: Vector2(16, 16),
      ), // Stage 0
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(16, 1424),
        srcSize: Vector2(16, 16),
      ), // Stage 1
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(32, 1424),
        srcSize: Vector2(16, 16),
      ), // Stage 2
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(48, 1424),
        srcSize: Vector2(16, 16),
      ), // Stage 3
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(64, 1424),
        srcSize: Vector2(16, 16),
      ), // Stage 4
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(80, 1424),
        srcSize: Vector2(16, 16),
      ), // Stage 5
      // --- Alho Itens (32 e 33) ---
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(112, 1424),
        srcSize: Vector2(16, 16),
      ), // 32: 'garlic_seed'
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(128, 1424),
        srcSize: Vector2(16, 16),
      ), // 33: 'garlic_item'
      // trash item
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(400, 384),
        srcSize: Vector2(16, 16),
      ), // 34: 'trash_item'
      //mailbox
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(1216, 1056),
        srcSize: Vector2(16, 16),
      ), // 35: 'mailBox'
      // --- Trigo Stages (36 a 43) ---
      // Stage 1 (Seedling)
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(448, 784),
        srcSize: Vector2(16, 16),
      ), // 36: Base Stage 1
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(448, 768),
        srcSize: Vector2(16, 16),
      ), // 37: Topo Stage 1
      // Stage 2
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(464, 784),
        srcSize: Vector2(16, 16),
      ), // 38: Base Stage 2
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(464, 768),
        srcSize: Vector2(16, 16),
      ), // 39: Topo Stage 2
      // Stage 3
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(480, 784),
        srcSize: Vector2(16, 16),
      ), // 40: Base Stage 3
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(480, 768),
        srcSize: Vector2(16, 16),
      ), // 41: Topo Stage 3
      // Stage 4 (Harvestable)
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(496, 784),
        srcSize: Vector2(16, 16),
      ), // 42: Base Stage 4
      Sprite.load(
        'tiled/world/tileset/texture.png',
        srcPosition: Vector2(496, 768),
        srcSize: Vector2(16, 16),
      ), // 43: Topo Stage 4
      Sprite.load('itens/wheat_seed.png'), // 44: 'wheat_seed'
      Sprite.load('itens/wheat_item.png'), // 45: 'wheat_item'

      /// animals drops
      // calf
      Sprite.load('itens/milk.png'), // 46: 'milk' calf
      // cow
      Sprite.load('itens/milkBig.png'), // 47: 'milkBig' cow

      // goat
      Sprite.load('itens/milkGoat.png'), // 48: 'milkGoat' goat

      // sheep
      Sprite.load('itens/wool.png'), // 49: 'wool' sheep

      // pintinho
      Sprite.load('itens/egg.png'), // 50: 'egg' pintinho
      // chicken
      Sprite.load('itens/eggBig.png'), // 51: 'eggBig' chicken
    ]);

    dryDirt = results[0];
    wetDirt = results[1];

    strawberryStages.clear();
    strawberryStages.add(results[2]); // Stage 0
    strawberryStages.add(results[3]); // Stage 1
    strawberryStages.add(results[4]); // Stage 2
    strawberryStages.add(results[5]); // Stage 3
    strawberryStages.add(results[6]); // Stage 4
    strawberryStages.add(results[7]); // Stage 5

    itemSprites.clear();
    itemSprites['strawberry_seed'] = results[8];
    itemSprites['strawberry_item'] = results[9];

    springOnionStages.clear();
    springOnionStages.add(results[10]); // Stage 0
    springOnionStages.add(results[11]); // Stage 1
    springOnionStages.add(results[12]); // Stage 2
    springOnionStages.add(results[13]); // Stage 3
    springOnionStages.add(results[14]); // Stage 4
    springOnionStages.add(results[15]); // Stage 5

    itemSprites['springOnion_seed'] = results[16];
    itemSprites['springOnion_item'] = results[17];

    potatoStages.clear();
    potatoStages.add(results[18]); // Stage 0
    potatoStages.add(results[19]); // Stage 1
    potatoStages.add(results[20]); // Stage 2
    potatoStages.add(results[21]); // Stage 3
    potatoStages.add(results[22]); // Stage 4
    potatoStages.add(results[23]); // Stage 5

    itemSprites['potato_seed'] = results[24];
    itemSprites['potato_item'] = results[25];

    garlicStages.clear();
    garlicStages.add(results[26]); // Stage 0
    garlicStages.add(results[27]); // Stage 1
    garlicStages.add(results[28]); // Stage 2
    garlicStages.add(results[29]); // Stage 3
    garlicStages.add(results[30]); // Stage 4
    garlicStages.add(results[31]); // Stage 5

    itemSprites['garlic_seed'] = results[32];
    itemSprites['garlic_item'] = results[33];

    trashItem = results[34];
    itemSprites['trash_item'] = results[34];

    mailBoxInteracted = results[35];
    itemSprites['mail_item'] = results[35];

    int offset = 36;

    wheatStages.clear();
    wheatStages.add([
      results[offset + 0],
      results[offset + 1],
    ]); // Stage 1 (0 no jogo)
    wheatStages.add([
      results[offset + 2],
      results[offset + 3],
    ]); // Stage 2 (1 no jogo)
    wheatStages.add([
      results[offset + 4],
      results[offset + 5],
    ]); // Stage 3 (2 no jogo)
    wheatStages.add([results[offset + 6], results[offset + 7]]);

    itemSprites['wheat_seed'] = results[44];
    itemSprites['wheat_item'] = results[45];

    // animals drop

    itemSprites['milk_item'] = results[46];
    itemSprites['milkBig_item'] = results[47];
    itemSprites['milkGoat_item'] = results[48];
    itemSprites['wool_item'] = results[49];
    itemSprites['egg_item'] = results[50];
    itemSprites['eggBig_item'] = results[51];
  }

  static List<Sprite> getWheatSprites(int stage) {
    final index = stage.clamp(0, wheatStages.length - 1);

    if (index >= wheatStages.length) {
      return wheatStages.last;
    }

    return wheatStages[index];
  }

  static Sprite getCropSprite(String type, int stage) {
    if (type == 'strawberry') {
      if (stage >= 0 && stage < strawberryStages.length) {
        return strawberryStages[stage];
      }
    } else if (type == 'springOnion') {
      if (stage >= 0 && stage < springOnionStages.length) {
        return springOnionStages[stage];
      }
    } else if (type == 'potato') {
      if (stage >= 0 && stage < potatoStages.length) {
        return potatoStages[stage];
      }
    } else if (type == 'garlic') {
      if (stage >= 0 && stage < garlicStages.length) {
        return garlicStages[stage];
      }
    }

    return strawberryStages.first;
  }
}
