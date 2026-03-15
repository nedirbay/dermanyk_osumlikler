import 'dart:io';
import 'package:flutter/material.dart';

class PlantImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  const PlantImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    Widget image;

    if (imageUrl.startsWith('assets/')) {
      image = Image.asset(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    } else if (imageUrl.startsWith('/') || imageUrl.contains('app_flutter/')) {
      // Local file
      image = Image.file(
        File(imageUrl),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    } else if (imageUrl.startsWith('http')) {
      image = Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(context),
      );
    } else {
      image = _buildPlaceholder(context);
    }

    if (borderRadius > 0) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: image,
      );
    }

    return image;
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(
        Icons.eco,
        color: Theme.of(context).primaryColor,
        size: (width != null && width! < 50) ? 20 : 40,
      ),
    );
  }
}
