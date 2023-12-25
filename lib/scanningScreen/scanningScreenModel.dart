import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import 'package:flutter/material.dart';
import 'package:isolate_current_directory/isolate_current_directory.dart';
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
      String colmapPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}colmap${slash}COLMAP.bat' : './dependencies/colmap/colmap';
      String openMvsPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}openMVS${slash}' : './dependencies/openMVS/';
      String texReconPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}' : './dependencies/';
      String decimateMeshPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}' : './dependencies/';
      String textureMeshPath = Platform.isWindows ? 'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}' : './dependencies/';
      
      
      String databasePath = "$outputPath${slash}temp${slash}database.db";
      int totalStepNumber = 10;

      var shell = Shell();

      if(Platform.isWindows) {

        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}sparse\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}dense\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}dense${slash}sparse\' -ItemType Directory"', []);
        await runCommand('powershell -c "New-Item -Path \'$outputPath${slash}temp${slash}database.db\' -ItemType File"', []);
      
      }else{

        

        try{

        await shell.run('''
        mkdir $outputPath${slash}temp
        ''');

        }catch(e) {}

        try{

        await shell.run('''
        mkdir $outputPath${slash}temp${slash}sparse
        ''');

        }catch(e) {}

        try{

        await shell.run('''
        mkdir $outputPath${slash}temp${slash}dense
        ''');

        }catch(e) {}

        try{

        await shell.run('''
        mkdir $outputPath${slash}temp${slash}dense${slash}sparse
        ''');

        }catch(e) {}

        try{

          await shell.run('''
          touch $outputPath${slash}temp${slash}database.db
          ''');

        }catch(e) {}

      }

      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "1/$totalStepNumber Sift Extraction";
      view.setState(() {});
      await runCommand("\"$colmapPath\" feature_extractor --SiftExtraction.use_gpu ${view.useGpu && Platform.isWindows ? 1 : 0} --database_path \"$databasePath\" --image_path \"$imagesPath\"", []);

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

      view.status = "5.1/$totalStepNumber Converting Project";
      view.setState(() {});
      await runCommand("\"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_type TXT", []);

      if (view.stop) {
        stop(view);
        return;
      }

       view.status = "5.2/$totalStepNumber Converting Project";
       view.setState(() {});
       await runCommand("\"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$imagesPath${slash}project.nvm\" --output_type NVM", []);

   //   //  view.status = "5.2/$totalStepNumber Converting Project";
 //     //  view.setState(() {});
   //   //  await runCommand("\"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$imagesPath\" --output_type CAM", []);

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

      int maxImgResolution = 2560;
      int denseRetrys = 1;

      if(Platform.isWindows) {
        await runCommand('powershell -c "del \'$outputPath${slash}temp${slash}model_dense.mvs\'"', []);
      }else{
        await runCommand('rm -rf \'$outputPath${slash}temp${slash}model_dense.mvs\'', []);
      }

      while (!File("$outputPath${slash}temp${slash}model_dense.mvs").existsSync()) {
        if (view.stop) {
          stop(view);
          return;
        }

        print("max_img_resolution: ${maxImgResolution}");

        if (denseRetrys == 1) {
          view.status = "7/$totalStepNumber Densifying Point Cloud";
          view.setState(() {});
        } else {
          view.status = "7/$totalStepNumber Densifying Point Cloud failed, retrying with a max image resolution of $maxImgResolution";
        }
        view.setState(() {});

        if(Platform.isWindows) {

          await runCommand('powershell -c "del \'$outputPath${slash}temp${slash}*.dmap\'"', []);
        
        }else{

          // await runCommand('rm \'$outputPath${slash}temp${slash}*.dmap\'', []);

        }

        await runCommand("\"${openMvsPath}DensifyPointCloud\" --input-file \"$outputPath${slash}temp${slash}model_colmap.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_dense.mvs\" --max-resolution $maxImgResolution", []);
        if(denseRetrys == 5) {
          view.status = "Failed, went wrong at DensifyPointCloud";
          view.setState(() {});
          return;
        }
        denseRetrys++;
        maxImgResolution = (maxImgResolution*0.7).floor();
      }

      if (view.stop) {
        stop(view);
        return;
      }

      double decimationFactorMeshRecon = 1;
        int meshReconRetrys = 1;
        
        while (!File("$outputPath${slash}temp${slash}model_surface.mvs").existsSync()) {
        
        if(decimationFactorMeshRecon == 1.0) {

          view.status = "9/$totalStepNumber Reconstructing Mesh";
          view.setState(() {});
        
        }else{
          view.status = "9/$totalStepNumber Reconstructing Mesh failed, retrying with decimation factor $meshReconRetrys";
          view.setState(() {});
        }

        await runCommand("\"${openMvsPath}ReconstructMesh\" --input-file \"$outputPath${slash}temp${slash}model_dense.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_surface.mvs\" -d ${(2.5+(double.parse(meshReconRetrys.toString())/2)).toString()}  --integrate-only-roi 1 --smooth 1", []);
        decimationFactorMeshRecon=decimationFactorMeshRecon*0.7;

        if(meshReconRetrys == 10) {
          view.status = "Failed, went wrong at Mesh Reconstruction";
            view.setState(() {});
            return;
        }
        meshReconRetrys++;

        }
      
      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "10/$totalStepNumber Texturing Mesh";
      view.setState(() {});

      int texreconRetrys = 1;

      while(!File("$outputPath${slash}textured.obj").existsSync()) {

        if (view.stop) {
        stop(view);
        return;
      }

        if(texreconRetrys > 1 && Platform.isWindows) {
          view.status = "10/$totalStepNumber Texturing Mesh, ran out of memory retrying with lowered resolution (decimation-factor: ${1+((texreconRetrys-1)/2)})";
          view.setState(() {});
          // await runCommand("\"${resizeImagesPath}resizeImages\" -i \"${imagesPath}\" -r ${texrecon_retrys*0.7}", []);
          await runCommand("\"${decimateMeshPath}decimateMesh\" -m \"$outputPath${slash}temp${slash}model_surface.ply\" -o \"$outputPath${slash}temp\" -t ${1+((texreconRetrys-1)/2)}", []);
        }

        if(Platform.isWindows) {
          await runCommand("\"${textureMeshPath}textureMesh\" -m ${texreconRetrys > 1 ? "\"$outputPath${slash}temp${slash}model_surface_decimated.ply\"" : "\"$outputPath${slash}temp${slash}model_surface.ply\""} -p \"$imagesPath${slash}project.nvm\" -o \"$outputPath\"", [],workingFolder: imagesPath);
        }else{

          // await runCommand("\"${openMvsPath}TextureMesh\" --export-type obj --input-file \"$outputPath${slash}temp${slash}model_dense.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_surface.mvs\" -d ${(2.5+(double.parse(meshReconRetrys.toString())/2)).toString()}  --integrate-only-roi 1 --smooth 1", []);

          await runCommand("\"${openMvsPath}TextureMesh\" --input-file \"$outputPath${slash}temp${slash}model_surface.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}textured.mvs\" --export-type obj --decimate ${1/(1+((texreconRetrys-1)/6))}  --resolution-level ${(texreconRetrys-1)}", []);

          // Directory current = Directory.current;

          // await runCommand("\"${current.path.toString().replaceAll("'", "")}${textureMeshPath.replaceFirst(".", "")}textureMesh\" -m ${texreconRetrys > 1 ? "\"$outputPath${slash}temp${slash}model_surface_decimated.ply\"" : "\"$outputPath${slash}temp${slash}model_surface.ply\""} -p \"$imagesPath${slash}project.nvm\" -o \"$outputPath\"", [],workingFolder: imagesPath);

        }

        if(texreconRetrys == 8){
          view.status = "Failed, went wrong at texturing mesh";
          view.setState(() {});
          return;
        }

        texreconRetrys++;

      }

      // while(!File("$outputPath${slash}textured.obj").existsSync()) {

      //   if(texreconRetrys > 1) {
      //     view.status = "10/$totalStepNumber Texturing Mesh, failed retrying with decimation-factor: ${1+((texreconRetrys-1)/2)}";
      //     view.setState(() {});
      //     // await runCommand("\"${resizeImagesPath}resizeImages\" -i \"${imagesPath}\" -r ${texrecon_retrys*0.7}", []);
      //     await runCommand("\"${decimateMeshPath}decimateMesh\" -m \"$outputPath${slash}temp${slash}model_surface.ply\" -o \"$outputPath${slash}temp\" -t ${1+((texreconRetrys-1)/2)}", []);
      //   }

      //   print('working folder: $imagesPath');

      //   await Process.run('"${texReconPath}texrecon" .${slash} "$outputPath${slash}temp${slash}model_surface${texreconRetrys > 1 ? "_decimated" : ""}.ply" "${outputPath}${slash}textured"',[],workingDirectory: texreconRetrys > 1 && false ? "${imagesPath}${slash}downres" : imagesPath).then((ProcessResult results) {
      //     String err = results.stderr.toString();
      //     print('err: $err');
      //     if (err.contains('Permission denied') || err.contains("PermissionDenied")) {
      //       err = "permission_denied";
      //     }
      //     print('command_out: ${results.stdout}');
      //     return err;
      //   });

      //   if(texreconRetrys == 6){
      //     view.status = "Failed, went wrong at texturing mesh";
      //     view.setState(() {});
      //     return;
      //   }

      //   texreconRetrys++;

      // }

      view.status = "Done";
      view.setState(() {});
    }
  }

  int megaByte = 1024 * 1024;

  ramUsageWatcher(int val) {
    // Stop-Process -Name mspaint.exe -Force
    Timer.periodic(const Duration(milliseconds: 100), (timer) async {
      // print('free memory: ${(SysInfo.getFreePhysicalMemory() / megaByte)}');
      if ((SysInfo.getFreePhysicalMemory() / megaByte) < 400) {
        print("To much memory usage, Killing processes");
        if(Platform.isWindows) {
          runCommand('taskkill /IM "RefineMesh.exe" /F', []);
          runCommand('taskkill /IM "TextureMesh.exe" /F', []);
          runCommand('taskkill /IM "ReconstructMesh.exe" /F', []);
          runCommand('taskkill /IM "DensifyPointCloud.exe" /F', []);
          runCommand('taskkill /IM "COLMAP.bat" /F', []);
          runCommand('taskkill /IM "reconstructMesh.exe" /F', []);
          runCommand('taskkill /IM "texrecon.exe" /F', []);
        }else{
          runCommand('killall RefineMesh', []);
          runCommand('killall TextureMesh', []);
          runCommand('killall ReconstructMesh', []);
          runCommand('killall reconstructMesh', []);
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
      // bool hasRemoveOutliers = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}removeOutliers.exe").exists();
      // bool hasReconstructMesh = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}reconstructMesh.exe").exists();
      bool hasTexRecon = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}texrecon.exe").exists();
      bool hasResizeImages = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}resizeImages.exe").exists();
      bool hasDecimateMesh = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}decimateMesh.exe").exists();
      bool hasTextureMesh = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}textureMesh.exe").exists();

      hasAllDependencies = hasColmap && hasOpenMVS && hasTexRecon && hasResizeImages && hasDecimateMesh && hasTextureMesh;
    }
    else if (Platform.isLinux) {

      

      // bool hasColmap = await Directory("~${slash}simple_photogrammetry_gui_external_programs${slash}colmap").exists();

      // bool hasOpenMVS = await Directory("~${slash}simple_photogrammetry_gui_external_programs${slash}openMVS").exists();
      // // bool hasRemoveOutliers = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}removeOutliers.exe").exists();
      // // bool hasReconstructMesh = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}reconstructMesh.exe").exists();
      // bool hasResizeImages = await File("~${slash}simple_photogrammetry_gui_external_programs${slash}resizeImages").exists();
      // bool hasDecimateMesh = await File("~${slash}simple_photogrammetry_gui_external_programs${slash}decimateMesh").exists();
      // bool hasTextureMesh = await File("~${slash}simple_photogrammetry_gui_external_programs${slash}textureMesh").exists();

      // hasAllDependencies = hasColmap && hasOpenMVS && hasResizeImages && hasDecimateMesh && hasTextureMesh;
      hasAllDependencies = true;

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

      // if (!File("./openmvs.zip").existsSync()) {
      //   await runCommand('powershell -c "Invoke-WebRequest -OutFile openmvs.zip -Uri https://github.com/cdcseacave/openMVS/releases/download/v2.1.0/OpenMVS_Windows_x64.7z"', []);
      // }

      String err = await runCommand('powershell -c "Expand-Archive -Path ./colmap.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap\'"', []);

      if (err == "permission_denied") {
        permissionErrorAlert(view);
        return;
      }

      await runCommand('powershell -c "Expand-Archive -Path ./decimateMesh.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui\'"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./resizeImages.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui\'"', []);
      
      await runCommand('powershell -c "Expand-Archive -Path ./textureMesh.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui\'"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./texrecon.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui\'"', []);

      await runCommand('powershell -c "Rename-Item -Path \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}${cuda ? 'COLMAP-3.7-windows-cuda' : 'COLMAP-3.7-windows-no-cuda'}\' -NewName \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}colmap${slash}colmap\'"', []);

      await runCommand('powershell -c "Rename-Item -Path ./${cuda ? 'openmvs_cuda.zip' : 'openmvs_no_cuda.zip'} -NewName ./openmvs.zip"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./openmvs.zip -DestinationPath \'C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}openMVS\'"', []);
    } else if (Platform.isLinux) {

      // Directory current = Directory.current;

      // print("currentDir: $current");

      // await runCommand('echo "hello world"', []);
      // await runCommand('cp -r "./dependencies" "~/simple_photogrammetry_gui_external_programs"', []);
      // await runCommand('cp -r ./openMVS ~/simple_photogrammetry_gui_external_programs', []);

      // bool hasResizeImages = await File("~${slash}simple_photogrammetry_gui_external_programs${slash}resizeImages").exists();
      // bool hasDecimateMesh = await File("~${slash}simple_photogrammetry_gui_external_programs${slash}decimateMesh").exists();
      // bool hasTextureMesh = await File("~${slash}simple_photogrammetry_gui_external_programs${slash}textureMesh").exists();
      
      // ~/.simple_photogrammetry_gui_dependencies/
      // await runCommand('mkdir ~/.simple_photogrammetry_gui_dependencies', []);
      // await runCommand('cp ./removeOutliers ~/.simple_photogrammetry_gui_dependencies/', []);
      // await runCommand('cp ./reconstructMesh ~/.simple_photogrammetry_gui_dependencies/', []);
      // await runCommand('cp ./texrecon ~/.simple_photogrammetry_gui_dependencies/', []);
      // await runCommand('cp ./openMVS ~/.simple_photogrammetry_gui_dependencies/', []);

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
