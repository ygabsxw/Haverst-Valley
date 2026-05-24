import 'package:bonfire/bonfire.dart';

enum PersonAttackEnum {
  meleeDown,
  meleeUp,
  meleeLeft,
  meleeRight,
  meleeUpRight,
  meleeDownRight,
  meleeUpLeft,
  meleeDownLeft,
  rangeDown,
  rangeUp,
  rangeLeft,
  rangeRight,
  rangeUpRight,
  rangeDownRight,
  rangeUpLeft,
  rangeDownLeft,
}

enum PersonHoeEnum {
  hoeDown,
  hoeUp,
  hoeLeft,
  hoeRight,
  hoeUpRight,
  hoeDownRight,
  hoeUpLeft,
  hoeDownLeft,
}

enum PersonWateringCanEnum {
  wateringCanDown,
  wateringCanUp,
  wateringCanLeft,
  wateringCanRight,
  // wateringCanUpRight,
  // wateringCanDownRight,
  // wateringCanUpLeft,
  // wateringCanDownLeft,
}

enum PlayerActionType { attackMelee, attackRange, hoeAction, wateringCanAction }

class PersonSpritesheet {
  final String path;

  PersonSpritesheet({this.path = '/players/human.png'});

  SimpleDirectionAnimation simpleAnimation() {
    return SimpleDirectionAnimation(
      idleRight: getIdleRight,
      idleDown: getIdleDown,
      idleUp: getIdleUp,
      idleDownRight: getIdleDownRight,
      idleDownLeft: getIdleDownLeft,
      idleUpLeft: getIdleUpLeft,
      idleUpRight: getIdleUpRight,
      runRight: getRunRight,
      runDown: getRunDown,
      runUp: getRunUp,
      runDownRight: getRunDownRight,
      runUpRight: getRunUpRight,
      runUpLeft: getRunUpLeft,
      runDownLeft: getRunDownLeft,
      others: {
        // melee attack
        PersonAttackEnum.meleeDown: getAttackMeleeDown,
        PersonAttackEnum.meleeUp: getAttackMeleeUp,
        PersonAttackEnum.meleeLeft: getAttackMeleeLeft,
        PersonAttackEnum.meleeRight: getAttackMeleeRight,
        PersonAttackEnum.meleeUpRight: getAttackMeleeUpRight,
        PersonAttackEnum.meleeUpLeft: getAttackMeleeUpLeft,
        PersonAttackEnum.meleeDownRight: getAttackMeleeDownRight,
        PersonAttackEnum.meleeDownLeft: getAttackMeleeDownLeft,
        // range attack
        PersonAttackEnum.rangeDown: getAttackRangeDown,
        PersonAttackEnum.rangeUp: getAttackRangeUp,
        PersonAttackEnum.rangeLeft: getAttackRangeLeft,
        PersonAttackEnum.rangeRight: getAttackRangeRight,
        PersonAttackEnum.rangeUpRight: getAttackRangeUpRight,
        PersonAttackEnum.rangeUpLeft: getAttackRangeUpLeft,
        PersonAttackEnum.rangeDownRight: getAttackRangeDownRight,
        PersonAttackEnum.rangeDownLeft: getAttackRangeDownLeft,
        // hoe
        PersonHoeEnum.hoeDown: getHoeDown,
        PersonHoeEnum.hoeUp: getHoeUp,
        PersonHoeEnum.hoeLeft: getHoeLeft,
        PersonHoeEnum.hoeRight: getHoeRight,
        PersonHoeEnum.hoeUpRight: getHoeUpRight,
        PersonHoeEnum.hoeDownRight: getHoeDownRight,
        PersonHoeEnum.hoeUpLeft: getHoeUpLeft,
        PersonHoeEnum.hoeDownLeft: getHoeDownLeft,
        // watering can
        PersonWateringCanEnum.wateringCanDown: getWateringCanDown,
        PersonWateringCanEnum.wateringCanUp: getWateringCanUp,
        PersonWateringCanEnum.wateringCanLeft: getWateringCanLeft,
        PersonWateringCanEnum.wateringCanRight: getWateringCanRight,
        // PersonWateringCanEnum.wateringCanUpRight: getWateringCanUpRight,
        // PersonWateringCanEnum.wateringCanDownRight: getWateringCanDownRight,
        // PersonWateringCanEnum.wateringCanUpLeft: getWateringCanUpLeft,
        // PersonWateringCanEnum.wateringCanDownLeft: getWateringCanDownLeft,
      },
    );
  }

  Future<SpriteAnimation> get getIdleDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 4),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 1),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getIdleDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(0, 32 * 7),
      ),
    );
  }

  get getRunRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 2),
      ),
    );
  }

  get getRunDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 0),
      ),
    );
  }

  get getRunUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 4),
      ),
    );
  }

  get getRunDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 1),
      ),
    );
  }

  get getRunUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 3),
      ),
    );
  }

  get getRunUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 5),
      ),
    );
  }

  get getRunDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 2,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(64, 32 * 7),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 0),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 4),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 6),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackMeleeDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 5, 32 * 7),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 0),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 4),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 6),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getAttackRangeDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 9, 32 * 7),
      ),
    );
  }

  // Enxada (Plantar)
  Future<SpriteAnimation> get getHoeDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 0),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeDownRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 1),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 2),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeUpRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 3),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 4),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeUpLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 5),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 6),
      ),
    );
  }

  Future<SpriteAnimation> get getHoeDownLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.sequenced(
        amount: 3,
        stepTime: 0.2,
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 13, 32 * 7),
      ),
    );
  }

  Future<SpriteAnimation> get getWateringCanDown {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.variable(
        amount: 3,
        stepTimes: [0.2, 0.2, 0.6],
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 16, 0),
      ),
    );
  }

  // Future<SpriteAnimation> get getWateringCanDownRight {
  //   return SpriteAnimation.load(
  //     path,
  //     SpriteAnimationData.variable(
  //       amount: 3,
  //       stepTimes: [0.2, 0.2, 0.4],
  //       textureSize: Vector2.all(32),
  //       texturePosition: Vector2(32 * 16, 32 * 1), // Coluna 17, Linha 2
  //     ),
  //   );
  // }

  Future<SpriteAnimation> get getWateringCanRight {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.variable(
        amount: 3,
        stepTimes: [0.2, 0.2, 0.6],
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 16, 32 * 2), // Coluna 17, Linha 3
      ),
    );
  }

  // Future<SpriteAnimation> get getWateringCanUpRight {
  //   return SpriteAnimation.load(
  //     path,
  //     SpriteAnimationData.sequenced(
  //       amount: 3,
  //       stepTime: 0.2,
  //       textureSize: Vector2.all(32),
  //       texturePosition: Vector2(32 * 16, 32 * 3), // Coluna 17, Linha 4
  //     ),
  //   );
  // }

  Future<SpriteAnimation> get getWateringCanUp {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.variable(
        amount: 3,
        stepTimes: [0.2, 0.2, 0.6],
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 16, 32 * 4), // Coluna 17, Linha 5
      ),
    );
  }

  // Future<SpriteAnimation> get getWateringCanUpLeft {
  //   return SpriteAnimation.load(
  //     path,
  //     SpriteAnimationData.sequenced(
  //       amount: 3,
  //       stepTime: 0.2,
  //       textureSize: Vector2.all(32),
  //       texturePosition: Vector2(32 * 16, 32 * 5), // Coluna 17, Linha 6
  //     ),
  //   );
  // }

  Future<SpriteAnimation> get getWateringCanLeft {
    return SpriteAnimation.load(
      path,
      SpriteAnimationData.variable(
        amount: 3,
        stepTimes: [0.2, 0.2, 0.6],
        textureSize: Vector2.all(32),
        texturePosition: Vector2(32 * 16, 32 * 6), // Coluna 17, Linha 7
      ),
    );
  }

  // Future<SpriteAnimation> get getWateringCanDownLeft {
  //   return SpriteAnimation.load(
  //     path,
  //     SpriteAnimationData.sequenced(
  //       amount: 3,
  //       stepTime: 0.2,
  //       textureSize: Vector2.all(32),
  //       texturePosition: Vector2(32 * 16, 32 * 7), // Coluna 17, Linha 8
  //     ),
  //   );
  // }
}
