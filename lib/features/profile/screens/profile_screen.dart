import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/di/app_dependencies.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../../../data/models/user_model.dart';
import '../controllers/profile_controller.dart';
import 'change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final ProfileController _controller;

  /// Whole-screen loader shown during sign-out. Uses the root overlay so the
  /// scrim covers the bottom navigation bar too (which lives on the parent
  /// MainScreen scaffold, outside this screen's own LoadingOverlay).
  OverlayEntry? _logoutOverlay;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController();
    _controller.loadProfile();
  }

  @override
  void dispose() {
    _hideLogoutOverlay();
    _controller.dispose();
    super.dispose();
  }

  void _showLogoutOverlay() {
    if (_logoutOverlay != null) return;
    _logoutOverlay = OverlayEntry(
      builder: (_) => const Positioned.fill(
        child: AbsorbPointer(
          child: ColoredBox(
            color: Color(0x80000000),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
          ),
        ),
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(_logoutOverlay!);
  }

  void _hideLogoutOverlay() {
    _logoutOverlay?.remove();
    _logoutOverlay = null;
  }

  Future<void> _onSignOut() async {
    _showLogoutOverlay();
    await _controller.signOut(
      onSuccess: () {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            AppRouter.login,
            (route) => false,
          );
        }
      },
    );
    // On success the route (and this state) is gone; on failure we're still
    // here — tear down the overlay and surface the error either way.
    _hideLogoutOverlay();
    if (mounted && _controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_controller.errorMessage!)),
      );
    }
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
              appBar: const AppBarWidget(),
              body: controller.errorMessage != null && controller.user == null
                  ? AppErrorWidget(
                      message: controller.errorMessage,
                      onRetry: () => controller.loadProfile(),
                    )
                  : _Body(
                      onSignOut: _onSignOut,
                      controller: controller,
                    ),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final VoidCallback onSignOut;
  final ProfileController controller;

  const _Body({
    required this.onSignOut,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              _ProfileInfoCard(user: controller.user),
              const SizedBox(height: 32),
              const Text(
                'ACCOUNT PREFERENCES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF9CA3AF),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              _ChangePasswordTile(controller: controller),
              const SizedBox(height: 12),
              const _BiometricToggleTile(),
              const SizedBox(height: 140),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SignOutButton(onSignOut: onSignOut),
                const SizedBox(height: 12),
                const Text(
                  'Ardent MIS | ARM',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF9CA3AF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                const _VersionText(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Displays the app version read from the build metadata (pubspec version),
/// so it always matches the shipped binary instead of a hardcoded string.
class _VersionText extends StatefulWidget {
  const _VersionText();

  @override
  State<_VersionText> createState() => _VersionTextState();
}

class _VersionTextState extends State<_VersionText> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) setState(() => _version = info.version);
    } catch (_) {
      // Leave blank on failure; the label still renders gracefully.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _version.isEmpty ? 'Version' : 'Version $_version',
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF9CA3AF),
      ),
      textAlign: TextAlign.center,
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  final UserModel? user;

  const _ProfileInfoCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = (user?.fullName ?? '').isNotEmpty ? user!.fullName : '—';
    final userId = (user?.id ?? '').isNotEmpty ? user!.id : '—';
    final classification =
        (user?.classification ?? '').isNotEmpty ? user!.classification : '—';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            userId,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFFD32F2F),
            ),
            textAlign: TextAlign.center,
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: Color(0xFFE5E7EB), height: 1, thickness: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.work_outline,
                  size: 16, color: Color(0xFF9CA3AF)),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  classification,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChangePasswordTile extends StatelessWidget {
  final ProfileController controller;

  const _ChangePasswordTile({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChangeNotifierProvider.value(
            value: controller,
            child: const ChangePasswordScreen(),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.lock_outline,
                size: 20,
                color: Color(0xFFD32F2F),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Change Password',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Update your security credentials',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: Color(0xFF9CA3AF)),
          ],
        ),
      ),
    );
  }
}

/// Toggle that lets the user turn biometric (Face ID / Touch ID / fingerprint /
/// device passcode) login on or off. Enabling it requires a successful
/// biometric check so we never enable it for someone who can't pass it.
class _BiometricToggleTile extends StatefulWidget {
  const _BiometricToggleTile();

  @override
  State<_BiometricToggleTile> createState() => _BiometricToggleTileState();
}

class _BiometricToggleTileState extends State<_BiometricToggleTile> {
  final _biometric = AppDependencies.instance.biometricService;
  final _tokenStorage = AppDependencies.instance.tokenStorage;
  final _session = AppDependencies.instance.sessionService;

  bool _enabled = false;
  bool _available = false;
  bool _busy = false;
  String _label = 'Biometric';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final available = await _biometric.canAuthenticate();
    final enabled = await _biometric.isEnabled();
    final label = await _biometric.primaryLabel();
    if (!mounted) return;
    setState(() {
      _available = available;
      _enabled = enabled;
      _label = label;
    });
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _onToggle(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      if (value) {
        if (!await _biometric.canAuthenticate()) {
          _snack(
            'Set up Face ID, fingerprint, or a device passcode in Settings '
            'first.',
          );
          return;
        }
        // We store the password entered at login so biometric login can sign in
        // again later (even after sign-out). It's only in memory this session.
        final userId = _session.lastUserId;
        final password = _session.lastPassword;
        if (userId == null ||
            userId.isEmpty ||
            password == null ||
            password.isEmpty) {
          _snack(
            'Please sign out and sign in again, then enable $_label login.',
          );
          return;
        }
        final ok = await _biometric.authenticate(
          reason: 'Confirm to enable $_label login',
        );
        if (!ok) {
          _snack('Authentication cancelled. $_label login not enabled.');
          return;
        }
        await _tokenStorage.setBiometricCredentials(
          userId: userId,
          password: password,
        );
        await _biometric.setEnabled(true);
        if (!mounted) return;
        setState(() => _enabled = true);
        _snack('$_label login enabled.');
      } else {
        await _biometric.setEnabled(false);
        await _tokenStorage.clearBiometricCredentials();
        if (!mounted) return;
        setState(() => _enabled = false);
        _snack('$_label login disabled.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = !_available
        ? 'Not available on this device'
        : _enabled
            ? 'Use $_label to sign in'
            : 'Sign in faster with $_label';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.fingerprint,
              size: 20,
              color: Color(0xFFD32F2F),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Biometric Login',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _enabled,
            onChanged: (_available && !_busy) ? _onToggle : null,
            activeThumbColor: const Color(0xFFD32F2F),
          ),
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
      child: OutlinedButton(
        onPressed: onSignOut,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFD32F2F), width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.white,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout, size: 18, color: Color(0xFFD32F2F)),
            SizedBox(width: 8),
            Text(
              'SIGN OUT OF SYSTEM',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD32F2F),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
