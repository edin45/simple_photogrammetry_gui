import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

/// Scales images in [sourceDir] to [maxSize] using a fixed pool of [maxConcurrency] threads.
Future<void> downscaleImages(
  String sourceDir, 
  String destDir, 
  int maxSize, {
  int maxConcurrency = 4,
}) async {
  final dir = Directory(sourceDir);
  final dest = Directory(destDir);
  if (!dest.existsSync()) {
    dest.createSync(recursive: true);
  }

  final files = dir.listSync().whereType<File>().where((f) {
    final ext = p.extension(f.path).toLowerCase();
    return ext == '.jpg' || ext == '.jpeg' || ext == '.png';
  }).toList();

  if (files.isEmpty) return;

  // Work-stealing queue to keep exactly [maxConcurrency] isolates busy
  int fileIndex = 0;
  final workers = List.generate(maxConcurrency, (_) async {
    while (fileIndex < files.length) {
      final currentFile = files[fileIndex++];
      await Isolate.run(
        () => _resizeWorker(currentFile.path, destDir, maxSize),
      );
    }
  });

  await Future.wait(workers);
}

/// Standalone top-level worker executed inside an Isolate
void _resizeWorker(String filePath, String destDir, int maxSize) {
  final bytes = File(filePath).readAsBytesSync();
  final image = img.decodeImage(bytes);
  
  if (image == null) return;

  final fileName = p.basename(filePath);
  final outPath = p.join(destDir, fileName);

  // Skip downscaling if already within target dimensions
  if (image.width <= maxSize && image.height <= maxSize) {
    File(filePath).copySync(outPath);
    return;
  }

  int targetWidth = image.width;
  int targetHeight = image.height;
  
  if (image.width > image.height) {
    targetWidth = maxSize;
    targetHeight = (image.height * (maxSize / image.width)).round();
  } else {
    targetHeight = maxSize;
    targetWidth = (image.width * (maxSize / image.height)).round();
  }

  // Fast bilinear resizing suitable for photogrammetry inputs
  final resized = img.copyResize(
    image, 
    width: targetWidth, 
    height: targetHeight, 
    interpolation: img.Interpolation.linear,
  );

  File(outPath).writeAsBytesSync(img.encodeJpg(resized, quality: 95));
}