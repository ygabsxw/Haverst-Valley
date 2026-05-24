import 'package:bonfire/bonfire.dart';
import 'package:bonfire/util/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:harvest_valley/audio/audiomanager.dart';
import 'package:harvest_valley/player/human.dart';

/// Sistema de dia e noite que aplica filtros de cor baseado no horário do jogo
class DayNightSystem extends GameComponent {
  // Períodos do dia (em horas)
  static const int horaManha = 6; // 06:00
  static const int horaInicioTarde = 12; // 12:00
  static const int horaFimTarde = 16; // 16:00
  static const int horaNoite = 18; // 18:00
  static const int horaFimNoite = 6; // 06:00 (próximo dia)

  // Cores e modos de blend para cada período
  static final Map<DayPeriod, PeriodConfig> _periodConfigs = {
    DayPeriod.manha: PeriodConfig(
      colorFilter: const Color.fromARGB(35, 220, 235, 255), // Luz suave e clara
      blendMode: BlendMode.multiply,
      lightingOpacity: 0.0,
    ),
    DayPeriod.inicioTarde: PeriodConfig(
      colorFilter: const Color.fromARGB(15, 255, 255, 240), // Luz amarelada
      blendMode: BlendMode.multiply,
      lightingOpacity: 0.0,
    ),
    DayPeriod.fimTarde: PeriodConfig(
      colorFilter: const Color.fromARGB(70, 255, 180, 90), // Luz alaranjada
      blendMode: BlendMode.multiply,
      lightingOpacity: 0.0,
    ),
    DayPeriod.noite: PeriodConfig(
      colorFilter: const Color.fromARGB(132, 0, 59, 252), // Azul escuro
      blendMode: BlendMode.multiply,
      lightingOpacity: 0.75,
    ),
  };

  DayPeriod? _currentPeriod;
  int? _lastHour;

  @override
  void update(double dt) {
    super.update(dt);

    final player = gameRef.player;
    if (player is! HumanPlayer) return;

    final int hora = player.minutoAtualJogo ~/ 60;

    // Verifica se a hora mudou
    if (_lastHour != hora) {
      _lastHour = hora;

      final newPeriod = _getPeriodFromHour(hora);

      if (newPeriod != _currentPeriod) {
        _currentPeriod = newPeriod;
        _applyPeriodFilter(newPeriod, animate: true);

        // dispara transição de ambiência só uma vez
        if (newPeriod == DayPeriod.noite) {
          AudioManager().transitionAmbience("night_ambience.mp3");
        }
      }
    }
  }

  /// Determina o período do dia baseado na hora
  DayPeriod _getPeriodFromHour(int hora) {
    if (hora >= horaManha && hora < horaInicioTarde) {
      return DayPeriod.manha;
    } else if (hora >= horaInicioTarde && hora < horaFimTarde) {
      return DayPeriod.inicioTarde;
    } else if (hora >= horaFimTarde && hora < horaNoite) {
      return DayPeriod.fimTarde;
    } else {
      return DayPeriod.noite;
    }
  }

  /// Aplica o filtro de cor correspondente ao período
  void _applyPeriodFilter(DayPeriod period, {bool animate = false}) {
    final config = _periodConfigs[period];
    if (config == null) return;

    final duration = animate ? const Duration(seconds: 8) : Duration.zero;
    gameRef.colorFilter?.animateTo(
      config.colorFilter,
      blendMode: config.blendMode,
      duration: duration,
    );

    gameRef.lighting?.animateToColor(
      Colors.black.withValues(alpha: config.lightingOpacity),
      duration: duration,
    );

    if (animate) {
      if (_lastHour != null) {
        print(
          'Sistema Dia/Noite: Mudou para ${period.name} (${_formatHora(_lastHour!)})',
        );
      } else {
        print('Sistema Dia/Noite: Mudou para ${period.name}');
      }
    }
  }

  String _formatHora(int hora) {
    return '${hora.toString().padLeft(2, '0')}:00';
  }

  @override
  void onMount() {
    super.onMount();

    final player = gameRef.player;
    if (player is HumanPlayer) {
      final hora = player.minutoAtualJogo ~/ 60;
      _lastHour = hora;
      _currentPeriod = _getPeriodFromHour(hora);

        _applyPeriodFilter(_currentPeriod!, animate: false);
        print(
          'Sistema Dia/Noite: Inicializado em ${_currentPeriod!.name} (${_formatHora(hora)})',
        );
      
    } else {
      // Se não houver player ainda, evita crash
      _lastHour = null;
      _currentPeriod = null;
    }
  }
}

enum DayPeriod {
  manha,
  inicioTarde,
  fimTarde,
  noite,
}

class PeriodConfig {
  final Color colorFilter;
  final BlendMode blendMode;
  final double lightingOpacity; // Opacidade da escuridão

  PeriodConfig({
    required this.colorFilter,
    required this.blendMode,
    required this.lightingOpacity,
  });
}
