import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/navigation/app_router.dart';
import '../../../shared/widgets/app_bar_widget.dart';
import '../../../shared/widgets/app_error_widget.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/profile_controller.dart';
import 'change_password_screen.dart';

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
              appBar: const AppBarWidget(),
              body: controller.errorMessage != null
                  ? AppErrorWidget(
                      message: controller.errorMessage,
                      onRetry: () => controller.loadProfile(),
                    )
                  : _Body(onSignOut: _onSignOut),
            ),
          );
        },
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final VoidCallback onSignOut;

  const _Body({required this.onSignOut});

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
              _ProfileInfoCard(),
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
              _ChangePasswordTile(),
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
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
          const Text(
            'Mark Cedrick Almueda',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A1A2E),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          const Text(
            'Technical Support Engineer',
            style: TextStyle(
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
            children: const [
              Icon(Icons.email_outlined, size: 16, color: Color(0xFF9CA3AF)),
              SizedBox(width: 6),
              Text(
                'cedrick.almueda@ardentnetworks.com.ph',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.business_outlined, size: 16, color: Color(0xFF9CA3AF)),
              SizedBox(width: 6),
              Text(
                'Ardent Networks Inc.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF6B7280),
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
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const ChangePasswordScreen(),
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
