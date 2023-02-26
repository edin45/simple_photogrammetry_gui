import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:simple_photogrammetry_gui/runCommand.dart';
import 'package:system_info2/system_info2.dart';

class ScanningScreenModel {

  String slash = Platform.isWindows ? "\\" : "/";

  showAlert(ColorScheme colorScheme, BuildContext context, String title, List<Widget> buttons, {String? desc, Widget? content}) {
    var alert = AlertDialog(
      backgroundColor: colorScheme.background,
      title: Text(
        title,
        style: TextStyle(color: colorScheme.onBackground),
      ),
      content: SizedBox(
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            desc != null
                ? Text(
                    desc,
                    style: TextStyle(color: colorScheme.onBackground),
                  )
                : Container(),
            content ?? Container(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: buttons,
            ),
          ],
        ),
      ),
    );
    showDialog(context: context, builder: (_) => alert);
  }

  startScanningProcess(var view, String imagesPath, String outputPath) async {
    if ((await checkDependencies(view))) {
      // "C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}colmap${slash}COLMAP.bat"
      String colmapPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}colmap${slash}COLMAP.bat' : 'colmap';
      String openMvsPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}openMVS${slash}' : '';
      String databasePath = "$outputPath${slash}temp${slash}database.db";
      int totalStepNumber = 10;

      if(Platform.isWindows) {

        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}sparse\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}dense\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}dense${slash}sparse\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}database.db\' -ItemType File"', []);
      
      }else{

        await runCommand("mkdir $outputPath/temp", []);
        await runCommand("mkdir $outputPath/temp/sparse", []);
        await runCommand("mkdir $outputPath/temp/dense", []);
        await runCommand("mkdir $outputPath/temp/dense/sparse", []);
        await runCommand("touch $outputPath/temp/database.db", []);

      }

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "1/$totalStepNumber Sift Extraction";
      view.setState(() {});
      await runCommand("\"$colmapPath\" feature_extractor --SiftExtraction.use_gpu ${view.useGpu ? 1 : 0} --database_path \"$databasePath\" --image_path \"$imagesPath\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "2/$totalStepNumber SiftMatching";
      view.setState(() {});
      await runCommand("\"$colmapPath\" exhaustive_matcher --SiftMatching.use_gpu ${view.useGpu ? 1 : 0} --database_path \"$databasePath\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "3/$totalStepNumber Converting Project";
      view.setState(() {});
      await runCommand("\"$colmapPath\" mapper --database_path \"$databasePath\" --image_path \"$imagesPath\" --output_path \"$outputPath${slash}temp${slash}sparse\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "4/$totalStepNumber Undistorting Images";
      view.setState(() {});
      await runCommand("\"$colmapPath\" image_undistorter --image_path \"$imagesPath\" --input_path \"$outputPath${slash}temp${slash}sparse${slash}0\" --output_path \"$outputPath${slash}temp${slash}dense\" --output_type COLMAP", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "5/$totalStepNumber Converting Project";
      view.setState(() {});
      await runCommand("\"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_type TXT", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "6/$totalStepNumber Converting Project to OpenMVS";
      view.setState(() {});
      await runCommand("\"${openMvsPath}InterfaceCOLMAP\" --working-folder \"$outputPath${slash}temp${slash}dense\" --input-file \"$outputPath${slash}temp${slash}dense\" --output-file \"$outputPath${slash}temp${slash}model_colmap.mvs\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "7/$totalStepNumber Densifying Point Cloud";
      view.setState(() {});
      await runCommand("\"${openMvsPath}DensifyPointCloud\" --input-file \"$outputPath${slash}temp${slash}model_colmap.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_dense.mvs\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "8/$totalStepNumber Reconstructing Mesh";
      view.setState(() {});
      await runCommand("\"${openMvsPath}ReconstructMesh\" --input-file \"$outputPath${slash}temp${slash}model_dense.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_surface.mvs\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      double decimationFactor = 0;
      int imgScaleDownFactor = 0;
      bool useDecimationFactor = false;

      while (!File("$outputPath${slash}temp${slash}model_surface_refined.mvs").existsSync()) {
        if (view.stop) {
          stop(view);
          return;
        }

        if (decimationFactor == 0) {
          view.status = "9/$totalStepNumber Refining Mesh";
          view.setState(() {});
        } else {
          view.status = "9/$totalStepNumber Refining Mesh failed, retrying with image scale-down factor $imgScaleDownFactor, and decimation factor $decimationFactor";
          view.setState(() {});
        }

        await runCommand("\"${openMvsPath}RefineMesh\" --input-file \"$outputPath${slash}temp${slash}model_surface.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_surface_refined.mvs\" --reduce-memory 1 --decimate $decimationFactor --resolution-level $imgScaleDownFactor", []);

        imgScaleDownFactor++;

        if (useDecimationFactor) {
          decimationFactor-=0.1;
        }

        if (imgScaleDownFactor == 5 && useDecimationFactor == false) {
          imgScaleDownFactor = 0;
          decimationFactor = 0.9;
          useDecimationFactor = true;
          continue;
        }

        if (imgScaleDownFactor == 5 && useDecimationFactor) {
          view.status = "Failed";
          view.setState(() {});
          return;
        }
      }

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "10/$totalStepNumber Texturing Mesh";
      view.setState(() {});
      await runCommand("\"${openMvsPath}TextureMesh\" --input-file \"$outputPath${slash}temp${slash}model_surface_refined.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}textured.mvs\" --export-type obj", []);

      view.status = "Done";
      view.setState(() {});
      // await runCommand("\"$colmapPath\" feature_extractor exhaustive_matcher --SiftMatching.use_gpu 0 --database_path \"$outputPath${slash}temp${slash}database.db\"", []);
      //colmap mapper --database_path $outputPath${slash}temp${slash}database.db --image_path $imagesPath --output_path $PROJECT/sparse
    }
  }

  int megaByte = 1024 * 1024;

  ramUsageWatcher(int val) {
    // Stop-Process -Name mspaint.exe -Force
    Timer.periodic(const Duration(milliseconds: 200), (timer) async {
      // print('free memory: ${(SysInfo.getFreePhysicalMemory() / megaByte)}');
      if ((SysInfo.getFreePhysicalMemory() / megaByte) < 400) {
        print("To much memory usage, Killing processes");
        if(Platform.isWindows) {
          runCommand('taskkill /IM "RefineMesh.exe" /F', []);
          runCommand('taskkill /IM "TextureMesh.exe" /F', []);
          runCommand('taskkill /IM "ReconstructMesh.exe" /F', []);
          runCommand('taskkill /IM "DensifyPointCloud.exe" /F', []);
          runCommand('taskkill /IM "COLMAP.bat" /F', []);
        }else{
          runCommand('killall RefineMesh', []);
          runCommand('killall TextureMesh', []);
          runCommand('killall ReconstructMesh', []);
          runCommand('killall DensifyPointCloud', []);
          runCommand('killall colmap', []);
        }
      }
    });
  }

  stop(var view) {
    view.status = "";
    view.setState(() {});
  }

  checkDependencies(var view) async {
    bool hasAllDependencies = false;
    if (Platform.isWindows) {
      bool hasColmap = await Directory("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap").exists();
      bool hasOpenMVS = await Directory("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}openMVS").exists();

      hasAllDependencies = hasColmap && hasOpenMVS;
    }
    else if (Platform.isLinux) {

      bool hasColmap = (await runCommand('colmap',[])).toString().trim() != "";
      bool hasOpenMVS = (await runCommand('DensifyPointCloud',[])).toString().trim() != "";//ile("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}openMVS").existsSync();
      hasAllDependencies = hasColmap && hasOpenMVS;

    }
    if (!hasAllDependencies) {
      showAlert(
          view.colorScheme,
          view.context,
          "Some dependencies are missing, download them now?",
          [
            TextButton(
                onPressed: () async {
                  Navigator.pop(view.context);

                  view.isDownloadingDependencies = true;
                  view.setState(() {});

                  await downloadDependencies(view, true);

                  view.isDownloadingDependencies = false;
                  view.setState(() {});
                },
                child: Text(
                  "Yes (CUDA)",
                  style: TextStyle(color: view.colorScheme.onBackground, fontSize: 18),
                )),
            TextButton(
                onPressed: () async {
                  Navigator.pop(view.context);

                  view.isDownloadingDependencies = true;
                  view.setState(() {});

                  await downloadDependencies(view, false);

                  view.isDownloadingDependencies = false;
                  view.setState(() {});
                },
                child: Text(
                  "Yes (No CUDA)",
                  style: TextStyle(color: view.colorScheme.onBackground, fontSize: 18),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(view.context);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: view.colorScheme.onBackground, fontSize: 18),
                ))
          ],
          desc: Platform.isLinux ? "This requires the application to be run with sudo" : "This requires the application to be run as adminstrator");
    }
    return hasAllDependencies;
  }

  downloadDependencies(var view, bool cuda) async {
    if (Platform.isWindows) {
      if (!File("./colmap.zip").existsSync()) {
        await runCommand('powershell -c "Invoke-WebRequest -OutFile colmap.zip -Uri https://github.com/colmap/colmap/releases/download/3.7/${cuda ? "COLMAP-3.7-windows-cuda.zip" : "COLMAP-3.7-windows-no-cuda.zip"}"', []);
      }

      if (!File("./openmvs.zip").existsSync()) {
        await runCommand('powershell -c "Invoke-WebRequest -OutFile openmvs.zip -Uri https://github.com/cdcseacave/openMVS/releases/download/v2.1.0/OpenMVS_Windows_x64.7z"', []);
      }

      String err = await runCommand('powershell -c "Expand-Archive -Path ./colmap.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap\'"', []);

      if (err == "permission_denied") {
        permissionErrorAlert(view);
        return;
      }

      await runCommand('powershell -c "Rename-Item -Path \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}${cuda ? 'COLMAP-3.7-windows-cuda' : 'COLMAP-3.7-windows-no-cuda'}\' -NewName \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}colmap\'"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./openmvs.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}openMVS\'"', []);
    } else if (Platform.isLinux) {
      String err = await runCommand('apt', ['install', 'colmap']);
      if (err == "permission_denied") {
        permissionErrorAlert(view);
        return;
      }

    }
  }

  permissionErrorAlert(var view) {
    showAlert(view.colorScheme, view.context, Platform.isLinux ? "You have to run this application with sudo to install dependencies" : "You have to run this application as adminstrator to install dependencies", [
      TextButton(
          onPressed: () {
            Navigator.pop(view.context);
          },
          child: Text(
            "Ok",
            style: TextStyle(color: view.colorScheme.onBackground),
          ))
    ]);
  }
}
