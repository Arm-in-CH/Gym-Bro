import 'package:intl/intl.dart';

class PersianUtils {
  static const List<String> _persianDigits = [
    '۰',
    '۱',
    '۲',
    '۳',
    '۴',
    '۵',
    '۶',
    '۷',
    '۸',
    '۹'
  ];

  static String toPersianDigits(dynamic input) {
    if (input == null) return '';
    final str = input.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      final code = str.codeUnitAt(i);
      if (code >= 48 && code <= 57) {
        buffer.write(_persianDigits[code - 48]);
      } else {
        buffer.write(str[i]);
      }
    }
    return buffer.toString();
  }

  /// Converts Persian and Arabic numerals and Persian decimal separators to standard ASCII English digits.
  static String fromPersianDigits(dynamic input) {
    if (input == null) return '';
    var str = input.toString();
    const persian = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];
    const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    for (int i = 0; i < 10; i++) {
      str = str.replaceAll(persian[i], i.toString());
      str = str.replaceAll(arabic[i], i.toString());
    }
    // Also handle Persian decimal comma/slash
    str = str.replaceAll('٫', '.').replaceAll('،', '.').replaceAll('/', '.');
    return str;
  }

  /// Safely parses a double from either English, Persian, or Arabic digit strings.
  static double? tryParseDouble(dynamic input) {
    if (input == null) return null;
    final clean = fromPersianDigits(input).trim();
    if (clean.isEmpty) return null;
    return double.tryParse(clean);
  }

  /// Safely parses an integer from either English, Persian, or Arabic digit strings.
  static int? tryParseInt(dynamic input) {
    if (input == null) return null;
    final clean = fromPersianDigits(input).trim();
    if (clean.isEmpty) return null;
    return int.tryParse(clean);
  }

  static String formatToman(num amount) {
    final formatter = NumberFormat("#,###", "en_US");
    return '${toPersianDigits(formatter.format(amount))} تومان';
  }

  static String formatCalories(num kcal) {
    final formatter = NumberFormat("#,###", "en_US");
    return '${toPersianDigits(formatter.format(kcal))} کالری';
  }

  static String formatWeight(num kg, {int decimalDigits = 1}) {
    final str = decimalDigits > 0 ? kg.toStringAsFixed(decimalDigits) : kg.toInt().toString();
    return '${toPersianDigits(str)} کیلوگرم';
  }

  static String formatHeight(num cm) {
    return '${toPersianDigits(cm.toInt())} سانتی‌متر';
  }

  static String formatMeasurement(num cm, {int decimalDigits = 1}) {
    final str = decimalDigits > 0 && cm is! int
        ? cm.toStringAsFixed(decimalDigits)
        : (cm is int ? cm.toString() : cm.toStringAsFixed(1));
    return '${toPersianDigits(str)} سانتی‌متر';
  }

  static String formatSeconds(int sec) {
    return '${toPersianDigits(sec)} ثانیه';
  }

  static String formatGrams(num grams) {
    final str = grams is int ? grams.toString() : grams.toStringAsFixed(1);
    return '${toPersianDigits(str)} گرم';
  }

  static String formatTonnage(num kg) {
    final formatter = NumberFormat("#,###", "en_US");
    return '${toPersianDigits(formatter.format(kg.toInt()))} کیلوگرم';
  }

  static String formatDistance(num distance, {bool isKm = true}) {
    if (isKm) {
      return '${toPersianDigits(distance.toStringAsFixed(1))} کیلومتر';
    }
    return '${toPersianDigits(distance.toInt())} متر';
  }

  static String formatDurationMinutesSeconds(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
    return toPersianDigits(timeStr);
  }

  /// Formats a percentage number with standardized Persian digits and standard Persian percentage symbol (٪).
  /// Guarantees consistent RTL presentation without mixing Arabic, Persian, or Latin numeral glyphs.
  static String formatPercentage(dynamic value, {int decimalDigits = 0}) {
    if (value == null) return '۰٪';
    final numVal = (value is num)
        ? value
        : (double.tryParse(fromPersianDigits(value).trim()) ?? 0.0);
    final formattedNumber = decimalDigits > 0
        ? numVal.toStringAsFixed(decimalDigits)
        : numVal.round().toString();
    return '${toPersianDigits(formattedNumber)}٪';
  }

  static String toDateString(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String formatPersianDate(DateTime date) {
    const persianMonths = [
      'فروردین',
      'اردیبهشت',
      'خرداد',
      'تیر',
      'مرداد',
      'شهریور',
      'مهر',
      'آبان',
      'آذر',
      'دی',
      'بهمن',
      'اسفند'
    ];
    final day = toPersianDigits(date.day);
    final month = persianMonths[(date.month - 1) % 12];
    return '$day $month';
  }
}
