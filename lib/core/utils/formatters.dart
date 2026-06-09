import 'package:intl/intl.dart';

/// Money + date formatting helpers shared across the presentation layer,
/// mirroring the prototype's `fmtMoney` / `fmtDateLabel` behaviour.
class Formatters {
  Formatters._();

  static final _withCents = NumberFormat('#,##0.00', 'en_US');
  static final _noCents = NumberFormat('#,##0', 'en_US');

  /// Formats [n] as currency. [sign] prefixes +/−; [cents] toggles decimals.
  static String money(num n, {bool sign = false, bool cents = true}) {
    final v = n.abs();
    final s = (cents ? _withCents : _noCents).format(v);
    final prefix = sign ? (n < 0 ? '−' : '+') : '';
    return '$prefix\$$s';
  }

  /// "Today" / "Yesterday" / weekday / "Mon 3" relative day label.
  static String dateLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff > 1 && diff < 7) return DateFormat('EEEE').format(d);
    return DateFormat('MMM d').format(d);
  }

  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);
}
