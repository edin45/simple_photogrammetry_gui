import 'package:flutter/material.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenModel.dart';
import 'package:simple_photogrammetry_gui/scanningScreen/scanningScreenView.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MaterialApp(home: ScanningScreenView(ScanningScreenModel())));
}
