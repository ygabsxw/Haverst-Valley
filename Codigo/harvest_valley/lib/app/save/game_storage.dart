import 'package:hive/hive.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'game_state.dart';

class GameStorage {
  static const String boxName = 'game_state';

  static String? get _userId {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static DocumentReference<GameState>? _getFirebaseDocRef() {
    final userId = _userId;
    if (userId == null) return null;

    return FirebaseFirestore.instance
        .collection('game_saves')
        .doc(userId)
        .collection('save_slots')
        .doc('save1')
        .withConverter<GameState>(
          fromFirestore: (snapshot, _) => GameState.fromJson(snapshot.data()!),
          toFirestore: (state, _) => state.toJson(),
        );
  }

  static Future<void> _saveLocal(GameState state) async {
    final box = await Hive.openBox<GameState>(boxName);
    await box.put('save1', state);
  }

  static Future<void> _saveCloud(GameState state) async {
    final docRef = _getFirebaseDocRef();
    if (docRef != null) {
      try {
        await docRef.set(state, SetOptions(merge: true));
        print("Jogo salvo na nuvem com sucesso.");
      } catch (e) {
        print("Erro ao salvar na nuvem: $e");
      }
    } else {
      print("Usuário não logado. Salvando apenas localmente.");
    }
  }

  static Future<GameState?> _fetchCloudState() async {
    final docRef = _getFirebaseDocRef();
    if (docRef == null) {
      print("Usuário não logado, não é possível carregar da nuvem.");
      return null;
    }

    try {
      final docSnap = await docRef.get();
      if (docSnap.exists) {
        print("Save encontrado na nuvem.");
        return docSnap.data();
      }
    } catch (e) {
      print("Erro ao carregar da nuvem: $e");
    }

    print("Nenhum save encontrado na nuvem.");
    return null;
  }

  static Future<void> saveGame(GameState state) async {
    final stateToSave = state.copyWith(lastUpdated: DateTime.now().toUtc());

    await Future.wait([_saveLocal(stateToSave), _saveCloud(stateToSave)]);
  }

  static Future<GameState?> loadGame() async {
    print("Carregando saves local e da nuvem para comparação...");

    final box = await Hive.openBox<GameState>(boxName);

    GameState? rawLocalState = box.get('save1');
    GameState? localState;

    if (rawLocalState != null) {
      localState = GameState.fromJson(rawLocalState.toJson());
    }

    final cloudState = await _fetchCloudState();

    if (localState == null && cloudState == null) {
      print("Nenhum save encontrado em lugar nenhum.");
      return null;
    }

    if (localState == null && cloudState != null) {
      print("Apenas save da nuvem encontrado. Salvando localmente");
      await _saveLocal(cloudState);
      return cloudState;
    }

    if (localState != null && cloudState == null) {
      print("Apenas save local encontrado. Enviando para nuvem");
      await _saveCloud(localState);
      return localState;
    }

    if (localState != null && cloudState != null) {
      if (cloudState.lastUpdated.isAfter(localState.lastUpdated)) {
        print("Save da nuvem é mais recente.");
        await _saveLocal(cloudState);
        return cloudState;
      } else {
        print("Save local é mais recente (ou igual).");
        await _saveCloud(localState);
        return localState;
      }
    }

    return null;
  }
}
