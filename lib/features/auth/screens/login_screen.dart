import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../services/biometric_service.dart';
import '../../../shared/controllers/main_tab_controller.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/auth_controller.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  static const _privacyPolicyUrl =
      'https://arm.ardentnetworks.com.ph/privacy-policy';
  static const _supportUrl = 'https://arm.ardentnetworks.com.ph/support';

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Consumer<AuthController>(
        builder: (context, auth, child) => LoadingOverlay(
          isLoading: auth.isLoading,
          child: child!,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(
                  left: 24,
                  right: 24,
                  bottom: 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Center(
                      child: Image.asset(
                        'assets/ARM.png',
                        width: 280,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Smart Approvals for Smart Teams',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 60),
                    Builder(
                      builder: (context) {
                        void goToDashboard() {
                          Provider.of<MainTabController>(context, listen: false)
                              .switchTo(0);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRouter.dashboard,
                            (route) => false,
                          );
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            LoginForm(onSuccess: goToDashboard),
                            _BiometricUnlockButton(onUnlocked: goToDashboard),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom + 12,
                  top: 8,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FooterLink(
                          label: 'Privacy Policy',
                          onTap: () => _openUrl(_privacyPolicyUrl),
                        ),
                        const Text(
                          '   |   ',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        _FooterLink(
                          label: 'Support',
                          onTap: () => _openUrl(_supportUrl),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Ardent MIS | ARM',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Biometric login icon shown below the LOGIN button — eForward style. It is
/// only rendered when the user has enabled the biometric toggle AND a saved
/// session exists AND the device can authenticate. The icon and label follow
/// the device's own method (Face ID / Touch ID / Fingerprint / PIN). Tapping it
/// authenticates and restores the saved session straight into the app.
class _BiometricUnlockButton extends StatefulWidget {
  final VoidCallback onUnlocked;

  const _BiometricUnlockButton({required this.onUnlocked});

  @override
  State<_BiometricUnlockButton> createState() => _BiometricUnlockButtonState();
}

class _BiometricUnlockButtonState extends State<_BiometricUnlockButton> {
  final _deps = AppDependencies.instance;

  bool _show = false;
  bool _busy = false;
  BiometricMethod _method = BiometricMethod.fingerprint;
  String _label = '';

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    // Show only when biometric login is enabled, the device can authenticate,
    // and credentials have been stored — these survive sign-out, so the button
    // stays available after the user logs out.
    final enabled = await _deps.biometricService.isEnabled();
    final available = await _deps.biometricService.canAuthenticate();
    final hasCreds = await _deps.tokenStorage.hasBiometricCredentials();
    final method = await _deps.biometricService.resolveMethod();
    if (!mounted) return;
    setState(() {
      _show = enabled && available && hasCreds;
      _method = method;
      _label = _deps.biometricService.labelFor(method);
    });
  }

  IconData get _icon => switch (_method) {
        BiometricMethod.face => Icons.face,
        BiometricMethod.fingerprint => Icons.fingerprint,
        BiometricMethod.pin => Icons.dialpad,
      };

  Future<void> _onTap() async {
    if (_busy) return;
    // Captured before any await so we never touch context across an async gap.
    final auth = context.read<AuthController>();
    setState(() => _busy = true);

    // 1. Device authentication (Face ID / Touch ID / fingerprint / passcode).
    final ok = await _deps.biometricService.authenticate(
      reason: 'Log in to ARM',
      biometricOnly: _method != BiometricMethod.pin,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _busy = false);
      return;
    }

    // 2. Replay the stored credentials through the normal login flow so a fresh
    //    session is issued (works even after sign-out revoked the old tokens).
    final creds = await _deps.tokenStorage.biometricCredentials();
    if (creds == null) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _show = false;
      });
      return;
    }

    await auth.login(
      userId: creds.userId,
      password: creds.password,
      onSuccess: widget.onUnlocked,
    );
    if (!mounted) return;

    // If login failed (e.g. the password was changed on the backend), the
    // stored credentials are stale — clear them and disable biometric login so
    // the user falls back to the password form.
    if (!_deps.sessionService.isLoggedIn) {
      await _deps.biometricService.setEnabled(false);
      await _deps.tokenStorage.clearBiometricCredentials();
      if (!mounted) return;
      setState(() => _show = false);
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_show) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: GestureDetector(
          onTap: _busy ? null : _onTap,
          behavior: HitTestBehavior.opaque,
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD32F2F),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _busy
                    ? const Padding(
                        padding: EdgeInsets.all(18),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
                        ),
                      )
                    : Icon(_icon, size: 30, color: const Color(0xFFD32F2F)),
              ),
              const SizedBox(height: 8),
              Text(
                _label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _FooterLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Color(0xFFD32F2F),
        ),
      ),
    );
  }
}
