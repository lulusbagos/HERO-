/// App-wide constants.
/// Keep all magic strings and numbers here instead of scattering them.
abstract final class AppConstants {
  // ── Durations ──────────────────────────────────────────────────────────────
  static const Duration animShort = Duration(milliseconds: 200);
  static const Duration animMedium = Duration(milliseconds: 350);
  static const Duration animLong = Duration(milliseconds: 500);

  // ── Spacing & Radius ──────────────────────────────────────────────────────
  static const double cardRadius = 16.0;
  static const double sheetRadius = 24.0;
  static const double pageHPad = 20.0;

  // ── Revision rules ────────────────────────────────────────────────────────
  /// Minimum days in the past allowed for attendance revision.
  static const int revisionMaxDaysAgo = 7;

  // ── API base – replace when backend is ready ──────────────────────────────
  static const String apiBase = 'https://api.indeximcoalindo.co.id/v1';
}
