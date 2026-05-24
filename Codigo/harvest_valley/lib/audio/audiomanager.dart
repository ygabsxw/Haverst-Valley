import 'package:flame_audio/flame_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AudioManager {
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  final Map<String, AudioPlayer> _activeLoops = {};
  bool _muted = false;

  String? _currentBgm;
  String? _currentAmbience;
  double bgmVolume = 0.7;
  double sfxVolume = 0.7;
  double ambienceVolume = 0.5;

  //inicializar carregando preferências salvas
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _muted = prefs.getBool('audio_muted') ?? false;
    bgmVolume = prefs.getDouble('bgm_volume') ?? 0.7;
    sfxVolume = prefs.getDouble('sfx_volume') ?? 0.7;
    ambienceVolume = prefs.getDouble('ambience_volume') ?? 0.5;
  }

  //salvar preferências
  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('audio_muted', _muted);
    await prefs.setDouble('bgm_volume', bgmVolume);
    await prefs.setDouble('sfx_volume', sfxVolume);
    await prefs.setDouble('ambience_volume', ambienceVolume);
  }

  // --- SFX ---
  void playSfx(String file) {
    if (!_muted) FlameAudio.play(file, volume: sfxVolume);
  }

  // --- BGM ---
  void playBgm(String file) {
    if (_currentBgm == file && FlameAudio.bgm.isPlaying) return;

    _currentBgm = file;
    if (!_muted) {
      FlameAudio.bgm.play(file, volume: bgmVolume);
    }
  }

  void stopBgm() {
    FlameAudio.bgm.stop();
    _currentBgm = null;
  }

  Future<void> transitionBgm(String newFile) async {
    if (_currentBgm == newFile) return;
    // Fade out da música atual
    if (newFile.isEmpty) {
      await _fadeOutBgm();
      stopBgm();
      return;
    }

    await _fadeOutBgm();

    _currentBgm = newFile;
    if (!_muted) {
      FlameAudio.bgm.play(newFile, volume: 0);
      await _fadeInBgm();
    }
  }

  Future<void> _fadeOutBgm() async {
    if (!FlameAudio.bgm.isPlaying) return;
    for (double v = bgmVolume; v >= 0; v -= 0.1) {
      FlameAudio.bgm.audioPlayer.setVolume(v);
      await Future.delayed(const Duration(milliseconds: 100));
    }
    FlameAudio.bgm.stop();
  }

  Future<void> _fadeInBgm() async {
    for (double v = 0; v <= bgmVolume; v += 0.1) {
      FlameAudio.bgm.audioPlayer.setVolume(v);
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> transitionAmbience(String newFile) async {
    // Usamos uma chave única para o som de ambiente do mapa
    const String ambienceKey = 'map_ambience_loop';

    if (_currentAmbience == newFile) return;
    _currentAmbience = newFile;

    final currentPlayer = _activeLoops[ambienceKey];

    if (currentPlayer != null) {
      for (double v = ambienceVolume; v >= 0; v -= 0.1) {
        currentPlayer.setVolume(v);
        await Future.delayed(const Duration(milliseconds: 100));
      }
      currentPlayer.stop();
      _activeLoops.remove(ambienceKey);
    }

    if (newFile.isEmpty) return;

    if (!_muted) {
      final newPlayer = await FlameAudio.loop(newFile, volume: 0);
      _activeLoops[ambienceKey] = newPlayer;

      for (double v = 0; v <= ambienceVolume; v += 0.1) {
        newPlayer.setVolume(v);
        await Future.delayed(const Duration(milliseconds: 100));
      }
    }
  }

  void stopAmbience() {
    transitionAmbience(''); // Transição para "nada"
  }

  // --- Controle Geral ---

  void stopAllLoops() {
    for (final player in _activeLoops.values) {
      player.stop();
    }
    _activeLoops.clear();
    stopBgm();
    _currentAmbience = null;
  }

  // --- Mute/Unmute ---
  void muteAll() {
    _muted = true;
    FlameAudio.bgm.audioPlayer.setVolume(0);
    for (final player in _activeLoops.values) {
      player.setVolume(0);
    }
    _savePrefs();
  }

  void unmuteAll() {
    _muted = false;
    FlameAudio.bgm.audioPlayer.setVolume(bgmVolume);
    // Restaura o volume correto da ambiência (não 1.0)
    for (final player in _activeLoops.values) {
      player.setVolume(ambienceVolume);
    }
    _savePrefs();
  }

  bool get isMuted => _muted;

  // --- Ajuste de volumes ---
  void setBgmVolume(double v) {
    bgmVolume = v;
    if (!_muted) FlameAudio.bgm.audioPlayer.setVolume(v);
    _savePrefs();
  }

  void setSfxVolume(double v) {
    sfxVolume = v;
    _savePrefs();
  }

  void setAmbienceVolume(double v) {
    ambienceVolume = v;
    if (!_muted) {
      // Atualiza o player de ambiência ativo
      final player = _activeLoops['map_ambience_loop'];
      if (player != null) player.setVolume(v);
    }
    _savePrefs();
  }

  double get sfxVolumeLevel => sfxVolume;
}
