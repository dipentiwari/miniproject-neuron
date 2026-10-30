import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class NeuronLogo extends StatelessWidget {
  const NeuronLogo({
    super.key,
    this.size = 48,
    this.showText = true,
    this.compact = false,
  });

  final double size;
  final bool showText;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(size * 0.28),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.psychology_outlined,
            color: Colors.white,
            size: size * 0.55,
          ),
        ),
        if (showText) ...[
          SizedBox(width: compact ? 8 : 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Neuron',
                style: TextStyle(
                  fontSize: compact ? 16 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryText(context),
                  letterSpacing: -0.5,
                ),
              ),
              if (!compact)
                Text(
                  'Your Second Brain',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.secondaryText(context),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
