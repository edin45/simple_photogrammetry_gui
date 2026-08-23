import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path/path.dart' as path;
import 'package:simple_photogrammetry_gui/videoFrameExtractor/videoFrameExtractor.dart';

class VideoFrameExtractorWidget extends StatefulWidget {
  const VideoFrameExtractorWidget({required this.onFramesReady, super.key});

  final void Function(String imageDirectory) onFramesReady;

  @override
  State<VideoFrameExtractorWidget> createState() =>
      _VideoFrameExtractorWidgetState();
}

class _VideoFrameExtractorWidgetState extends State<VideoFrameExtractorWidget> {
  final VideoFrameExtractor extractor = VideoFrameExtractor();
  double progress = 0;
  int processedFrames = 0;
  int totalFrames = 0;
  int savedFrames = 0;
  bool isExtracting = false;
  bool wasCancelled = false;
  String selectedVideo = '';

  @override
  void dispose() {
    extractor.cancel();
    super.dispose();
  }

  Future<void> selectVideo() async {
    const videoTypes = XTypeGroup(
      label: 'videos',
      extensions: ['mp4', 'mov', 'mkv', 'avi', 'm4v', 'webm'],
    );
    final video = await openFile(acceptedTypeGroups: [videoTypes]);
    if (video == null || !mounted) {
      return;
    }

    final parentDirectory = await getDirectoryPath(
      confirmButtonText: 'Save extracted images here',
    );
    if (parentDirectory == null || !mounted) {
      return;
    }

    final videoName = path
        .basenameWithoutExtension(video.path)
        .replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    var outputDirectory = path.join(parentDirectory, '${videoName}_frames');
    var suffix = 2;
    while (await Directory(outputDirectory).exists()) {
      outputDirectory = path.join(
        parentDirectory,
        '${videoName}_frames_$suffix',
      );
      suffix += 1;
    }
    await Directory(outputDirectory).create(recursive: true);

    setState(() {
      selectedVideo = video.path;
      isExtracting = true;
      wasCancelled = false;
      progress = 0;
      processedFrames = 0;
      totalFrames = 0;
      savedFrames = 0;
    });

    try {
      final result = await extractor.extract(
        videoPath: video.path,
        outputDirectory: outputDirectory,
        onProgress: (update) {
          if (!mounted) {
            return;
          }
          setState(() {
            progress = update.progress;
            processedFrames = update.processedFrames;
            totalFrames = update.totalFrames;
            savedFrames = update.savedFrames;
          });
        },
      );
      if (!mounted) {
        return;
      }
      widget.onFramesReady(result.outputDirectory);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${result.savedFrames} clear frames saved and selected as the image folder.',
          ),
        ),
      );
    } catch (error) {
      if (mounted && !wasCancelled) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) {
        setState(() {
          isExtracting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton.icon(
          onPressed: isExtracting ? null : selectVideo,
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(HexColor('#458588')),
          ),
          icon: Icon(Icons.video_file, color: HexColor('#282828')),
          label: Text(
            'Select Video',
            style: TextStyle(color: HexColor('#282828')),
          ),
        ),
        if (isExtracting) ...[
          const Padding(padding: EdgeInsets.all(4)),
          SizedBox(
            width: 500,
            child: LinearProgressIndicator(
              value: totalFrames > 0 ? progress : null,
              color: HexColor('#83a598'),
              backgroundColor: HexColor('#3c3836'),
            ),
          ),
          const Padding(padding: EdgeInsets.all(4)),
          Text(
            'Selecting clear frames: $processedFrames/$totalFrames analysed, $savedFrames saved',
            style: TextStyle(
              color: HexColor('#ebdbb2'),
              fontWeight: FontWeight.w200,
            ),
          ),
          TextButton(
            onPressed: () {
              wasCancelled = true;
              extractor.cancel();
            },
            child: Text(
              'Cancel Video Import',
              style: TextStyle(color: HexColor('#fb4934')),
            ),
          ),
        ] else if (selectedVideo.isNotEmpty)
          Text(
            path.basename(selectedVideo),
            style: TextStyle(
              color: HexColor('#a89984'),
              fontWeight: FontWeight.w200,
            ),
          ),
      ],
    );
  }
}
