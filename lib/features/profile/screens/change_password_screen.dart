import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/profile_controller.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  String _newPassword = '';

  bool get _hasMinLength => _newPassword.length >= 8;
  bool get _hasLowercase => _newPassword.contains(RegExp(r'[a-z]'));
  bool get _hasUppercase => _newPassword.contains(RegExp(r'[A-Z]'));
  bool get _hasNumber => _newPassword.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar =>
      _newPassword.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
  bool get _allRequirementsMet =>
      _hasMinLength && _hasLowercase && _hasUppercase && _hasNumber && _hasSpecialChar;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(ProfileController controller) async {
    if (!_allRequirementsMet) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please meet all password requirements'),
        ),
      );
      return;
    }
    if (_formKey.currentState?.validate() != true) return;

    await controller.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
      onSuccess: () {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password changed successfully')),
        );
        Navigator.pop(context);
      },
    );

    if (!mounted) return;
    final error = controller.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ProfileController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F8),
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top section
            Container(
              width: double.infinity,
              color: const Color(0xFFF4F7F8),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.arrow_back_ios,
                            size: 14, color: Color(0xFF6B7280)),
                        SizedBox(width: 4),
                        Text(
                          'Back to Profile',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ensure your account stays secure by using a strong, unique password.',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            // Form section
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PasswordField(
                      label: 'CURRENT PASSWORD',
                      controller: _currentPasswordController,
                      obscure: _obscureCurrent,
                      onToggle: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Current password is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    _PasswordField(
                      label: 'NEW PASSWORD',
                      controller: _newPasswordController,
                      obscure: _obscureNew,
                      onToggle: () =>
                          setState(() => _obscureNew = !_obscureNew),
                      onChanged: (value) =>
                          setState(() => _newPassword = value),
                      helperWidget: PasswordRequirementsWidget(
                        password: _newPassword,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _PasswordField(
                      label: 'CONFIRM NEW PASSWORD',
                      controller: _confirmPasswordController,
                      obscure: _obscureConfirm,
                      onToggle: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (val != _newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            // Update Password button
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () => _submit(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'UPDATE PASSWORD',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.lock_reset, size: 18, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
            // Security Protocol card
            Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF0F0),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFFFCDD2)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD32F2F).withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4E4),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 22,
                      color: Color(0xFFD32F2F),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Security Protocol',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD32F2F),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD32F2F),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'IMPORTANT',
                                style: TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Updating your password is an important '
                          'step in keeping your account secure '
                          'and protecting your information.',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF6B7280),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1C2333),
      elevation: 0,
      toolbarHeight: 64,
      titleSpacing: 12,
      automaticallyImplyLeading: false,
      title: RichText(
        text: const TextSpan(
          children: [
            TextSpan(
              text: 'ARDENT ',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
            TextSpan(
              text: 'RESOURCE MANAGEMENT',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD32F2F),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(2),
        child: SizedBox(
          height: 2,
          child: ColoredBox(color: Color(0xFFD32F2F)),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String>? onChanged;
  final String? helperText;
  final Widget? helperWidget;
  final String? Function(String?)? validator;

  const _PasswordField({
    required this.label,
    required this.controller,
    required this.obscure,
    required this.onToggle,
    this.onChanged,
    this.helperText,
    this.helperWidget,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF475569),
            letterSpacing: 0.8,
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
          style: const TextStyle(fontSize: 15),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: '••••••••',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD32F2F)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD32F2F)),
            ),
            errorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD32F2F)),
            ),
            focusedErrorBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFD32F2F)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF9CA3AF),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 8),
            isDense: true,
            errorStyle: const TextStyle(
              color: Color(0xFFD32F2F),
              fontSize: 11,
            ),
          ),
        ),
        if (helperWidget != null) ...[
          const SizedBox(height: 8),
          helperWidget!,
        ] else if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ],
    );
  }
}

class PasswordRequirementsWidget extends StatelessWidget {
  final String password;

  const PasswordRequirementsWidget({super.key, required this.password});

  bool get hasMinLength => password.length >= 8;
  bool get hasLowercase => password.contains(RegExp(r'[a-z]'));
  bool get hasUppercase => password.contains(RegExp(r'[A-Z]'));
  bool get hasNumber => password.contains(RegExp(r'[0-9]'));
  bool get hasSpecialChar =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _RequirementRow(met: hasMinLength, text: 'Minimum 8 characters'),
          const SizedBox(height: 6),
          _RequirementRow(met: hasLowercase, text: 'At least 1 lowercase letter'),
          const SizedBox(height: 6),
          _RequirementRow(met: hasUppercase, text: 'At least 1 uppercase letter'),
          const SizedBox(height: 6),
          _RequirementRow(met: hasNumber, text: 'At least 1 number'),
          const SizedBox(height: 6),
          _RequirementRow(met: hasSpecialChar, text: 'At least 1 special character'),
        ],
      ),
    );
  }
}

class _RequirementRow extends StatelessWidget {
  final bool met;
  final String text;

  const _RequirementRow({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Icon(
            met ? Icons.check_circle : Icons.circle_outlined,
            key: ValueKey(met),
            size: 13,
            color: met ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(width: 6),
        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 300),
          style: TextStyle(
            fontSize: 11,
            fontWeight: met ? FontWeight.w600 : FontWeight.w400,
            color: met ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
          ),
          child: Text(text),
        ),
      ],
    );
  }
}
