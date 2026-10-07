import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
      'https://arm.ardentnetworks.com.ph/#/privacy-policy';
  static const _supportUrl = 'https://arm.ardentnetworks.com.ph/#/support';

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

                        return _LoginBody(onSuccess: goToDashboard);
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
                    const SizedBox(height: 4),
                    // Matches the version line on the Profile screen.
                    FutureBuilder<PackageInfo>(
                      future: PackageInfo.fromPlatform(),
                      builder: (context, snap) {
                        final v = snap.data?.version;
                        return Text(
                          v == null ? 'Version' : 'Version $v',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF9CA3AF),
                          ),
                        );
                      },
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

/// Biometric-first login body. When biometric login is enabled, the device
/// can authenticate, and credentials are stored, only the biometric panel is
/// shown — the email/password form stays hidden behind "Use password instead".
/// Otherwise the normal password form is shown.
class _LoginBody extends StatefulWidget {
  final VoidCallback onSuccess;

  const _LoginBody({required this.onSuccess});

  @override
  State<_LoginBody> createState() => _LoginBodyState();
}

class _LoginBodyState extends State<_LoginBody> {
  final _deps = AppDependencies.instance;

  bool _loaded = false;
  bool _bioAvailable = false;
  bool _usePassword = false;
  bool _busy = false;
  String? _savedUserId;
  BiometricMethod _method = BiometricMethod.fingerprint;
  String _label = '';

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final enabled = await _deps.biometricService.isEnabled();
    final available = await _deps.biometricService.canAuthenticate();
    final creds = await _deps.tokenStorage.biometricCredentials();
    final method = await _deps.biometricService.resolveMethod();
    if (!mounted) return;
    setState(() {
      _bioAvailable = enabled && available && creds != null;
      _savedUserId = creds?.userId;
      _method = method;
      _label = _deps.biometricService.labelFor(method);
      _loaded = true;
    });
  }

  IconData get _icon => switch (_method) {
        BiometricMethod.face => Icons.face,
        BiometricMethod.fingerprint => Icons.fingerprint,
        BiometricMethod.pin => Icons.dialpad,
      };

  Future<void> _unlock() async {
    if (_busy) return;
    final auth = context.read<AuthController>();
    setState(() => _busy = true);

    final ok = await _deps.biometricService.authenticate(
      reason: 'Log in to ARM',
      biometricOnly: _method != BiometricMethod.pin,
    );
    if (!mounted) return;
    if (!ok) {
      setState(() => _busy = false);
      return;
    }

    final creds = await _deps.tokenStorage.biometricCredentials();
    if (creds == null) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _bioAvailable = false;
      });
      return;
    }

    await auth.login(
      userId: creds.userId,
      password: creds.password,
      onSuccess: widget.onSuccess,
    );
    if (!mounted) return;

    // Stale credentials (e.g. password changed on the backend): drop them and
    // fall back to the password form.
    if (!_deps.sessionService.isLoggedIn) {
      await _deps.biometricService.setEnabled(false);
      await _deps.tokenStorage.clearBiometricCredentials();
      if (!mounted) return;
      setState(() => _bioAvailable = false);
    }
    setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) return const SizedBox(height: 200);

    if (!_bioAvailable || _usePassword) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LoginForm(onSuccess: widget.onSuccess),
          if (_bioAvailable)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Center(
                child: TextButton.icon(
                  onPressed: () => setState(() => _usePassword = false),
                  icon: Icon(_icon, color: const Color(0xFFD32F2F)),
                  label: Text(
                    'Use $_label instead',
                    style: const TextStyle(
                      color: Color(0xFFD32F2F),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    // The parent Column is start-aligned; force full width so this panel
    // centers on screen.
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // The biometric panel is much shorter than the password form; push it
          // down so it sits in the middle of the free space, not under the logo.
          SizedBox(height: MediaQuery.of(context).size.height * 0.04),
          if (_savedUserId != null) ...[
            const Text(
              'Signing in as',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F7F8),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _savedUserId!,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
              ),
            ),
            const SizedBox(height: 32),
          ],
          GestureDetector(
            onTap: _busy ? null : _unlock,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: const Color(0xFFD32F2F), width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: _busy
                      ? const Padding(
                          padding: EdgeInsets.all(28),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFD32F2F)),
                          ),
                        )
                      : Icon(_icon, size: 44, color: const Color(0xFFD32F2F)),
                ),
                const SizedBox(height: 12),
                Text(
                  'Sign in with $_label',
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          TextButton(
            onPressed: _busy ? null : () => setState(() => _usePassword = true),
            child: const Text(
              'Use password instead',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
