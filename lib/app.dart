import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'services/app_version_service.dart';
import 'shared/navigation/app_router.dart';

class ArdentApp extends StatefulWidget {
  const ArdentApp({super.key});

  @override
  State<ArdentApp> createState() => _ArdentAppState();
}

class _ArdentAppState extends State<ArdentApp> with WidgetsBindingObserver {
  bool _versionUpToDate = false;
  // "Up to date" is only trusted for [_upToDateRecheckInterval]; after that a
  // resume re-asks the server so a version released while the app sat in
  // memory still prompts without killing the app from multitask.
  DateTime? _upToDateCheckedAt;
  static const _upToDateRecheckInterval = Duration(minutes: 1);
  bool _versionDialogVisible = false;
  bool _versionCheckInProgress = false;
  DateTime? _lastVersionPromptAt;
  DateTime? _suppressVersionPromptUntil;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Wait for the splash to hand off to login/dashboard: its pushReplacement
    // would otherwise replace (dismiss) a dialog shown on top of it.
    if (AppRouter.splashDone.value) {
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _enforceLatestVersionIfNeeded());
    } else {
      AppRouter.splashDone.addListener(_onSplashDone);
    }
  }

  void _onSplashDone() {
    if (!AppRouter.splashDone.value) return;
    AppRouter.splashDone.removeListener(_onSplashDone);
    // Let the new route's first frame settle before showing the dialog.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _enforceLatestVersionIfNeeded());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppRouter.splashDone.removeListener(_onSplashDone);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckVersionAfterResume();
    }
  }

  Future<void> _recheckVersionAfterResume() async {
    final checkedAt = _upToDateCheckedAt;
    if (_versionUpToDate &&
        checkedAt != null &&
        DateTime.now().difference(checkedAt) >= _upToDateRecheckInterval) {
      _versionUpToDate = false;
    }
    if (_versionUpToDate || _versionDialogVisible || _versionCheckInProgress) {
      return;
    }
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted ||
        _versionUpToDate ||
        _versionDialogVisible ||
        _versionCheckInProgress) {
      return;
    }
    await _enforceLatestVersionIfNeeded(fromResume: true);
  }

  Future<void> _enforceLatestVersionIfNeeded({bool fromResume = false}) async {
    // Runs on both platforms: the backend returns an App Store link for iOS
    // and the APK URL for Android. Never before the splash hands off — a
    // dialog shown over the splash gets replaced by its pushReplacement.
    if (!AppRouter.splashDone.value) return;
    if (_versionUpToDate || _versionDialogVisible || _versionCheckInProgress) {
      return;
    }

    final now = DateTime.now();
    final suppressPrompt = _suppressVersionPromptUntil != null &&
        now.isBefore(_suppressVersionPromptUntil!);

    // Don't re-prompt too aggressively when returning from the background.
    if (fromResume && _lastVersionPromptAt != null && !suppressPrompt) {
      final elapsed = now.difference(_lastVersionPromptAt!);
      if (elapsed < const Duration(seconds: 30)) return;
    }

    _versionCheckInProgress = true;
    final svc = AppVersionService();
    try {
      final current = await svc.getInstalledVersion();
      final remote = await svc.fetchLatestVersion();

      debugPrint(
        '[VersionCheck] Current: $current, Latest: ${remote?.latestVersion}',
      );

      if (!mounted || current == null || remote == null) return;

      // Two-tier gate: below min → forced wall, below latest → soft prompt.
      final action = AppVersionService.decideUpdate(current, remote);
      if (action == AppUpdateAction.none) {
        _versionUpToDate = true;
        _upToDateCheckedAt = DateTime.now();
        _suppressVersionPromptUntil = null;
        return;
      }

      if (suppressPrompt) return;

      final dialogContext =
          AppRouter.navigatorKey.currentState?.overlay?.context;
      if (dialogContext == null || !dialogContext.mounted) return;

      _versionDialogVisible = true;
      _lastVersionPromptAt = DateTime.now();

      final updateInitiated = action == AppUpdateAction.forced
          ? await showForceUpdateDialog(
              context: dialogContext,
              remote: remote,
              current: current,
            )
          : await showSoftUpdateDialog(
              context: dialogContext,
              remote: remote,
              current: current,
            );

      if (!mounted) return;
      _versionDialogVisible = false;

      // User opened the download link — avoid a re-prompt loop while they
      // install the new APK.
      if (updateInitiated) {
        _suppressVersionPromptUntil =
            DateTime.now().add(const Duration(minutes: 3));
      }
    } catch (e) {
      debugPrint('Version gate failed: $e');
      _versionDialogVisible = false;
    } finally {
      _versionCheckInProgress = false;
      svc.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ardent Resource Management',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      navigatorKey: AppRouter.navigatorKey,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.generateRoute,
    );
  }
}
