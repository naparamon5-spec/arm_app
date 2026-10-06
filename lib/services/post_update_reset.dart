import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:arm_app/core/di/app_dependencies.dart';

/// Post-update sign-out. On every launch we compare the installed app version
/// to the one recorded on the last launch. If it changed — the user just
/// installed a new build — we wipe the stored session so they have to sign
/// in again. New builds may change the auth contract (claims, token format,
/// endpoints), so stale credentials shouldn't carry across upgrades.
///
/// Fails open: any error just skips the reset. Never blocks launch.
class PostUpdateReset {
  PostUpdateReset._();

  static const _kLastLaunchedVersion = 'last_launched_version';
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// Call once from `main()` BEFORE `runApp` (after
  /// `AppDependencies.instance.initialize()` so sessionService exists).
  static Future<void> runIfVersionChanged() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version.trim();
      if (current.isEmpty) return;

      final last = await _storage.read(key: _kLastLaunchedVersion);
      if (last != null && last.isNotEmpty && last != current) {
        debugPrint('[PostUpdateReset] version changed $last → $current, '
            'clearing session');
        await AppDependencies.instance.sessionService.clearSession();
      }
      await _storage.write(key: _kLastLaunchedVersion, value: current);
    } catch (e) {
      debugPrint('[PostUpdateReset] skipped: $e');
    }
  }
}
