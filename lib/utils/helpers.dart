import 'package:intl/intl.dart';

class Helpers {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_PK',
    symbol: 'Rs. ',
    decimalDigits: 0,
  );

  static String formatCurrency(num value) {
    return _currencyFormat.format(value);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatDateTime(DateTime date) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(date);
  }

  static String formatDateForDb(DateTime date) {
    return date.toIso8601String();
  }

  static DateTime parseDbDate(String value) {
    return DateTime.parse(value);
  }

  static String generateTripNumber(int lastId) {
    final year = DateTime.now().year;
    final id = (lastId + 1).toString().padLeft(4, '0');
    return 'AHT-$year-$id';
  }

  static int daysUntil(DateTime date) {
    final now = DateTime.now();
    return date.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  static double toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }
}
