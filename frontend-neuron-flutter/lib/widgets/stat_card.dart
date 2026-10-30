import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/knowledge_stat_model.dart';
import 'neuron_card.dart';

class StatCard extends StatelessWidget {
  const StatCard({super.key, required this.stat});

  final KnowledgeStatModel stat;

  @override
  Widget build(BuildContext context) {
    return NeuronCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: stat.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(stat.icon, color: stat.color, size: 20),
          ),
          const SizedBox(height: 14),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryText(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryText(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            stat.description,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.secondaryText(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 24,
            child: CustomPaint(
              size: const Size(double.infinity, 24),
              painter: _TrendLinePainter(color: stat.color.withValues(alpha: 0.5)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendLinePainter extends CustomPainter {
  _TrendLinePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.4, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.1, size.width * 0.8, size.height * 0.4);
    path.quadraticBezierTo(size.width * 0.9, size.height * 0.55, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
