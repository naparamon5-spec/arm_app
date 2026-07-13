import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool fullWidth;
  final bool italic;
  final Color? valueColor;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.fullWidth = false,
    this.italic = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: valueColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}

class DetailRowGrid extends StatelessWidget {
  final List<DetailRow> rows;

  const DetailRowGrid({super.key, required this.rows});

  @override
  Widget build(BuildContext context) {
    final pairs = <Widget>[];
    for (var i = 0; i < rows.length; i += 2) {
      final left = rows[i];
      final right = i + 1 < rows.length ? rows[i + 1] : null;
      pairs.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: left),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: right ?? const SizedBox()),
          ],
        ),
      );
      if (i + 2 < rows.length) {
        pairs.add(const SizedBox(height: AppSpacing.lg));
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: pairs,
    );
  }
}
