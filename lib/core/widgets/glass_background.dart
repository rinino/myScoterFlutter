import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBackground extends StatelessWidget {
  final Color primaryColor;
  final Color secondaryColor;

  const GlassBackground({
    super.key,
    this.primaryColor = Colors.blue,
    this.secondaryColor = Colors.cyan,
  });

  @override
  Widget build(BuildContext context) {
    // Colore di fondo base in base al tema (chiaro/scuro)
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Colors.black : Colors.grey.shade100;

    return Stack(
      children: [
        // Sfondo solido base
        Container(color: backgroundColor),

        // Cerchio in alto a sinistra
        Positioned(
          top: -100,
          left: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withOpacity(0.15),
            ),
          ),
        ),

        // Cerchio in basso a destra
        Positioned(
          bottom: -50,
          right: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: secondaryColor.withOpacity(0.15),
            ),
          ),
        ),

        // Filtro sfocatura che applica l'effetto a tutto ciò che c'è sotto
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }
}