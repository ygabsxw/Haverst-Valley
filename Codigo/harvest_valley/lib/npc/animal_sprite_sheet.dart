import 'package:bonfire/bonfire.dart';

class AnimalSpritesheet {
  final String path;
  final double stepTime;
  final Vector2 frameSize;

  AnimalSpritesheet({
    required this.path,
    this.stepTime = 0.2,
    Vector2? frameSize,
  }) : frameSize = frameSize ?? Vector2(16, 16);

  SimpleDirectionAnimation simpleAnimation() {
    return SimpleDirectionAnimation(
      idleDown: idleDown,
      idleUp: idleUp,
      idleLeft: idleLeft,
      idleRight: idleRight,
      runDown: runDown,
      runUp: runUp,
      runLeft: runLeft,
      runRight: runRight,
    );
  }

  // --- IDLE ---
  Future<SpriteAnimation> get idleDown => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, 0),
        ),
      );

  Future<SpriteAnimation> get idleLeft => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y),
        ),
      );

  Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y * 2),
        ),
      );

  Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 1,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(frameSize.x, frameSize.y * 3),
        ),
      );

  // --- RUN (3 frames por linha) ---
  Future<SpriteAnimation> get runDown => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(0, 0),
        ),
      );

  Future<SpriteAnimation> get runLeft => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(0, frameSize.y),
        ),
      );

  Future<SpriteAnimation> get runRight => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(0, frameSize.y * 2),
        ),
      );

  Future<SpriteAnimation> get runUp => SpriteAnimation.load(
        path,
        SpriteAnimationData.sequenced(
          amount: 3,
          stepTime: stepTime,
          textureSize: frameSize,
          texturePosition: Vector2(0, frameSize.y * 3),
        ),
      );
}