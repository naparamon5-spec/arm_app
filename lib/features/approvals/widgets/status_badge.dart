import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/quote_model.dart';

class StatusBadge extends StatelessWidget {
  final QuoteStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: _backgroundColor.withOpacity(0.4)),
      ),
      child: Text(
        _label,
        style: TextStyle(
          color: _backgroundColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status) {
      case QuoteStatus.pending:
        return AppColors.pending;
      case QuoteStatus.approved:
        return AppColors.approved;
      case QuoteStatus.rejected:
        return AppColors.rejected;
    }
  }

  String get _label {
    switch (status) {
      case QuoteStatus.pending:
        return AppStrings.statusPending;
      case QuoteStatus.approved:
        return AppStrings.statusApproved;
      case QuoteStatus.rejected:
        return AppStrings.statusRejected;
    }
  }
}
