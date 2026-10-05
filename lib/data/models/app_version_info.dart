class AppVersionInfo {
  const AppVersionInfo({
    required this.latestVersion,
    required this.downloadUrl,
    this.minSupportedVersion,
  });

  /// Newest shipped version. Clients below this get a dismissible prompt.
  final AppComparableVersion latestVersion;

  /// Oldest version the backend still supports. Clients below this get a
  /// blocking "update required" wall. Null → soft prompt only.
  final AppComparableVersion? minSupportedVersion;

  final Uri downloadUrl;
}

/// Launch-time decision for the version gate.
enum AppUpdateAction { none, soft, forced }

/// Compares semver only (e.g. `3.1.2`). Build numbers are ignored.
class AppComparableVersion implements Comparable<AppComparableVersion> {
  const AppComparableVersion({
    required this.major,
    required this.minor,
    required this.patch,
  });

  final int major;
  final int minor;
  final int patch;

  static AppComparableVersion? tryParse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) return null;

    // Only semver-style strings are supported (e.g. 3.1.2, v3.1.2, 3.1.2+17).
    if (RegExp(r'^\d+$').hasMatch(trimmed)) return null;

    final normalized = trimmed.startsWith('v') || trimmed.startsWith('V')
        ? trimmed.substring(1)
        : trimmed;

    // Drop any +build suffix — comparison uses major.minor.patch only.
    final core = normalized.split('+').first;
    final parts = core.split('.');

    if (parts.isEmpty || parts.length < 2) return null;

    return AppComparableVersion(
      major: _extractLeadingInt(parts[0]),
      minor: parts.length > 1 ? _extractLeadingInt(parts[1]) : 0,
      patch: parts.length > 2 ? _extractLeadingInt(parts[2]) : 0,
    );
  }

  static int _extractLeadingInt(String s) {
    final match = RegExp(r'^\d+').firstMatch(s.trim());
    if (match == null) return 0;
    return int.tryParse(match.group(0)!) ?? 0;
  }

  static AppComparableVersion? fromVersionName(String versionName) {
    return tryParse(versionName);
  }

  @override
  int compareTo(AppComparableVersion other) {
    if (major != other.major) return major.compareTo(other.major);
    if (minor != other.minor) return minor.compareTo(other.minor);
    if (patch != other.patch) return patch.compareTo(other.patch);
    return 0;
  }

  bool operator <(AppComparableVersion other) => compareTo(other) < 0;
  bool operator <=(AppComparableVersion other) => compareTo(other) <= 0;
  bool operator >(AppComparableVersion other) => compareTo(other) > 0;
  bool operator >=(AppComparableVersion other) => compareTo(other) >= 0;
  @override
  bool operator ==(Object other) =>
      other is AppComparableVersion && compareTo(other) == 0;
  @override
  int get hashCode => Object.hash(major, minor, patch);

  @override
  String toString() => '$major.$minor.$patch';
}
