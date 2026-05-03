import 'package:flutter/material.dart';
import 'package:myscooter/core/services/local_image_cache.dart';

class ScooterHeaderImage extends StatelessWidget {
  final String? imgPath;
  final String scooterId;
  final VoidCallback onTap;

  const ScooterHeaderImage({super.key, required this.imgPath, required this.scooterId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 140, height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.blue.withValues(alpha: 0.5), width: 3),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: ClipOval(
            child: Hero(
              tag: 'scooter_image_$scooterId',
              child: CloudSyncImage(imagePath: imgPath, width: 140, height: 140),
            ),
          ),
        ),
      ),
    );
  }
}