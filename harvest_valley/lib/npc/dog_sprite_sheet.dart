import 'package:bonfire/bonfire.dart';

class DogSpriteSheet {
  final String path;
  final double stepTime;
  final Vector2 frameSize;

  DogSpriteSheet({
    required this.path,
    this.stepTime = 0.1,
    Vector2? frameSize,
  }) : frameSize = frameSize ?? Vector2(32, 32);

  SimpleDirectionAnimation simpleAnimation() {
    return SimpleDirectionAnimation(
      idleDown: idleDown,
      idleUp: idleUp,
      idleRight: idleRight,
      runDown: runDown,
      runUp: runUp,
      runRight: runRight,
    );
  }

  // --- IDLE ---
  Future<SpriteAnimation> get idleDown => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, 0), // linha 0
        ),
      );

  Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y), // linha 1
        ),
      );

  //Future<SpriteAnimation> get idleLeft => idleRight; // reaproveita

  Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y * 2), // linha 2
        ),
      );

  // --- RUN ---
  Future<SpriteAnimation> get runDown => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y * 3), // linha 3
        ),
      );

  Future<SpriteAnimation> get runRight => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y * 4), // linha 4
        ),
      );

  //Future<SpriteAnimation> get runLeft => runRight; // reaproveita

  Future<SpriteAnimation> get runUp => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y * 5), // linha 5
        ),
      );
}