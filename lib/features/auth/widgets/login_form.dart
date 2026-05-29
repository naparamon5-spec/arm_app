import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const LoginForm({super.key, required this.onSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit(AuthController controller) {
    if (!_formKey.currentState!.validate()) return;
    controller.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      onSuccess: widget.onSuccess,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, controller, _) {
        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: AppStrings.corporateEmail,
                hint: AppStrings.emailHint,
                controller: _emailController,
                validator: Validators.email,
                keyboardType: TextInputType.emailAddress,
                fillColor: Colors.white,
                borderColor: const Color(0xFFE5E7EB),
                labelColor: const Color(0xFF1A1A2E),
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                label: AppStrings.password,
                hint: AppStrings.passwordHint,
                controller: _passwordController,
                validator: Validators.password,
                obscureText: _obscurePassword,
                fillColor: Colors.white,
                borderColor: const Color(0xFFE5E7EB),
                labelColor: const Color(0xFF1A1A2E),
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: const Color(0xFF9CA3AF),
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.xs,
                    ),
                  ),
                  child: const Text(
                    AppStrings.forgotPassword,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              _RememberDeviceRow(controller: controller),
              const SizedBox(height: AppSpacing.xl),
              if (controller.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppSpacing.inputRadius),
                  ),
                  child: Text(
                    controller.errorMessage!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              _LoginButton(
                isLoading: controller.isLoading,
                onPressed: () => _submit(controller),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _Divider(),
              const SizedBox(height: AppSpacing.lg),
              const _SignUpPrompt(),
            ],
          ),
        );
      },
    );
  }
}

class _RememberDeviceRow extends StatelessWidget {
  final AuthController controller;

  const _RememberDeviceRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: Checkbox(
            value: controller.rememberDevice,
            onChanged: (v) => controller.setRememberDevice(v ?? false),
            activeColor: AppColors.primary,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          AppStrings.rememberDevice,
          style: AppTextStyles.bodySmall.copyWith(
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}

class _LoginButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _LoginButton({required this.isLoading, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.buttonRadius),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.textLight),
                ),
              )
            : const Text('LOGIN', style: AppTextStyles.buttonLabel),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.divider)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'or',
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.divider)),
      ],
    );
  }
}

class _SignUpPrompt extends StatelessWidget {
  const _SignUpPrompt();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(
            text: AppStrings.newToArdent,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF1A1A2E),
            ),
          ),
          WidgetSpan(
            child: GestureDetector(
              onTap: null,
              child: const Text(
                AppStrings.contactItAdmin,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
