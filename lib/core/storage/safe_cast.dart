/// Robust type casting and fallback utility for resilient JSON serialization.
class SafeCast {
  SafeCast._();

  static int toInt(dynamic val, [int fallback = 0]) {
    if (val == null) return fallback;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? num.tryParse(val)?.toInt() ?? fallback;
    }
    return fallback;
  }

  static int? toIntOrNull(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toInt();
    if (val is String) {
      return int.tryParse(val) ?? num.tryParse(val)?.toInt();
    }
    return null;
  }

  static double toDouble(dynamic val, [double fallback = 0.0]) {
    if (val == null) return fallback;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val) ?? fallback;
    }
    return fallback;
  }

  static double? toDoubleOrNull(dynamic val) {
    if (val == null) return null;
    if (val is num) return val.toDouble();
    if (val is String) {
      return double.tryParse(val);
    }
    return null;
  }

  static bool toBool(dynamic val, [bool fallback = false]) {
    if (val == null) return fallback;
    if (val is bool) return val;
    if (val is num) return val != 0;
    if (val is String) {
      final s = val.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return fallback;
  }

  static String toStringVal(dynamic val, [String fallback = '']) {
    if (val == null) return fallback;
    if (val is String) return val;
    return val.toString();
  }

  static String? toStringOrNull(dynamic val) {
    if (val == null) return null;
    if (val is String) return val;
    return val.toString();
  }
}
