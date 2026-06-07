import 'dart:ui';
import 'package:flutter/material.dart';

class CustomGlassCard extends StatelessWidget {
  final Widget child;
  final List<Color> borderColors;

  const CustomGlassCard({
    Key? key,
    required this.child,
    required this.borderColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Il Container esterno crea l'ombra e il bordo a gradiente
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: borderColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3), // Ombra per la Dark Mode
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // Il padding simula lo spessore del bordo (1.5 pixel)
      padding: const EdgeInsets.all(1.5),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22.5), // 24 - 1.5
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // Sfocatura vetro
          child: Container(
            // Sfondo semitrasparente della card (adatta l'opacità in base al tuo tema dark)
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.6),
            child: child,
          ),
        ),
      ),
    );
  }
}