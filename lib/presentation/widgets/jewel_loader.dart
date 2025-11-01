import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class JewelLoader extends StatelessWidget {
  const JewelLoader({super.key, this.label});

  final String? label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withOpacity(0.15), color.withOpacity(0.45)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 16),
          Text(
            label!,
            style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    ).animate().fadeIn(duration: 400.ms).scale(begin: 0.9, end: 1);
  }
}
