import 'dart:io';
import 'package:flutter/material.dart';

class ScooterHeaderImage extends StatelessWidget {
  final String? imgPath;
  final int scooterId;
  final VoidCallback onTap;

  const ScooterHeaderImage({
    super.key,
    required this.imgPath,
    required this.scooterId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasImage = imgPath != null && File(imgPath!).existsSync();

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
              child: hasImage
                  ? Image.file(File(imgPath!), fit: BoxFit.cover)
                  : Container(
                color: Colors.grey[200],
                child: const Icon(Icons.moped, size: 50, color: Colors.blue),
              ),
            ),
          ),
        ),
      ),
    );
  }
}