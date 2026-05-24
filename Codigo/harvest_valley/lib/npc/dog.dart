import 'package:bonfire/bonfire.dart';
import 'dog_sprite_sheet.dart';
import 'animal.dart';
import 'package:harvest_valley/player/human.dart';

// Nó do algoritmo A* (sem diagonais nesse caso)
// Cada nó representa uma célula do grid
// g = custo do caminho até aqui
// h = heurística (distância estimada até o objetivo)
// f = g + h
// parent = nó anterior no caminho
class _Node {
  final int x, y;
  double g;
  double h;
  double f;
  _Node? parent;

  _Node(this.x, this.y) : g = double.infinity, h = 0.0, f = double.infinity;
}

class Dog extends Animal {
  // Lista de células do caminho calculado no A*
  List<Vector2> _path = [];

  // Grid de colisão do mapa (0 = livre, 1 = bloqueado)
  late List<List<int>> _collisionGrid;

  // Tamanho de cada célula em pixels (igual ao tileSize do mapa)
  final double cellSize = 16;

  Dog({
    required super.id,
    required Vector2 position,
    required Vector2 size,
    required String specie,
    required DogSpriteSheet spriteSheet,
    double speed = 30,
    double wanderArea = 200,
    Direction lookDirection = Direction.down,
  }) : super(
         position: position,
         size: size,
         specie: specie,
         spriteSheet: spriteSheet,
         animation: spriteSheet.simpleAnimation(),
         speed: speed,
         wanderArea: wanderArea,
         lookDirection: lookDirection,
         behavior: AnimalBehavior.idle, // força sem wander
       );

  @override
  void onMount() {
    super.onMount();
    Future.delayed(Duration(milliseconds: 100), () {
      // Aguarda o mapa estar carregado antes de gerar o grid
      _collisionGrid = _generateCollisionGrid();
      print(
        "Grid gerado: ${_collisionGrid.length} x ${_collisionGrid[0].length}",
      );
    });
  }


  @override
  void update(double dt) {
    // se existe caminho vai de célula a célula
    if (_path.isNotEmpty) {
      _seguirCaminho();
    }
    super.update(dt);
  }


  // Gera grid de colisão a partir dos componentes do mapa
  // Cada célula do grid representa um tile do mapa
  // Se houver um objeto de colisão ocupando a célula, marca como 1 (bloqueado)
  List<List<int>> _generateCollisionGrid() {
    final worldWidthPx = gameRef.map.width;
    final worldHeightPx = gameRef.map.height;

    final gridWidth = (worldWidthPx / cellSize).ceil();
    final gridHeight = (worldHeightPx / cellSize).ceil();

    final grid = List.generate(gridHeight, (_) => List.filled(gridWidth, 0));

    // Percorre apenas os objetos de colisão
    for (final comp in gameRef.collisions()) {
      if (comp is GameDecoration) {
        final startX = (comp.position.x / cellSize).floor();
        final startY = (comp.position.y / cellSize).floor();
        final endX = ((comp.position.x + comp.size.x) / cellSize).ceil();
        final endY = ((comp.position.y + comp.size.y) / cellSize).ceil();

        for (int y = startY; y < endY; y++) {
          for (int x = startX; x < endX; x++) {
            if (y >= 0 && y < gridHeight && x >= 0 && x < gridWidth) {
              grid[y][x] = 1; // bloqueado
            }
          }
        }
      }
    }

    return grid;
  }

  @override
  void onTap() {
    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    // Cancela o movimento atual
    stopMove();
    idle();
    _path.clear();

    // Converte posição do Dog e do Player para coordenadas de célula
    final dogCell = Vector2(
      (center.x / cellSize).floorToDouble(),
      (center.y / cellSize).floorToDouble(),
    );
    final playerCell = Vector2(
      (player.center.x / cellSize).floorToDouble(),
      (player.center.y / cellSize).floorToDouble(),
    );

    // Aplica o A*
    _path = _aStar(_collisionGrid, dogCell, playerCell);

    if (_path.isNotEmpty) {
      _seguirCaminho();
    } else {
      print("Nenhum caminho encontrado!");
    }

    // Debug
    print("DogCell: $dogCell PlayerCell: $playerCell");
    print(
      "DogCell status -> ${_collisionGrid[dogCell.y.toInt()][dogCell.x.toInt()]}",
    );
    print(
      "PlayerCell status -> ${_collisionGrid[playerCell.y.toInt()][playerCell.x.toInt()]}",
    );
  }

  void _seguirCaminho() {
    if (_path.isEmpty) {
      stopMove();
      idle();
      return;
    }

    // Próxima célula do caminho
    final nextCell = _path.first;

    // Converte célula para coordenadas em pixels
    final targetWorld = Vector2(
      (nextCell.x * cellSize) + cellSize / 2,
      (nextCell.y * cellSize) + cellSize / 2,
    );

    // Diferença entre posição atual e alvo
    final diff = targetWorld - center;


    // Decide direção com base na diferença
    if (diff.x.abs() > diff.y.abs()) {
      if (diff.x > 0) {
        _andarNaDirecao(Direction.right);
      } else {
        _andarNaDirecao(Direction.left);
      }
    } else {
      if (diff.y > 0) {
        _andarNaDirecao(Direction.down);
      } else {
        _andarNaDirecao(Direction.up);
      }
    }

    // Se chegou perto do centro da célula, remove do caminho
    if (diff.length < cellSize) {
      stopMove();
      idle();
      _path.removeAt(0);
    }
  }


  // Algoritmo A* (sem diagonais)
  // Retorna lista de células (Vector2) que compõem o caminho
  List<Vector2> _aStar(List<List<int>> grid, Vector2 start, Vector2 goal) {
    final int width = grid[0].length;
    final int height = grid.length;

    bool inBounds(int x, int y) => x >= 0 && y >= 0 && x < width && y < height;
    String key(int x, int y) => '$x,$y';

    final nodes = <String, _Node>{};
    _Node nodeAt(int x, int y) =>
        nodes.putIfAbsent(key(x, y), () => _Node(x, y));

    final open = <_Node>[]; // lista de nós a explorar

    final closed = <String>{};  // conjunto de nós já explorados

    final sx = start.x.toInt();
    final sy = start.y.toInt();
    final gx = goal.x.toInt();
    final gy = goal.y.toInt();

    // aborta se fora do grid ou bloqueado
    if (!inBounds(sx, sy) || !inBounds(gx, gy)) {
      return []; // aborta se fora do grid
    }

    if (grid[sy][sx] == 1 || grid[gy][gx] == 1) {
      return []; // aborta se célula bloqueada
    }

    // inicializa nó inicial
    final startNode = nodeAt(sx, sy);
    startNode.g = 0.0;
    startNode.h = ((gx - sx).abs() + (gy - sy).abs()).toDouble(); // heurística Manhattan

    startNode.f = startNode.g + startNode.h;
    open.add(startNode);

    // movimentos possíveis (4 direções, excluindo diagonais)
    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];

    // construir caminho
    while (open.isNotEmpty) {
      // seleciona nó com menor f
      open.sort((a, b) => a.f.compareTo(b.f));
      final current = open.removeAt(0);

      // se chegou ao objetivo, reconstrói caminho
      if (current.x == gx && current.y == gy) {
        final path = <Vector2>[];
        _Node? n = current;
        while (n != null) {
          path.add(Vector2(n.x.toDouble(), n.y.toDouble()));
          n = n.parent;
        }
        return path.reversed.toList();
      }

      closed.add(key(current.x, current.y));

      // explora vizinhos
      for (final dir in dirs) {
        final nx = current.x + dir[0];
        final ny = current.y + dir[1];

        if (!inBounds(nx, ny)) continue;
        if (grid[ny][nx] == 1) continue; // celula bloqueada
        if (closed.contains(key(nx, ny))) continue; // obtém ou cria nó vizinho

        final neighbor = nodeAt(nx, ny);

        // custo g até o vizinho = custo atual + 1 (cada passo vale 1)
        final tentativeG = current.g + 1.0;

        // se encontramos um caminho melhor até o vizinho
        if (tentativeG < neighbor.g) {
          neighbor.parent = current;  // registra quem levou até aqui
          neighbor.g = tentativeG;

          // heurística Manhattan: distância em x + distância em y
          neighbor.h = ((gx - nx).abs() + (gy - ny).abs()).toDouble();
          neighbor.f = neighbor.g + neighbor.h;

          // adiciona vizinho à lista de abertos se ainda não estiver lá
          if (!open.contains(neighbor)) {
            open.add(neighbor);
          }
        }
      }
    }

    // se não encontrou caminho retorna lista vazia
    return [];
  }

  // Sprites da animação de andar para as 4 direções
  @override
  void _andarNaDirecao(Direction dir) {
    switch (dir) {
      case Direction.right:
        scale = Vector2(1, 1);
        moveRight(); // animação da direita
        break;
      case Direction.left:
        scale = Vector2(1, 1); //sprite espelhado do da direita
        moveLeft();
        break;
      case Direction.up:
        moveUp();
        break;
      case Direction.down:
        moveDown();
        break;
      default:
        break;
    }
  }
}
