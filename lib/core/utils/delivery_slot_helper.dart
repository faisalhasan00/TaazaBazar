/// Helper class for dynamic delivery slot date calculations in TaazaBazar / Freshly.
class DeliverySlotHelper {
  static const List<String> _weekdays = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  static const List<String> _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  /// Calculates and formats tomorrow's delivery slot date as 'Tomorrow (EEE, d MMM)'.
  /// If [now] is provided (e.g. in unit tests), it uses that as the base time;
  /// otherwise defaults to the local device [DateTime.now()].
  static String getTomorrowSlotDate([DateTime? now]) {
    final baseDate = now ?? DateTime.now();
    final tomorrow = baseDate.add(const Duration(days: 1));
    return formatSlotDate(tomorrow);
  }

  /// Formats any target delivery date as 'Tomorrow (EEE, d MMM)'.
  static String formatSlotDate(DateTime date) {
    final weekday = _weekdays[date.weekday - 1];
    final day = date.day;
    final month = _months[date.month - 1];
    return 'Tomorrow ($weekday, $day $month)';
  }
}
