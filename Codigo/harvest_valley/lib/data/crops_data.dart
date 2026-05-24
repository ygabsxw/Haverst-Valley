import 'dart:math';

import 'dart:math';

// tempos alterados para a apresentacao
class CropConfig {
  final String name;
  final int seedPrice;
  final int sellPrice;
  final double growthTimeSec;
  final int dryTimeGameMin;
  final int minYield;
  final int maxYield;
  final int reputationGain;

  const CropConfig({
    required this.name,
    required this.seedPrice,
    required this.sellPrice,
    required this.growthTimeSec,
    required this.dryTimeGameMin,
    required this.minYield,
    required this.maxYield,
    required this.reputationGain,
  });

  int getDynamicSellPrice(int reputation) {
    double multiplier = 1.0;

    if (reputation >= 80) {
      multiplier = 1.20;
    } else if (reputation >= 40) {
      multiplier = 1.0;
    } else {
      multiplier =
          0.60;
    }

    return (sellPrice * multiplier).floor();
  }

  int getDynamicSeedPrice(int reputation) {
    double multiplier = 1.0;

    if (reputation >= 80) {
      multiplier = 0.90;
    } else if (reputation >= 40) {
      multiplier = 1.0;
    } else {
      multiplier = 1.20; 
    }

    return (seedPrice * multiplier).floor();
  }

  int getDynamicYield(int reputation) {
    final Random rng = Random();
    int currentMin = minYield;
    int currentMax = maxYield;

    if (reputation >= 90) {
      if (currentMin < currentMax) currentMin++;
    }

    if (currentMin >= currentMax) return currentMin;
    return currentMin + rng.nextInt(currentMax - currentMin + 1);
  }

  static const Map<String, CropConfig> data = {
    'wheat': CropConfig(
      name: 'Trigo',
      seedPrice: 15,
      sellPrice: 6, 
      growthTimeSec: 8, // tempo normal 60.0 // 1 min
      dryTimeGameMin: 40,
      minYield: 3,
      maxYield: 5,
      reputationGain: 0,
    ),
    'springOnion': CropConfig(
      name: 'Cebolinha',
      seedPrice: 20,
      sellPrice: 12,
      growthTimeSec: 10, // tempo normal 120.0 // 2 min
      dryTimeGameMin: 60,
      minYield: 3,
      maxYield: 5,
      reputationGain: 1,
    ),
    'potato': CropConfig(
      name: 'Batata',
      seedPrice: 50,
      sellPrice: 30,
      growthTimeSec: 10, // tempo normal 300.0 // 5 min
      dryTimeGameMin: 120,
      minYield: 3,
      maxYield: 5,
      reputationGain: 2,
    ),
    'strawberry': CropConfig(
      name: 'Morango',
      seedPrice: 120,
      sellPrice: 55,
      growthTimeSec: 10, // tempo normal 480.0 // 8 min
      dryTimeGameMin: 180,
      minYield: 3,
      maxYield: 6,
      reputationGain: 3,
    ),
    'garlic': CropConfig(
      name: 'Alho',
      seedPrice: 200,
      sellPrice: 180,
      growthTimeSec: 10, // tempo normal 900.0 // 15 min
      dryTimeGameMin: 240,
      minYield: 2,
      maxYield: 3,
      reputationGain: 5,
    ),
  };

  static CropConfig get(String type) {
    return data[type] ??
        const CropConfig(
          name: 'Desconhecido',
          seedPrice: 0,
          sellPrice: 0,
          growthTimeSec: 10,
          dryTimeGameMin: 30,
          minYield: 1,
          maxYield: 1,
          reputationGain: 0,
        );
  }
}

// tempos alterados para a apresentacao
class AnimalConfig {
  final String name;
  final int purchasePrice;
  final String productItem;
  final String productName;
  final int productSellPrice;
  final double productionTimeSec;
  final int reputationGain;
  final int wheatAmountForFeed;
  final int feedIntervalGameMin;

  const AnimalConfig({
    required this.name,
    required this.purchasePrice,
    required this.productItem,
    required this.productName,
    required this.productSellPrice,
    required this.productionTimeSec,
    required this.reputationGain,
    required this.wheatAmountForFeed,
    required this.feedIntervalGameMin,
  });

  int getDynamicProductPrice(int reputation) {
    double multiplier = 1.0;
    if (reputation >= 80) {
      multiplier = 1.20;
    } else if (reputation >= 40) {
      multiplier = 1.0;
    } else {
      multiplier = 0.70; 
    }
    return (productSellPrice * multiplier).floor();
  }

  int getDynamicPurchasePrice(int reputation) {
    double multiplier = 1.0;
    if (reputation >= 80) {
      multiplier = 0.85;
    } else if (reputation >= 40) {
      multiplier = 1.0;
    } else {
      multiplier = 1.30;
    }
    return (purchasePrice * multiplier).floor();
  }

  static const Map<String, AnimalConfig> data = {
    'pintinho': AnimalConfig(
      name: 'Pintinho',
      purchasePrice: 300,
      productItem: 'egg',
      productName: 'Ovo Pequeno',
      productSellPrice: 25,
      productionTimeSec: 5, // tempo normal 120.0 // 2 min
      reputationGain: 1,
      wheatAmountForFeed: 1,
      feedIntervalGameMin: 5, // tempo normal 60.0 // 1 min
    ),
    'galinha': AnimalConfig(
      name: 'Galinha',
      purchasePrice: 800,
      productItem: 'eggBig',
      productName: 'Ovo Grande',
      productSellPrice: 60,
      productionTimeSec: 5, // tempo normal 180.0 // 3 min
      reputationGain: 2,
      wheatAmountForFeed: 2,
      feedIntervalGameMin: 5, // tempo normal 90.0 // 1.5 min
    ),
    'bezerro': AnimalConfig(
      name: 'Bezerro',
      purchasePrice: 1500,
      productItem: 'milk',
      productName: 'Leite Pequeno',
      productSellPrice: 120,
      productionTimeSec: 5, // tempo normal 300.0 // 5 min
      reputationGain: 3,
      wheatAmountForFeed: 3,
      feedIntervalGameMin: 5, // tempo normal 120.0 // 2 min
    ),
    'ovelha': AnimalConfig(
      name: 'Ovelha',
      purchasePrice: 2500,
      productItem: 'wool',
      productName: 'Lã',
      productSellPrice: 180,
      productionTimeSec: 5, // tempo normal 420.0 // 7 min
      reputationGain: 4,
      wheatAmountForFeed: 4,
      feedIntervalGameMin: 5, // tempo normal 150.0 // 2.5 min
    ),
    'cabra': AnimalConfig(
      name: 'Cabra',
      purchasePrice: 3200,
      productItem: 'milkGoat',
      productName: 'Leite de Cabra',
      productSellPrice: 250,
      productionTimeSec: 5, // tempo normal 480.0 // 8 min
      reputationGain: 5,
      wheatAmountForFeed: 4,
      feedIntervalGameMin: 5, // tempo normal 180.0 // 3 min
    ),
    'vaca': AnimalConfig(
      name: 'Vaca',
      purchasePrice: 5000,
      productItem: 'milkBig',
      productName: 'Leite Grande',
      productSellPrice: 350,
      productionTimeSec: 5, // tempo normal 600.0 // 10 min
      reputationGain: 6,
      wheatAmountForFeed: 5,
      feedIntervalGameMin: 5, // tempo normal 240.0 // 4 min
    ),
  };

  static AnimalConfig? getByType(String type) {
    type = type.toLowerCase();
    if (type.contains('pintinho')) return data['pintinho'];
    if (type.contains('bezerro')) return data['bezerro'];
    if (type.contains('galinha')) return data['galinha'];
    if (type.contains('ovelha')) return data['ovelha'];
    if (type.contains('cabra')) return data['cabra'];
    if (type.contains('vaca')) return data['vaca'];
    return null;
  }
}
