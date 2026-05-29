import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showLogo;

  const AppBarWidget({
    super.key,
    this.title = '',
    this.actions,
    this.leading,
    this.showLogo = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 0,
      leading: leading ??
          (showLogo
              ? Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: _ArdentLogoSmall(),
                )
              : null),
      title: Text(
        title.isNotEmpty ? title : AppStrings.appBarHeading,
        style: AppTextStyles.appBarTitle,
      ),
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.textLight),
    );
  }
}

class _ArdentLogoSmall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      alignment: Alignment.center,
      child: const Text(
        'A',
        style: TextStyle(
          color: AppColors.primary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
