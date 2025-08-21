class DateFormatter {
  // Format: JJ/MM/AAAA
  static String formatDate(DateTime date) {
    return '${_twoDigits(date.day)}/${_twoDigits(date.month)}/${date.year}';
  }

  // Format: JJ/MM/AAAA HH:MM
  static String formatDateTime(DateTime date) {
    return '${formatDate(date)} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  // Format: HH:MM
  static String formatTime(DateTime date) {
    return '${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
  }

  // Ajoute un 0 devant les nombres < 10
  static String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }

  // Format pour les noms de fichiers
  static String formatForFileName(DateTime date) {
    return '${date.year}${_twoDigits(date.month)}${_twoDigits(date.day)}_'
        '${_twoDigits(date.hour)}${_twoDigits(date.minute)}';
  }
}