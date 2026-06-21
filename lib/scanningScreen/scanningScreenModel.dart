import 'dart:async';
import 'dart:io';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:process_run/shell.dart';

import 'package:flutter/material.dart';
import 'package:isolate_current_directory/isolate_current_directory.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_photogrammetry_gui/main.dart';
import 'package:simple_photogrammetry_gui/runCommand.dart';
import 'package:system_info2/system_info2.dart';
import 'package:path/path.dart' as p;

class ScanningScreenModel {

  String slash = Platform.isWindows ? "\\" : "/";

  String _getAppDir() {
    final appDir = Platform.environment['APPDIR'];
    if (appDir != null) {
      return "$appDir/usr/bin";
    }else{
      return '/workspace/install/bin';
    }
  }

  showAlert(ColorScheme colorScheme, BuildContext context, String title, List<Widget> buttons, {String? desc, Widget? content, double height = 100}) {
    var alert = AlertDialog(
      backgroundColor: HexColor("#282828"),
      title: Text(
        title,
        style: TextStyle(color: HexColor("#ebdbb2")),
      ),
      content: SizedBox(
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            desc != null
                ? Text(
                    desc,
                    style: TextStyle(color: HexColor("#ebdbb2")),
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

  startScanningProcess(var view, String imagesPath, String outputPath, int qualityLevel, bool photogrammetry_or_splat) async {
    
    final directory = (await getApplicationSupportDirectory()).path;

    if ((await checkDependencies(view))) {
      String appDir = _getAppDir();
      String colmapPath = Platform.isWindows ? '$directory${slash}colmap${slash}COLMAP.bat' : '$appDir/colmap';
      String brushPath = Platform.isWindows ? '$directory${slash}brush${slash}brush_app.exe' : '$appDir/brush/brush_app';
      String openMvsPath = Platform.isWindows ? '$directory${slash}openMVS${slash}' : '$appDir/OpenMVS/';
      // String texReconPath = Platform.isWindows ? '$directory${slash}' : './';
      String decimateMeshPath = Platform.isWindows ? '$directory${slash}' : '$appDir/';
      String textureMeshPath = Platform.isWindows ? '$directory${slash}' : '$appDir/';
      String PoissonRecon = Platform.isWindows ? '$directory${slash}PoissonRecon.exe' : '$appDir/PoissonRecon';
      String SurfaceTrimmer = Platform.isWindows ? '$directory${slash}SurfaceTrimmer.exe' : '$appDir/SurfaceTrimmer';
      String mvs_texturing = Platform.isWindows ? '$directory${slash}texrecon${slash}texrecon.exe' : '$appDir/texrecon';
      
      
      
      String databasePath = "$outputPath${slash}temp${slash}database.db";
      String glomapDatabasePath = "$outputPath${slash}temp${slash}global_database.db";
      int totalStepNumber = 10;

      if(photogrammetry_or_splat) {
        totalStepNumber = 4;
      }

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
        mkdir $outputPath/temp
        ''');

        }catch(e) {}

        try{

        await shell.run('''
        mkdir $outputPath/temp/sparse
        ''');

        }catch(e) {}

        try{

        await shell.run('''
        mkdir $outputPath/temp/dense
        ''');

        }catch(e) {}

        try{

        await shell.run('''
        mkdir $outputPath/temp/dense/sparse
        ''');

        }catch(e) {}

        try{

          await shell.run('''
          touch $outputPath/temp/database.db
          ''');

        }catch(e) {}

      }

      if (view.stop) {
        stop(view);
        return;
      }

      final model_colmap_file = File("$outputPath${slash}temp${slash}model_colmap.mvs");
    
      if (!(await model_colmap_file.exists())) {

        view.status = "1/$totalStepNumber Sift Extraction";
        view.setState(() {});

        print("Threads: $global_max_cpu_threads");

        await runCommand(colmapPath, [
          "feature_extractor",
          "--database_path", databasePath,
          "--image_path", imagesPath,
          "--FeatureExtraction.use_gpu", "${view.useGpu ? 1 : 0}",
          "--FeatureExtraction.num_threads", global_max_cpu_threads,
        ]);

        if (view.stop) {
          stop(view);
          return;
        }

        view.status = "2/$totalStepNumber SiftMatching";
        view.setState(() {});

        await runCommand(colmapPath, [
          "$feature_matching_type",
          "--FeatureMatching.use_gpu", "${view.useGpu ? 1 : 0}",
          "--database_path", databasePath,
          "--FeatureMatching.num_threads", global_max_cpu_threads,
        ]);

        // await runCommand("& \"$colmapPath\" exhaustive_matcher --FeatureMatching.use_gpu ${view.useGpu ? 1 : 0} --database_path \"$databasePath\"", []);

        if (view.stop) {
          stop(view);
          return;
        }

        view.status = "3/$totalStepNumber Aligning Cameras with Glomap";
        view.setState(() {});

        final sourceFile = File(databasePath);
      
        if (await sourceFile.exists()) {
          await sourceFile.copy(glomapDatabasePath);
        }

        // // await runCommand('powershell -c "cp $databasePath $glomapDatabasePath"', []);
        // if(Platform.isWindows) {
        //   await runCommand('powershell -c "cp \'$databasePath\' \'$glomapDatabasePath\'"', []);
        // }else{
        //   // await runCommand('cp $databasePath $glomapDatabasePath', []);
          
        // }

        await runCommand(colmapPath, [
          "view_graph_calibrator",
          "--database_path", glomapDatabasePath,
        ]);

      }

        

        if(photogrammetry_or_splat) {

          await runCommand(colmapPath, [
            "global_mapper",
            "--database_path", glomapDatabasePath,
            "--image_path", imagesPath,
            "--output_path", imagesPath
          ]);

          view.status = "4/$totalStepNumber Training Splat";
          view.setState(() {});

          await runCommand(brushPath, [
            imagesPath,
            //  "--image_path", imagesPath,


            // "--with-viewer",
            "--export-path", outputPath,
            "--total-steps", splat_training_steps
          ],workingFolder: outputPath);

          view.status = "Done";
          view.setState(() {});
          return;

        }else{
          
          if (!(await model_colmap_file.exists())) {

        await runCommand(colmapPath, [
          "global_mapper",
          "--database_path", glomapDatabasePath,
          "--image_path", imagesPath,
          "--output_path", "$outputPath${slash}temp${slash}sparse"
        ]);

        // await runCommand(colmapPath, [
        //   "mapper",
        //   "--database_path", glomapDatabasePath,
        //   "--image_path", imagesPath,
        //   "--output_path", "$outputPath${slash}temp${slash}sparse"
        // ]);

        // await runCommand("& \"$colmapPath\" global_mapper --database_path \"$glomapDatabasePath\" --image_path \"$imagesPath\" --output_path \"$outputPath${slash}temp${slash}sparse\"", []);

        if (view.stop) {
          stop(view);
          return;
        }

        view.status = "4/$totalStepNumber Undistorting Images";
        view.setState(() {});

        await runCommand(colmapPath, [
          "image_undistorter",
          "--image_path", imagesPath,


          "--input_path", "$outputPath${slash}temp${slash}sparse${slash}0",
          
          "--output_path", "$outputPath${slash}temp${slash}dense",

          "--output_type", "COLMAP",
        ]);

        // await runCommand("& \"$colmapPath\" image_undistorter --image_path \"$imagesPath\" --input_path \"$outputPath${slash}temp${slash}sparse${slash}0\" --output_path \"$outputPath${slash}temp${slash}dense\" --output_type COLMAP", []);

        if (view.stop) {
          stop(view);
          return;
        }

        view.status = "5.1/$totalStepNumber Converting Project";
        view.setState(() {});

        await runCommand(colmapPath, [
          "model_converter",
          //  "--image_path", imagesPath,


          "--input_path", "$outputPath${slash}temp${slash}dense${slash}sparse",
          
          "--output_path", "$outputPath${slash}temp${slash}dense${slash}sparse",

          "--output_type", "TXT",
        ]);

        // await runCommand("& \"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_type TXT", []);

        if (view.stop) {
          stop(view);
          return;
        }

        view.status = "5.2/$totalStepNumber Converting Project";
        view.setState(() {});

        await runCommand(colmapPath, [
          "model_converter",
          //  "--image_path", imagesPath,


          "--input_path", "$outputPath${slash}temp${slash}dense${slash}sparse",
          
          "--output_path", "$imagesPath${slash}project.nvm",

          "--output_type", "NVM",
        ]);
        //  await runCommand("& \"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$imagesPath${slash}project.nvm\" --output_type NVM", []);

    //   //  view.status = "5.2/$totalStepNumber Converting Project";
  //     //  view.setState(() {});
    //   //  await runCommand("\"$colmapPath\" model_converter --input_path \"$outputPath${slash}temp${slash}dense${slash}sparse\" --output_path \"$imagesPath\" --output_type CAM", []);

        if (view.stop) {
          stop(view);
          return;
        }

        view.status = "6/$totalStepNumber Converting Project to OpenMVS";
        view.setState(() {});

        await runCommand("${openMvsPath}InterfaceCOLMAP", [
          //  "model_converter",
          "--working-folder", "$outputPath${slash}temp${slash}dense",
          "--input-file", "$outputPath${slash}temp${slash}dense",
          "--output-file", "$outputPath${slash}temp${slash}model_colmap.mvs"
        ]);

          }

      }

      // await runCommand("\"${openMvsPath}InterfaceCOLMAP\" --working-folder \"$outputPath${slash}temp${slash}dense\" --input-file \"$outputPath${slash}temp${slash}dense\" --output-file \"$outputPath${slash}temp${slash}model_colmap.mvs\"", []);

      if (view.stop) {
        stop(view);
        return;
      }

      List dense_quality_levels = [2560, 1920, 512];

      int maxImgResolution = dense_quality_levels[qualityLevel];
      int denseRetrys = 1;

      // if(Platform.isWindows) {
      //   await runCommand('powershell -c "del \'$outputPath${slash}temp${slash}model_dense.mvs\'"', []);
      // }else{
      //   await runCommand('rm $outputPath${slash}temp${slash}model_dense.mvs', []);
      // }

      // final file = File("$outputPath${slash}temp${slash}model_dense.mvs");

      // if (await file.exists()) {
      //   await file.delete();
      // }

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
        
        }

        await runCommand("${openMvsPath}DensifyPointCloud", [
         "--input-file", "$outputPath${slash}temp${slash}model_colmap.mvs",
         "--working-folder", "$outputPath${slash}temp",
         "--output-file", "$outputPath${slash}temp${slash}model_dense.mvs",
         "--max-resolution", maxImgResolution.toString(),
        //  "--crop-to-roi", "0",
         "--roi-border", "10"
        ]);

        // await runCommand("\"${openMvsPath}DensifyPointCloud\" --input-file \"$outputPath${slash}temp${slash}model_colmap.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_dense.mvs\" --max-resolution $maxImgResolution", []);
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


      List mesh_recon_quality_levels = [13,11,9];

      double decimationFactorMeshRecon = 1;
        int meshReconRetrys = 1;
        
        while (!File("$outputPath${slash}temp${slash}model_surface.mvs").existsSync() && !File("$outputPath${slash}temp${slash}model_surface.ply").existsSync()) {
        
        if(decimationFactorMeshRecon == 1.0) {

          view.status = "9/$totalStepNumber Reconstructing Mesh";
          view.setState(() {});
        
        }else{
          view.status = "9/$totalStepNumber Reconstructing Mesh failed, retrying with decimation factor $meshReconRetrys";
          view.setState(() {});
        }

        // await runCommand("${openMvsPath}ReconstructMesh", [
        //  "--input-file", "$outputPath${slash}temp${slash}model_dense.mvs",
        //  "--working-folder", "$outputPath${slash}temp",
        //  "--output-file", "model_surface.mvs",
         
        // //  "--output-file", "$outputPath${slash}temp${slash}model_surface.mvs",
        //  "-d", (2.5+(double.parse(meshReconRetrys.toString())/2)).toString(),
        // //  "--integrate-only-roi", "1",
        // //  "--smooth", "1",
        //  "--remove-spurious", "0",
        // //  "--crop-to-roi", "0"
        // "--roi-border", "10"
        // ]);

        // ./PoissonRecon --in /workspace/Documents/out_test_2/2/temp/model_dense.ply --out /workspace/Documents/out_test_2/2/temp/model_surface_test_d12.ply --depth 12 --density

        // /workspace/PoissonRecon_1/PoissonRecon/Bin/Linux/SurfaceTrimmer --in /workspace/Documents/out_test_2/2/temp/model_surface_test_d12.ply --out /workspace/Documents/out_test_2/2/temp/model_surface_test_d12_cleaned.ply --trim 6 --ascii

        List<String> poissonReconArguments = [
          "--in", "$outputPath${slash}temp${slash}model_dense.ply",
          "--out", "$outputPath${slash}temp${slash}model_surface.ply",
          "--depth", "${mesh_recon_quality_levels[qualityLevel]}",
          // "--pointWeight", "16",
          "--density"
        ]..addAll(poissonExtraFlags.split(" "));

        print("poissonReconArguments: $poissonReconArguments");

        await runCommand(PoissonRecon, poissonReconArguments);

        // await runCommand("\"${openMvsPath}ReconstructMesh\" --input-file \"$outputPath${slash}temp${slash}model_dense.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}temp${slash}model_surface.mvs\" -d ${(2.5+(double.parse(meshReconRetrys.toString())/2)).toString()}  --integrate-only-roi 1 --smooth 1", []);
        decimationFactorMeshRecon=decimationFactorMeshRecon*0.7;
        mesh_recon_quality_levels[qualityLevel] = mesh_recon_quality_levels[qualityLevel] > 1 ? mesh_recon_quality_levels[qualityLevel]-1 : 1;
        
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

        List<String> surfaceTrimerArguments = [
          "--in", "$outputPath${slash}temp${slash}model_surface.ply",
          "--out", "$outputPath${slash}temp${slash}model_surface_cleaned.ply",
          "--trim", "4",
          "--ascii"
        ]..addAll(surfaceTrimmerExtraFlags.split(" "));

        await runCommand(SurfaceTrimmer, surfaceTrimerArguments);
      
      if (view.stop) {
        stop(view);
        return;
      }

      view.status = "10/$totalStepNumber Texturing Mesh";
      view.setState(() {});

      int texreconRetrys = 1;

      
      // texrecon --keep_unseen_faces ./project.nvm /workspace/Documents/out_test_2/2/temp/model_surface_test_d12_cleaned.ply /workspace/Documents/out_test_2/model_surface_test_d12_cleaned_textured6

      await runCommand(mvs_texturing, [
          "--keep_unseen_faces",
          "$imagesPath${slash}project.nvm",
          "$outputPath${slash}temp${slash}model_surface_cleaned.ply",
          "$outputPath${slash}textured"
          
        ],workingFolder: imagesPath);

        if(!File("$outputPath${slash}textured.obj").existsSync()) {
          view.status = "Failed, went wrong at texturing mesh";
          view.setState(() {});
          return;
        }

      

      // while(!File("$outputPath${slash}textured.obj").existsSync()) {

      //   if (view.stop) {
      //   stop(view);
      //   return;
      // }

      //   if(texreconRetrys > 1) {
      //     view.status = "10/$totalStepNumber Texturing Mesh, ran out of memory retrying with lowered resolution (decimation-factor: ${1+((texreconRetrys-1)/2)})";
      //     view.setState(() {});
      //     // await runCommand("\"${resizeImagesPath}resizeImages\" -i \"${imagesPath}\" -r ${texrecon_retrys*0.7}", []);
      //     await runCommand("${decimateMeshPath}decimateMesh", [
      //       "-m", "$outputPath${slash}temp${slash}model_surface.ply",
      //       "-o", "$outputPath${slash}temp",
      //       "-t", "${1+((texreconRetrys-1)/2)}"
      //     ]);
      //     // await runCommand("\"${decimateMeshPath}decimateMesh\" -m \"$outputPath${slash}temp${slash}model_surface.ply\" -o \"$outputPath${slash}temp\" -t ${1+((texreconRetrys-1)/2)}", []);
      //   }

      //   // await runCommand("${textureMeshPath}${Platform.isWindows ? "textureMesh" : "run_texturing.sh"}", [
      //   //     "-m", texreconRetrys > 1 ? "$outputPath${slash}temp${slash}model_surface_decimated.ply" : "$outputPath${slash}temp${slash}model_surface.ply",
      //   //     "-p", "$imagesPath${slash}project.nvm",
      //   //     "-o", outputPath
      //   // ],workingFolder: imagesPath);

      //   await runCommand("${openMvsPath}TextureMesh", [
      //     "--input-file", "$outputPath${slash}temp${slash}model_colmap.mvs",
      //     "--mesh-file", "$outputPath${slash}temp${slash}model_surface.ply",
      //     "--working-folder", "$outputPath${slash}temp",
      //     "--output-file", "$outputPath${slash}textured.mvs",
      //     "--export-type", "obj",
      //     "--decimate", "${1/(1+((texreconRetrys-1)/6))}",
      //     "--resolution-level", "${(texreconRetrys-1)}"
      //   ],workingFolder: imagesPath);

      //   // await runCommand("${textureMeshPath}textureMesh -m ${texreconRetrys > 1 ? "\"$outputPath${slash}temp${slash}model_surface_decimated.ply\"" : "\"$outputPath${slash}temp${slash}model_surface.ply\""} -p \"$imagesPath${slash}project.nvm\" -o \"$outputPath\"", [],workingFolder: imagesPath);

      //   // await runCommand("\"${openMvsPath}TextureMesh\" --input-file \"$outputPath${slash}temp${slash}model_surface.mvs\" --working-folder \"$outputPath${slash}temp\" --output-file \"$outputPath${slash}textured.mvs\" --export-type obj --decimate ${1/(1+((texreconRetrys-1)/6))}  --resolution-level ${(texreconRetrys-1)}", []);

      //   if(texreconRetrys == 8){
      //     view.status = "Failed, went wrong at texturing mesh";
      //     view.setState(() {});
      //     return;
      //   }

      //   texreconRetrys++;

      // }

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
    
    final directory = (await getApplicationSupportDirectory()).path;

    print("Directory: $directory");

    bool hasAllDependencies = false;
    if (Platform.isWindows) {
      bool hasColmap = await Directory("$directory${slash}colmap").exists();
      bool hasOpenMVS = await Directory("$directory${slash}openMVS").exists();
      // bool hasRemoveOutliers = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}removeOutliers.exe").exists();
      // bool hasReconstructMesh = await File("C:${slash}Program Files${slash}simple_photogrammetry_gui${slash}reconstructMesh.exe").exists();
      bool hasTexRecon = await File("$directory${slash}texrecon${slash}texrecon.exe").exists();
      bool hasResizeImages = await File("$directory${slash}resizeImages.exe").exists();
      bool hasDecimateMesh = await File("$directory${slash}decimateMesh.exe").exists();
      bool hasTextureMesh = await File("$directory${slash}textureMesh.exe").exists();
      bool hasPoissonRecon = await File("$directory${slash}PoissonRecon.exe").exists();
      bool hasSurfaceTrimmer = await File("$directory${slash}SurfaceTrimmer.exe").exists();
      // bool hasTexRecon = await File("$directory${slash}SurfaceTrimmer.exe").exists();

      hasAllDependencies = hasColmap && hasOpenMVS && hasTexRecon && hasResizeImages && hasDecimateMesh && hasTextureMesh && hasPoissonRecon && hasSurfaceTrimmer;
    }
    else if (Platform.isLinux) {

      

      // bool hasColmap = (await runCommand('colmap',[])).toString().trim().contains("COLMAP");
      
      // bool hasOpenMVS = await Directory("~/.simple_photogrammetry_gui_dependencies/openMVS").exists();
      // bool hasRemoveOutliers = await File("~/.simple_photogrammetry_gui_dependencies/removeOutliers").exists();
      // bool hasReconstructMesh = await File("~/.simple_photogrammetry_gui_dependencies/reconstructMesh").exists();
      // bool hasTexRecon = await File("~/.simple_photogrammetry_gui_dependencies/texrecon").exists();
      
      hasAllDependencies = true;// && hasOpenMVS && hasRemoveOutliers && hasReconstructMesh && hasTexRecon;

    }
    if (!hasAllDependencies) {
      showAlert(
          view.colorScheme,
          view.context,
          "Some dependencies are missing, download them now?",
          [
            Platform.isLinux ? Container() : TextButton(
                onPressed: () async {
                  Navigator.pop(view.context);

                  view.isDownloadingDependencies = true;
                  view.setState(() {});

                  await downloadDependencies(view, true);

                  is_non_cuda_version = false;

                  if(Platform.isWindows) {

                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool("is_non_cuda_version", false);

                  }

                  view.isDownloadingDependencies = false;
                  view.setState(() {});
                },
                child: Text(
                  "Yes (CUDA)",
                  style: TextStyle(color: HexColor("#ebdbb2"), fontSize: 18),
                )),
            TextButton(
                onPressed: () async {
                  Navigator.pop(view.context);

                  view.isDownloadingDependencies = true;
                  view.setState(() {});

                  await downloadDependencies(view, false);

                  is_non_cuda_version = true;

                  if(Platform.isWindows) {

                    final SharedPreferences prefs = await SharedPreferences.getInstance();

                    prefs.setBool("is_non_cuda_version", true);

                  }

                  view.isDownloadingDependencies = false;
                  view.setState(() {});
                },
                child: Text(
                  "Yes${Platform.isLinux ? "" : " (No CUDA)"}",
                  style: TextStyle(color: HexColor("#ebdbb2"), fontSize: 18),
                )),
            TextButton(
                onPressed: () {
                  Navigator.pop(view.context);
                },
                child: Text(
                  "No",
                  style: TextStyle(color: HexColor("#ebdbb2"), fontSize: 18),
                ))
          ],
          
          /*desc: Platform.isLinux ? "This requires the application to be run with sudo" : "This requires the application to be run as adminstrator"*/);
    }
    return hasAllDependencies;
  }

  downloadDependencies(var view, bool cuda) async {

    final directory = (await getApplicationSupportDirectory()).path;

    print("Directory: $directory");

    if (Platform.isWindows) {
      if (!File("./colmap.zip").existsSync()) {
        await runCommand('powershell -c "Invoke-WebRequest -OutFile colmap.zip -Uri https://github.com/colmap/colmap/releases/download/4.0.4/${cuda ? "colmap-x64-windows-cuda.zip" : "colmap-x64-windows-nocuda.zip"}"', []);
      }

      // if (!File("./openmvs.zip").existsSync()) {
      //   await runCommand('powershell -c "Invoke-WebRequest -OutFile openmvs.zip -Uri https://github.com/cdcseacave/openMVS/releases/download/v2.1.0/OpenMVS_Windows_x64.7z"', []);
      // }

      String err = await runCommand('powershell -c "Expand-Archive -Path ./colmap.zip -DestinationPath \'$directory${slash}colmap\'"', []);

      if (err == "permission_denied") {
        permissionErrorAlert(view);
        return;
      }

      await runCommand('powershell -c "Expand-Archive -Path ./decimateMesh.zip -DestinationPath \'$directory\'"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./resizeImages.zip -DestinationPath \'$directory\'"', []);
      
      await runCommand('powershell -c "Expand-Archive -Path ./textureMesh.zip -DestinationPath \'$directory\'"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./texrecon.zip -DestinationPath \'$directory\'"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./PoissonRecon.zip -DestinationPath \'$directory\'"', []);

      await runCommand('powershell -c "Rename-Item -Path \'$directory${slash}colmap${slash}${cuda ? 'colmap-x64-windows-cuda' : 'colmap-x64-windows-nocuda'}\' -NewName \'$directory${slash}colmap${slash}colmap\'"', []);

      await runCommand('powershell -c "Rename-Item -Path ./${cuda ? 'openmvs_cuda.zip' : 'openmvs_no_cuda.zip'} -NewName ./openmvs.zip"', []);

      await runCommand('powershell -c "Expand-Archive -Path ./openmvs.zip -DestinationPath \'$directory${slash}openMVS\'"', []);
    } else if (Platform.isLinux) {
      String err = await runCommand('apt', ['install', 'colmap']);
      if (err == "permission_denied") {
        permissionErrorAlert(view);
        return;
      }
      // ~/.simple_photogrammetry_gui_dependencies/
      // await runCommand('mkdir ~/.simple_photogrammetry_gui_dependencies', []);
      // await runCommand('cp ./removeOutliers ~/.simple_photogrammetry_gui_dependencies/', []);
      // await runCommand('cp ./reconstructMesh ~/.simple_photogrammetry_gui_dependencies/', []);
      // await runCommand('cp ./texrecon ~/.simple_photogrammetry_gui_dependencies/', []);
      // await runCommand('cp ./openMVS ~/.simple_photogrammetry_gui_dependencies/', []);

    }
  }

  permissionErrorAlert(var view) {
    showAlert(view.colorScheme, view.context, "Permission Error - Permission Denied", [
      TextButton(
          onPressed: () {
            Navigator.pop(view.context);
          },
          child: Text(
            "Ok",
            style: TextStyle(color: HexColor("#ebdbb2")),
          ))
    ]);
  }
}
