import 'package:intl/intl.dart';

/// Common formatting utilities shared across the app.
abstract final class FormatUtils {
  static final _dateShort = DateFormat('dd MMM yyyy', 'id_ID');
  static final _dateLong = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
  static final _time = DateFormat('HH:mm', 'id_ID');
  static final _dateTime = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  /// e.g. "31 Mei 2026"
  static String dateShort(DateTime dt) => _dateShort.format(dt);

  /// e.g. "Minggu, 31 Mei 2026"
  static String dateLong(DateTime dt) => _dateLong.format(dt);

  /// e.g. "08:30"
  static String time(DateTime dt) => _time.format(dt);

  /// e.g. "31 Mei 2026, 08:30"
  static String dateTime(DateTime dt) => _dateTime.format(dt);

  /// "08:00 – 17:00"
  static String timeRange(DateTime from, DateTime to) =>
      '${time(from)} \u2013 ${time(to)}';
}
