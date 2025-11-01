import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JewelCachedImage extends StatelessWidget {
  const JewelCachedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shimmerBase = theme.colorScheme.surfaceVariant.withOpacity(0.3);
    final shimmerHighlight = theme.colorScheme.surface.withOpacity(0.6);

    Widget child = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit ?? BoxFit.cover,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: shimmerBase,
        highlightColor: shimmerHighlight,
        child: Container(
          width: width,
          height: height,
          color: shimmerBase,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: shimmerBase,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, color: theme.colorScheme.onSurface.withOpacity(0.6)),
      ),
    );

    if (borderRadius != null) {
      child = ClipRRect(borderRadius: borderRadius, child: child);
    }
    return child;
  }
}
