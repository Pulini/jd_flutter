import 'dart:math';
import 'package:flutter/material.dart';

/// 截图风格的圆形进度环 + 中心百分比文字
class RingProgress extends StatelessWidget {
  final double value;     // 0.0 ~ 1.0
  final String label;     // 环内文字（如 "22.99%"）
  final String subLabel;  // 环下小字（如 "日完成率"）
  final double size;
  final double strokeWidth;
  final Color trackColor;
  final Color progressColor;
  final Color? centerTextColor;
  final Color? subTextColor;

  const RingProgress({
    super.key,
    required this.value,
    required this.label,
    required this.subLabel,
    this.size = 72,
    this.strokeWidth = 7,
    this.trackColor = const Color(0xFFB3E5FC),
    this.progressColor = const Color(0xFFFFF176), // 截图中用黄色高亮
    this.centerTextColor,
    this.subTextColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size, height: size,
          child: CustomPaint(
            painter: _RingPainter(
              value: value.clamp(0.0, 1.0),
              trackColor: trackColor,
              progressColor: progressColor,
              strokeWidth: strokeWidth,
            ),
            child: Center(
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: size * 0.155,
                  fontWeight: FontWeight.w700,
                  color: centerTextColor ?? const Color(0xFF37474F),
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subLabel,
          style: TextStyle(
            fontSize: 11,
            color: subTextColor ?? const Color(0xFF607D8B),
          ),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double value;
  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;

  const _RingPainter({
    required this.value,
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // track
    canvas.drawArc(
      rect,
      -pi / 2,
      2 * pi,
      false,
      Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round,
    );

    // progress arc
    if (value > 0) {
      canvas.drawArc(
        rect,
        -pi / 2,
        2 * pi * value,
        false,
        Paint()
          ..color = progressColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.value != value ||
      oldDelegate.progressColor != progressColor;
}
