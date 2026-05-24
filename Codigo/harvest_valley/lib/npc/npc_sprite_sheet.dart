import 'package:bonfire/bonfire.dart';

class NpcSpritesheet {
  final String path;
  final double stepTime;
  final Vector2 frameSize;

  NpcSpritesheet({required this.path, this.stepTime = 0.2, Vector2? frameSize})
    : frameSize = frameSize ?? Vector2.all(32);

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
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(0, 0),
    ),
  );

  Future<SpriteAnimation> get idleRight => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(0, frameSize.y * 2),
    ),
  );

  Future<SpriteAnimation> get idleUp => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(0, frameSize.y * 4),
    ),
  );

  Future<SpriteAnimation> get idleLeft => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(0, frameSize.y * 6),
    ),
  );

  // --- RUN ---
  Future<SpriteAnimation> get runDown => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(frameSize.x * 2, 0),
    ),
  );

  Future<SpriteAnimation> get runRight => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(frameSize.x * 2, frameSize.y * 2),
    ),
  );

  Future<SpriteAnimation> get runUp => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(frameSize.x * 2, frameSize.y * 4),
    ),
  );

  Future<SpriteAnimation> get runLeft => SpriteAnimation.load(
    path,
    SpriteAnimationData.sequenced(
      amount: 2,
      stepTime: stepTime,
      textureSize: frameSize,
      texturePosition: Vector2(frameSize.x * 2, frameSize.y * 6),
    ),
  );
}
