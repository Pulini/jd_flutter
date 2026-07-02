import 'package:flutter/material.dart';
import 'ring_progress.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final double? rate;
  final String rateLabel;
  final String rateSub;
  final Color? valueColor;

  const StatCard({
    super.key,
    required this.label,
    required this.value,
    required this.sub,
    this.rate,
    this.rateLabel = '',
    this.rateSub = '',
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFF90CAF9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF81D4FA).withValues(alpha: 0.35),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border:
            Border.all(color: const Color(0xFF039BE5).withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF0277BD).withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: valueColor ?? const Color(0xFF0277BD),
                      letterSpacing: -0.3,
                      height: 1.15,
                    )),
                const SizedBox(height: 3),
                Text(sub,
                    style: TextStyle(
                      fontSize: 13,
                      color: const Color(0xFF0277BD).withValues(alpha: 0.5),
                    )),
              ],
            ),
          ),
          if (rate != null) ...[
            const SizedBox(width: 10),
            RingProgress(
              value: rate!,
              label: rateLabel,
              subLabel: rateSub,
              size: 60,
              strokeWidth: 8,
              trackColor:  const Color(0xFF0277BD).withValues(alpha: 0.12),
              progressColor: const Color(0xFF039BE5),
              centerTextColor: const Color(0xFF039BE5),
              subTextColor: const Color(0xFF607D8B),
            ),
          ],
        ],
      ),
    );
  }
}
