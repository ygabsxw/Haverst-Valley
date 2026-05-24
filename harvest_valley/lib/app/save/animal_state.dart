import 'package:hive/hive.dart';

part 'animal_state.g.dart';

@HiveType(typeId: 5) 
class AnimalStatePersistent extends HiveObject {
  @HiveField(0)
  final String id; 

  @HiveField(1)
  final String specie;

  @HiveField(2)
  int currentStateIndex; 

  @HiveField(3)
  double productionTimer;

  @HiveField(4)
  double x;

  @HiveField(5)
  double y;

  AnimalStatePersistent({
    required this.id,
    required this.specie,
    this.currentStateIndex = 0,
    this.productionTimer = 0.0,
    this.x = 0.0,
    this.y = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specie': specie,
      'currentStateIndex': currentStateIndex,
      'productionTimer': productionTimer,
      'x': x,
      'y': y,
    };
  }

  factory AnimalStatePersistent.fromJson(Map<String, dynamic> json) {
    return AnimalStatePersistent(
      id: json['id'],
      specie: json['specie'],
      currentStateIndex: json['currentStateIndex'],
      productionTimer: (json['productionTimer'] as num).toDouble(),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
    );
  }
}