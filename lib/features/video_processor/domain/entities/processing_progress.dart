enum ProcessingStage {
  idle,
  analyzing,
  pass1Encoding,
  pass2Encoding,
  losslessCutting,
  completed,
  failed,
}

class ProcessingProgress {
  final ProcessingStage stage;
  final double percentage; // 0.0 to 1.0
  final String statusMessage;
  final String? outputPath;
  final int? outputSizeBytes;

  const ProcessingProgress({
    required this.stage,
    required this.percentage,
    required this.statusMessage,
    this.outputPath,
    this.outputSizeBytes,
  });

  factory ProcessingProgress.initial() => const ProcessingProgress(
        stage: ProcessingStage.idle,
        percentage: 0.0,
        statusMessage: 'Ready',
      );

  factory ProcessingProgress.running({
    required ProcessingStage stage,
    required double percentage,
    required String message,
  }) =>
      ProcessingProgress(
        stage: stage,
        percentage: percentage,
        statusMessage: message,
      );

  factory ProcessingProgress.success({
    required String outputPath,
    required int outputSizeBytes,
  }) =>
      ProcessingProgress(
        stage: ProcessingStage.completed,
        percentage: 1.0,
        statusMessage: 'Export complete!',
        outputPath: outputPath,
        outputSizeBytes: outputSizeBytes,
      );

  factory ProcessingProgress.error(String message) => ProcessingProgress(
        stage: ProcessingStage.failed,
        percentage: 0.0,
        statusMessage: message,
      );
}
