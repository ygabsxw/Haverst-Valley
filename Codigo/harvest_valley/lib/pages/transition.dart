import 'dart:async';
import 'package:flutter/material.dart';

/// Widget interno que cuida do fade in/out com vsync próprio.
class _BlackOverlayFader extends StatefulWidget {
  final Duration fadeIn;
  final Duration fadeOut;
  final Duration hold;
  final VoidCallback onFadeInCompleted;
  final VoidCallback onFadeOutCompleted;

  const _BlackOverlayFader({
    required this.fadeIn,
    required this.fadeOut,
    required this.hold,
    required this.onFadeInCompleted,
    required this.onFadeOutCompleted,
  });

  @override
  State<_BlackOverlayFader> createState() => _BlackOverlayFaderState();
}

class _BlackOverlayFaderState extends State<_BlackOverlayFader>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.fadeIn);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _runFadeSequence();
  }

  Future<void> _runFadeSequence() async {
    await _controller.forward(); // fade in preto
    widget.onFadeInCompleted();  // sinaliza para o helper navegar
    await Future.delayed(widget.hold); // segura o preto um pouco
    await _controller.animateBack(0.0,
        duration: widget.fadeOut, curve: Curves.easeOut); // fade out do preto
    widget.onFadeOutCompleted(); // sinaliza para remover overlay
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: true,
      child: AnimatedBuilder(
        animation: _opacity,
        builder: (_, __) => Container(
          color: Colors.black.withOpacity(_opacity.value),
        ),
      ),
    );
  }
}

/// Função pública: navega com overlay preto sem acessar context desmontado.
class BlackOverlayNavigator {
  static Future<void> pushReplacementWithBlackFade(
    BuildContext context,
    Widget nextPage, {
    Duration fadeIn = const Duration(milliseconds: 600),
    Duration hold = const Duration(milliseconds: 200),
    Duration fadeOut = const Duration(milliseconds: 700),
  }) async {
    // Capture o navigator e overlay do root ANTES de qualquer await.
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlay = navigator.overlay;
    if (overlay == null) return;

    final fadeInDone = Completer<void>();
    final fadeOutDone = Completer<void>();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _BlackOverlayFader(
        fadeIn: fadeIn,
        fadeOut: fadeOut,
        hold: hold,
        onFadeInCompleted: () {
          if (!fadeInDone.isCompleted) fadeInDone.complete();
        },
        onFadeOutCompleted: () {
          if (!fadeOutDone.isCompleted) fadeOutDone.complete();
        },
      ),
    );

    overlay.insert(entry);

    // Só navegue depois que o preto cobrir tudo.
    await fadeInDone.future;

    // Troca de rota sem animação para evitar “flash” do sistema.
    await navigator.pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => nextPage,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );

    // Espera o fade out terminar e remove o overlay.
    await fadeOutDone.future;
    entry.remove();
  }
}