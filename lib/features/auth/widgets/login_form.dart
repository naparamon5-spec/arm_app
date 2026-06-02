import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/validators.dart';
import '../controllers/auth_controller.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onSuccess;

  const LoginForm({super.key, required this.onSuccess});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  static const _underlineBorder = UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1),
  );
  static const _underlineBorderFocused = UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xFFD32F2F), width: 1.5),
  );

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _userIdValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'User ID is required';
    return null;
  }

  void _submit(AuthController controller) {
    if (!_formKey.currentState!.validate()) return;
    controller.setRememberDevice(_rememberMe);
    controller.login(
      userId: _userIdController.text.trim(),
      password: _passwordController.text,
      onSuccess: widget.onSuccess,
    );
  }

  InputDecoration _fieldDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: Color(0xFFC0C0C0),
      ),
      filled: false,
      border: _underlineBorder,
      enabledBorder: _underlineBorder,
      focusedBorder: _underlineBorderFocused,
      errorBorder: _underlineBorder,
      focusedErrorBorder: _underlineBorderFocused,
      contentPadding: const EdgeInsets.symmetric(vertical: 10),
      isDense: true,
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
              // USER ID
              const Text(
                'USER ID',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _userIdController,
                validator: _userIdValidator,
                keyboardType: TextInputType.text,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  TextInputFormatter.withFunction(
                    (oldValue, newValue) => newValue.copyWith(
                      text: newValue.text.toUpperCase(),
                      selection: newValue.selection,
                    ),
                  ),
                ],
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: _fieldDecoration(hint: 'ENTER YOUR USER ID'),
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 24),
              // PASSWORD
              const Text(
                'PASSWORD',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                validator: Validators.password,
                obscureText: _obscurePassword,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF1A1A2E),
                ),
                decoration: _fieldDecoration(hint: 'ENTER PASSWORD').copyWith(
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
              const SizedBox(height: 20),
              // REMEMBER ME
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    activeColor: const Color(0xFFD32F2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Remember Me',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Error message
              if (controller.errorMessage != null) ...[
                Text(
                  controller.errorMessage!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD32F2F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
              // LOGIN BUTTON
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                      controller.isLoading ? null : () => _submit(controller),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    disabledBackgroundColor:
                        const Color(0xFFD32F2F).withOpacity(0.6),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  child: controller.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          ' LOGIN ',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
