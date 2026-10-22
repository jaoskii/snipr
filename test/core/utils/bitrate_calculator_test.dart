import 'package:flutter_test/flutter_test.dart';
import 'package:media_shrink/core/utils/bitrate_calculator.dart';

void main() {
  group('BitrateCalculator Tests', () {
    test('Calculates safe video & audio bitrate for Discord 25MB limit on a 30s clip', () {
      const targetBytes = 25 * 1024 * 1024; // 25 MB
      const duration = Duration(seconds: 30);

      final result = BitrateCalculator.calculate(
        duration: duration,
        targetSizeBytes: targetBytes,
        includeAudio: true,
      );

      // Verify bitrates
      expect(result.audioBitrateKbps, equals(128));
      expect(result.videoBitrateKbps, greaterThan(5000));
      expect(result.isSafeForTarget, isTrue);
      expect(result.estimatedSizeBytes, lessThanOrEqualTo(targetBytes));
    });

    test('Calculates safe bitrates for 10MB legacy Discord upload', () {
      const targetBytes = 10 * 1024 * 1024; // 10 MB
      const duration = Duration(seconds: 45);

      final result = BitrateCalculator.calculate(
        duration: duration,
        targetSizeBytes: targetBytes,
        includeAudio: true,
      );

      expect(result.isSafeForTarget, isTrue);
      expect(result.estimatedSizeBytes, lessThanOrEqualTo(targetBytes));
    });

    test('Muted video allocates 0 kbps for audio', () {
      const targetBytes = 8 * 1024 * 1024;
      const duration = Duration(seconds: 20);

      final result = BitrateCalculator.calculate(
        duration: duration,
        targetSizeBytes: targetBytes,
        includeAudio: false,
      );

      expect(result.audioBitrateKbps, equals(0));
      expect(result.isSafeForTarget, isTrue);
    });
  });
}
