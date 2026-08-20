import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenModel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const linuxOnlyReason =
      'This fixture uses a POSIX colmap script and the Linux executable layout. '
      'It does not exercise Windows-specific path handling.';

  group(
    'paths containing spaces',
    () {
      late Directory fixtureDirectory;
      late Directory applicationSupportDirectory;
      late Directory binDirectory;
      late File argumentLog;

      setUpAll(() async {
        fixtureDirectory =
            await Directory.systemTemp.createTemp('spg-fixture-');
        applicationSupportDirectory = Directory(
          '${fixtureDirectory.path}/application-support',
        );
        await applicationSupportDirectory.create();
        argumentLog =
            File('${applicationSupportDirectory.path}/colmap-arguments');
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          (call) async => applicationSupportDirectory.path,
        );

        binDirectory = Directory('${fixtureDirectory.path}/bin');
        await binDirectory.create(recursive: true);
        final colmap = File('${binDirectory.path}/colmap');
        await colmap.writeAsString('''#!/bin/sh
printf '%s\\n' "\$@" > '${argumentLog.path}'
''');
        final chmod = await Process.run('chmod', ['+x', colmap.path]);
        expect(chmod.exitCode, 0, reason: chmod.stderr.toString());
      });

      tearDownAll(() async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
        await fixtureDirectory.delete(recursive: true);
      });

      const pathCases = [
        _PathCase('ordinary paths', 'images', 'output'),
        _PathCase('a spaced image path', 'image folder', 'output'),
        _PathCase('a spaced output path', 'images', 'output folder'),
        _PathCase(
            'spaced image and output paths', 'image folder', 'output folder'),
      ];

      for (final pathCase in pathCases) {
        test(
          'prepares the pipeline workspace with ${pathCase.description}',
          () async {
            final root =
                await Directory.systemTemp.createTemp('spg-path-test-');
            addTearDown(() => root.delete(recursive: true));
            final images = Directory('${root.path}/${pathCase.imageDirectory}');
            final output =
                Directory('${root.path}/${pathCase.outputDirectory}');
            await images.create();
            await output.create();
            final view = _StoppingView();

            await ScanningScreenModel(
              executableDirectory: binDirectory.path,
            ).startScanningProcess(view, images.path, output.path, 0, false);

            expect(view.status, isEmpty);
            expect(
                Directory('${output.path}/temp/sparse').existsSync(), isTrue);
            expect(
              Directory('${output.path}/temp/dense/sparse').existsSync(),
              isTrue,
            );
            expect(
                File('${output.path}/temp/database.db').existsSync(), isTrue);
            expect(
              await argumentLog.readAsLines(),
              containsAllInOrder([
                'feature_extractor',
                '--database_path',
                '${output.path}/temp/database.db',
                '--image_path',
                images.path,
              ]),
            );
          },
        );
      }
    },
    skip: Platform.isLinux ? false : linuxOnlyReason,
  );
}

class _PathCase {
  const _PathCase(this.description, this.imageDirectory, this.outputDirectory);

  final String description;
  final String imageDirectory;
  final String outputDirectory;
}

class _StoppingView {
  bool stop = false;
  bool useGpu = false;
  String status = '';

  void setState(void Function() update) {
    update();
    if (status.startsWith('1/')) {
      stop = true;
    }
  }
}
