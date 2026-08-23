import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class VideoFrameExtractionProgress {
  const VideoFrameExtractionProgress({
    required this.progress,
    required this.processedFrames,
    required this.totalFrames,
    required this.savedFrames,
  });

  final double progress;
  final int processedFrames;
  final int totalFrames;
  final int savedFrames;
}

class VideoFrameExtractionResult {
  const VideoFrameExtractionResult({
    required this.outputDirectory,
    required this.savedFrames,
  });

  final String outputDirectory;
  final int savedFrames;
}

class VideoFrameExtractor {
  VideoFrameExtractor({this.executableDirectory});

  final String? executableDirectory;
  Process? _process;

  Future<VideoFrameExtractionResult> extract({
    required String videoPath,
    required String outputDirectory,
    required int framesPerSecond,
    required void Function(VideoFrameExtractionProgress progress) onProgress,
  }) async {
    final command = await _findCommand();
    final process = await Process.start(command.$1, [
      ...command.$2,
      videoPath,
      outputDirectory,
      '--frames-per-second',
      framesPerSecond.toString(),
    ]);
    _process = process;

    String? errorMessage;
    VideoFrameExtractionResult? result;
    final standardError = StringBuffer();

    final outputComplete = process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .forEach((line) {
          final event = jsonDecode(line) as Map<String, dynamic>;
          if (event['event'] == 'progress') {
            onProgress(
              VideoFrameExtractionProgress(
                progress: (event['progress'] as num).toDouble(),
                processedFrames: event['processedFrames'] as int,
                totalFrames: event['totalFrames'] as int,
                savedFrames: event['savedFrames'] as int,
              ),
            );
          } else if (event['event'] == 'complete') {
            result = VideoFrameExtractionResult(
              outputDirectory: event['outputDirectory'] as String,
              savedFrames: event['savedFrames'] as int,
            );
          } else if (event['event'] == 'error') {
            errorMessage = event['message'] as String;
          }
        });
    final errorComplete = process.stderr
        .transform(utf8.decoder)
        .forEach(standardError.write);

    final exitCode = await process.exitCode;
    await Future.wait([outputComplete, errorComplete]);
    _process = null;

    if (exitCode != 0 || result == null) {
      throw VideoFrameExtractionException(
        errorMessage ??
            (standardError.isEmpty
                ? 'Video frame extraction failed'
                : standardError.toString()),
      );
    }
    return result!;
  }

  void cancel() {
    _process?.kill();
  }

  Future<(String, List<String>)> _findCommand() async {
    final executableName = Platform.isWindows
        ? 'videoFrameExtractor.exe'
        : 'videoFrameExtractor';
    final applicationSupport = await getApplicationSupportDirectory();
    final candidates = [
      if (executableDirectory != null)
        path.join(executableDirectory!, executableName),
      path.join(File(Platform.resolvedExecutable).parent.path, executableName),
      path.join(applicationSupport.path, executableName),
    ];
    for (final candidate in candidates) {
      if (await File(candidate).exists()) {
        return (candidate, const <String>[]);
      }
    }

    final developmentScript = path.join(
      Directory.current.path,
      'python',
      'videoFrameExtractor',
      'videoFrameExtractor.py',
    );
    if (await File(developmentScript).exists()) {
      return (Platform.isWindows ? 'py' : 'python3', [developmentScript]);
    }
    throw const VideoFrameExtractionException(
      'videoFrameExtractor is missing. Build the standalone helper before importing a video.',
    );
  }
}

class VideoFrameExtractionException implements Exception {
  const VideoFrameExtractionException(this.message);

  final String message;

  @override
  String toString() => message;
}
