import 'package:bonfire/bonfire.dart';
import 'package:harvest_valley/npc/animal.dart';


enum WalkAxis { horizontal, vertical }


class Cat extends Animal {
  Cat({
    required super.id,
    required super.position,
    required super.size,
    required super.spriteSheet,
    required SimpleDirectionAnimation super.animation,
    required super.specie,
    super.behavior = AnimalBehavior.wander,
    super.maxWait = 1,
    double super.speed = 10,
    super.wanderArea = 200,
    Direction lookDirection = Direction.down,
  });
  
}
