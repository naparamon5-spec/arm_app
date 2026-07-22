import 'dart:io';

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
  bool _versionDialogVisible = false;
  bool _versionCheckInProgress = false;
  DateTime? _lastVersionPromptAt;
  DateTime? _suppressVersionPromptUntil;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Run the first check once the first frame is on screen so the navigator
    // (and its overlay) exists for the dialog.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _enforceLatestVersionIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _recheckVersionAfterResume();
    }
  }

  Future<void> _recheckVersionAfterResume() async {
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
    // Android only. iOS updates are delivered exclusively through the App
    // Store; showing a custom force-update dialog that links to an external
    // (APK) download would violate App Store Review Guidelines 2.4.5 / 3.2.2.
    if (!Platform.isAndroid) return;
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

      if (!AppVersionService.isUpdateRequired(current, remote.latestVersion)) {
        _versionUpToDate = true;
        _suppressVersionPromptUntil = null;
        return;
      }

      if (suppressPrompt) return;

      final dialogContext =
          AppRouter.navigatorKey.currentState?.overlay?.context;
      if (dialogContext == null || !dialogContext.mounted) return;

      _versionDialogVisible = true;
      _lastVersionPromptAt = DateTime.now();

      final updateInitiated = await showForceUpdateDialog(
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
