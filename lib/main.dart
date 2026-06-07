import 'package:flutter/material.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenModel.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenView.dart';
import 'package:window_manager/window_manager.dart';

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
