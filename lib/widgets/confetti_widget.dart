import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart' as confetti;
import '../utils/theme.dart';

class ConfettiWidget extends StatefulWidget {
  final bool isActive;
  final Widget child;

  const ConfettiWidget({
    super.key,
    required this.isActive,
    required this.child,
  });

  @override
  State<ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<ConfettiWidget> {
  late confetti.ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = confetti.ConfettiController(duration: const Duration(seconds: 3));
  }

  @override
  void didUpdateWidget(ConfettiWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _confettiController.play();
    }
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.isActive)
          Align(
            alignment: Alignment.topCenter,
            child: confetti.ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: 1.57, // Down
              shouldLoop: false,
              colors: const [
                ShrexTheme.primaryColor,
                ShrexTheme.secondaryColor,
                ShrexTheme.accentColor,
                ShrexTheme.successColor,
              ],
            ),
          ),
      ],
    );
  }
}