import 'package:flutter/material.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenModel.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenView.dart';
import 'package:window_manager/window_manager.dart';

String global_max_cpu_threads = "-1";
String splat_training_steps = "30000";
String feature_matching_type = "exhaustive_matcher";
String sequential_matcher_overlap = "30";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1200, 800),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(MaterialApp(home: ScanningScreenView(ScanningScreenModel())));
}
