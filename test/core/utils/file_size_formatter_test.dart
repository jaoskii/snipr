import 'package:flutter_test/flutter_test.dart';
import 'package:media_shrink/core/utils/file_size_formatter.dart';

void main() {
  group('FileSizeFormatter Tests', () {
    test('Formats bytes properly', () {
      expect(FileSizeFormatter.format(1024), equals('1.0 KB'));
      expect(FileSizeFormatter.format(25 * 1024 * 1024), equals('25.0 MB'));
      expect(FileSizeFormatter.format(100 * 1024 * 1024), equals('100.0 MB'));
    });

    test('Formats 0 bytes', () {
      expect(FileSizeFormatter.format(0), equals('0 B'));
    });
  });
}
