import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/api/api_paths.dart';
import '../core/config/api_config.dart';
import '../core/constants/app_colors.dart';
import '../data/models/app_version_info.dart';

export '../data/models/app_version_info.dart';

/// Android update-check service. Fetches the latest published version from the
/// backend and compares it (semver) against the installed build. Mirrors the
/// eforward app's version gate. Fails open: any network/parse error returns
/// null so the app keeps working normally.
class AppVersionService {
  AppVersionService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static Uri get _defaultVersionEndpoint =>
      Uri.parse('${ApiConfig.baseUrl}${ApiPaths.appVersion}');

  /// Returns true when [installed] is older than [latest] from the backend.
  static bool isUpdateRequired(
    AppComparableVersion installed,
    AppComparableVersion latest,
  ) {
    return installed < latest;
  }

  Future<AppVersionInfo?> fetchLatestVersion({
    Uri? endpoint,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    final uri = endpoint ?? _defaultVersionEndpoint;

    try {
      final res = await _client.get(uri).timeout(timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) return null;

      final dynamic decoded = res.body.isNotEmpty ? jsonDecode(res.body) : null;
      if (decoded is! Map) return null;
      final payload = decoded['data'] is Map ? decoded['data'] : decoded;

      // Backend shape (same as eforward):
      // { "application": "Quote Approval", "version": "3.5.2", "url": "…apk" }
      // `version` is null until a release is published — treat that as
      // "no update available" and fail open.
      final latestStr = payload['version']?.toString().trim();
      final urlStr = payload['url']?.toString().trim();

      if (latestStr == null || latestStr.isEmpty) return null;
      if (urlStr == null || urlStr.isEmpty) return null;

      final latest = AppComparableVersion.tryParse(latestStr);
      if (latest == null) return null;

      final url = Uri.tryParse(urlStr);
      if (url == null) return null;

      return AppVersionInfo(latestVersion: latest, downloadUrl: url);
    } catch (e) {
      debugPrint('fetchLatestVersion failed: $e');
      return null;
    }
  }

  Future<AppComparableVersion?> getInstalledVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version.trim();
      if (v.isEmpty) return null;

      return AppComparableVersion.fromVersionName(v);
    } catch (e) {
      debugPrint('getInstalledVersion failed: $e');
      return null;
    }
  }

  Future<bool> launchDownload(Uri url) async {
    return launchUrl(url, mode: LaunchMode.externalApplication);
  }

  void dispose() {
    _client.close();
  }
}

/// Shows the non-dismissible force-update dialog. Uses a native iOS
/// (Cupertino) alert on iOS and a modern Material sheet on Android. Returns
/// `true` if the user tapped "Update Now" and the download link opened.
Future<bool> showForceUpdateDialog({
  required BuildContext context,
  required AppVersionInfo remote,
  required AppComparableVersion current,
}) async {
  if (Platform.isIOS) {
    return _showCupertinoUpdateDialog(
      context: context,
      remote: remote,
      current: current,
    );
  }
  return _showMaterialUpdateDialog(
    context: context,
    remote: remote,
    current: current,
  );
}

/// Opens the download/store link. Returns true when the link was launched.
/// Surfaces a message via [messengerContext] when it can't be opened.
Future<bool> _launchUpdate(
  Uri url, {
  required BuildContext messengerContext,
}) async {
  final svc = AppVersionService();
  try {
    final ok = await svc.launchDownload(url);
    if (!ok && messengerContext.mounted) {
      ScaffoldMessenger.maybeOf(messengerContext)?.showSnackBar(
        const SnackBar(
          content: Text('Unable to open the update link. Please try again.'),
        ),
      );
    }
    return ok;
  } catch (e) {
    debugPrint('Update launch failed: $e');
    return false;
  } finally {
    svc.dispose();
  }
}

// ── iOS — native Cupertino alert ────────────────────────────────────────────
Future<bool> _showCupertinoUpdateDialog({
  required BuildContext context,
  required AppVersionInfo remote,
  required AppComparableVersion current,
}) async {
  var updateInitiated = false;

  await showCupertinoDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: CupertinoAlertDialog(
          title: const Padding(
            padding: EdgeInsets.only(bottom: 6),
            child: Text('Update Required'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'A newer version of ARM is available. Please update to '
                'continue.',
                style: TextStyle(fontSize: 13, height: 1.35),
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey6,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$current',
                      style: const TextStyle(
                        fontSize: 13,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(CupertinoIcons.arrow_right,
                          size: 14, color: CupertinoColors.systemGrey),
                    ),
                    Text(
                      '${remote.latestVersion}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () async {
                final ok = await _launchUpdate(
                  remote.downloadUrl,
                  messengerContext: dialogContext,
                );
                if (!ok || !dialogContext.mounted) return;
                updateInitiated = true;
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    },
  );

  return updateInitiated;
}

// ── Android — modern Material sheet ──────────────────────────────────────────
Future<bool> _showMaterialUpdateDialog({
  required BuildContext context,
  required AppVersionInfo remote,
  required AppComparableVersion current,
}) async {
  var updateInitiated = false;

  await showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.10),
                  ),
                  child: const Icon(
                    Icons.system_update_rounded,
                    size: 34,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Update Required',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A newer version of ARM is available. Please update to '
                  'keep using the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 18),
                // Current → Latest chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _VersionChip(label: 'Current', value: '$current'),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.arrow_forward_rounded,
                          size: 18, color: AppColors.textMuted),
                    ),
                    _VersionChip(
                      label: 'Latest',
                      value: '${remote.latestVersion}',
                      highlight: true,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.download_rounded, size: 20),
                    label: const Text(
                      'Update Now',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onPressed: () async {
                      final ok = await _launchUpdate(
                        remote.downloadUrl,
                        messengerContext: dialogContext,
                      );
                      if (!ok || !dialogContext.mounted) return;
                      updateInitiated = true;
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  return updateInitiated;
}

/// Small "Current / Latest" version pill used in the Material update dialog.
class _VersionChip extends StatelessWidget {
  const _VersionChip({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: highlight
                ? AppColors.primary.withValues(alpha: 0.10)
                : const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: highlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
