import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/profile_controller.dart';
import '../widgets/preferences_tile.dart';
import '../widgets/profile_info_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.loadProfile();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSignOut() {
    _controller.signOut(
      onSuccess: () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<ProfileController>(
        builder: (context, controller, _) {
          return LoadingOverlay(
            isLoading: controller.isLoading,
            child: Scaffold(
              backgroundColor: const Color(0xFFF4F7F8),
              appBar: AppBarWidget(
                showLogo: true,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: AppColors.textLight),
                    onPressed: () {},
                  ),
                ],
              ),
              body: controller.errorMessage != null
                  ? AppErrorWidget(
                      message: controller.errorMessage,
                      onRetry: () => controller.loadProfile(),
                    )
                  : controller.user == null
                      ? const SizedBox.shrink()
                      : _Body(
                          controller: controller,
                          onSignOut: _onSignOut,
                        ),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final ProfileController controller;
  final VoidCallback onSignOut;

  const _Body({required this.controller, required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    final user = controller.user!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileInfoCard(user: user),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            AppStrings.accountPreferences,
            style: AppTextStyles.labelBold,
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
              border: Border.all(color: AppColors.divider),
            ),
            child: PreferencesTile(
              icon: Icons.lock_outline,
              title: AppStrings.changePassword,
              subtitle: AppStrings.changePasswordSubtitle,
              iconColor: AppColors.surface,
              onTap: () {},
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          _SignOutButton(onSignOut: onSignOut),
          const SizedBox(height: AppSpacing.xl),
          Center(
            child: Text(
              AppStrings.appVersionStable,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textMuted,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  final VoidCallback onSignOut;
  const _SignOutButton({required this.onSignOut});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onSignOut,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        icon: const Icon(Icons.logout, size: 18),
        label: const Text(
          AppStrings.signOut,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
