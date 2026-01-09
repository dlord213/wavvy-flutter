import 'package:wavvy/models/lyric.dart';

class PlayerUtils {
  static String formatDuration(Duration d) {
    if (d.inHours > 0) {
      final hours = d.inHours;
      final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return "$hours:$minutes:$seconds";
    }
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  static String formatDurationInt(int? ms) {
    if (ms == null) return "--:--";
    final duration = Duration(milliseconds: ms);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  static String formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB"];
    var i = (bytes.toString().length - 1) ~/ 3;
    // simple calculation...
    double size = bytes / (1024 * 1024); 
    return "${size.toStringAsFixed(2)} MB";
  }

  static List<Lyric> parseLrc(String lrc) {
    final List<String> lines = lrc.split('\n');
    final List<Lyric> parsedLyrics = [];
    final RegExp regex = RegExp(r'\[(\d{2}):(\d{2})\.(\d{2,3})\](.*)');

    for (String line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final minutes = int.parse(match.group(1)!);
        final seconds = int.parse(match.group(2)!);
        String msString = match.group(3)!;
        if (msString.length == 2) msString += "0"; // 12 -> 120ms
        final milliseconds = int.parse(msString);

        final text = match.group(4)!.trim();

        parsedLyrics.add(
          Lyric(
            Duration(
              minutes: minutes,
              seconds: seconds,
              milliseconds: milliseconds,
            ),
            text,
          ),
        );
      }
    }

    return parsedLyrics;
  }

  static String extractTextFromDom(dynamic node) {
    if (node is String) return node;

    if (node is List) {
      return node.map((n) => extractTextFromDom(n)).join('');
    }

    if (node is Map) {
      final String content = node['children'] != null
          ? extractTextFromDom(node['children'])
          : '';

      return (node['tag'] == 'p') ? "$content\n\n" : content;
    }

    return '';
  }
}
