import 'dart:convert';

/// Helpers for parsing loosely-typed API / database JSON objects.
extension JsonMap on Map<String, dynamic> {
  String str(List<String> keys, [String fallback = '']) {
    for (final key in keys) {
      final value = this[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return fallback;
  }

  double dbl(List<String> keys, [double fallback = 0]) {
    for (final key in keys) {
      final value = this[key];
      if (value == null) continue;
      if (value is num) return value.toDouble();
      final parsed = double.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  int integer(List<String> keys, [int fallback = 0]) {
    for (final key in keys) {
      final value = this[key];
      if (value == null) continue;
      if (value is int) return value;
      if (value is num) return value.toInt();
      final parsed = int.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return fallback;
  }

  DateTime date(List<String> keys, [DateTime? fallback]) {
    for (final key in keys) {
      final value = this[key];
      if (value == null) continue;
      if (value is DateTime) return value;
      final parsed = DateTime.tryParse(value.toString());
      if (parsed != null) return parsed;
    }
    return fallback ?? DateTime.now();
  }

  bool get isNotEmptyMap => isNotEmpty;
}

Map<String, dynamic> asJsonMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  // The list endpoint returns each row as a JSON-encoded string inside the
  // `result` array — decode it into a map.
  if (value is String) {
    final s = value.trim();
    if (s.startsWith('{')) {
      try {
        final decoded = jsonDecode(s);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {
        // fall through to empty map
      }
    }
  }
  return {};
}

List<Map<String, dynamic>> asJsonList(dynamic value) {
  if (value is! List) return [];
  return value.map(asJsonMap).where((m) => m.isNotEmpty).toList();
}
