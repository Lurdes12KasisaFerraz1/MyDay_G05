class DateFormatter {
  DateFormatter._();

  static const List<String> _weekdays = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];

  static const List<String> _months = [
    'janeiro',
    'fevereiro',
    'março',
    'abril',
    'maio',
    'junho',
    'julho',
    'agosto',
    'setembro',
    'outubro',
    'novembro',
    'dezembro',
  ];

  /// Exemplo: "Quarta, 28 de outubro".
  static String longDate(DateTime date) {
    return '${_weekdays[date.weekday - 1]}, ${date.day} de ${_months[date.month - 1]}';
  }

  /// Exemplo: "28 out 2026 · 10:42".
  static String shortDateTime(DateTime date) {
    final month = _months[date.month - 1].substring(0, 3);
    return '${date.day} $month ${date.year} · ${time(date)}';
  }

  /// Exemplo: "26/11".
  static String shortDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}';
  }

  /// Exemplo: "Novembro 2026".
  static String monthYear(DateTime date) {
    final month = _months[date.month - 1];
    return '${month[0].toUpperCase()}${month.substring(1)} ${date.year}';
  }

  /// Exemplo: "10:42".
  static String time(DateTime date) {
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
