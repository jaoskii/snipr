class TimeFormatter {
  static String format(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    final int milliseconds = (duration.inMilliseconds.remainder(1000) / 10).floor();

    final String mStr = minutes.toString().padLeft(2, '0');
    final String sStr = seconds.toString().padLeft(2, '0');
    final String msStr = milliseconds.toString().padLeft(2, '0');

    return '$mStr:$sStr.$msStr';
  }

  static String formatShort(Duration duration) {
    final int minutes = duration.inMinutes;
    final int seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
