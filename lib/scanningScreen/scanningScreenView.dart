import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:url_launcher/url_launcher.dart';

class ScanningScreenView extends StatefulWidget {
  late var model;

  ScanningScreenView(this.model, {super.key});

  @override
  State<ScanningScreenView> createState() => _ScanningScreenViewState();
}

class _ScanningScreenViewState extends State<ScanningScreenView> {
  String imageFolder = "";
  String outputFolder = "";
  late ColorScheme colorScheme;

  bool isDownloadingDependencies = false;
  bool useGpu = true;
  bool stop = false;
  bool reconstructAndTextureMesh = false;

  String status = "";

  bool hasAllDependencies = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    Isolate.spawn(widget.model.ramUsageWatcher, 0);

    asyncTasks() async {
      hasAllDependencies = await widget.model.checkDependencies(this);
      setState(() {});
    }
    asyncTasks();
    
  }

  @override
  Widget build(BuildContext context) {
    bool running = status != "" && status != "Done" && status != "Failed";

    return DynamicColorBuilder(builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
      colorScheme = darkDynamic ?? const ColorScheme.dark();
      return Scaffold(
        backgroundColor: colorScheme.background,
        body: isDownloadingDependencies
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                    Text(
                      "downloading dependencies...",
                      style: TextStyle(color: colorScheme.onBackground),
                    )
                  ],
                ),
              )
            : Stack(
                children: [
                  Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundCheckBox(
                          size: 30,
                          isChecked: useGpu,
                          checkedColor: colorScheme.primary,
                          disabledColor: colorScheme.background,
                          uncheckedColor: colorScheme.background,
                          checkedWidget: Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
                          ),
                          onTap: (selected) {
                            useGpu = selected ?? true;
                            setState(() {});
                          },
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Text(
                          'Use GPU when possible',
                          style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.normal),
                        )
                      ],
                    ),
                    /*const Padding(padding: EdgeInsets.all(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        RoundCheckBox(
                          size: 30,
                          isChecked: reconstructAndTextureMesh,
                          checkedColor: colorScheme.primary,
                          disabledColor: colorScheme.background,
                          uncheckedColor: colorScheme.background,
                          checkedWidget: Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
                          ),
                          onTap: (selected) {
                            reconstructAndTextureMesh = (selected ?? false);
                            setState(() {});
                          },
                        ),
                        const Padding(padding: EdgeInsets.all(5)),
                        Text(
                          'Reconstruct & Texture Mesh (High memory usage)',
                          style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.normal),
                        )
                      ],
                    ),*/
                    const Padding(padding: EdgeInsets.all(10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          imageFolder == "" ? "No image folder selected" : imageFolder,
                          style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.w200),
                        ),
                        const Padding(padding: EdgeInsets.all(10.0)),
                        TextButton(
                          onPressed: () async {
                            String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

                            if (selectedDirectory == null) {
                              // User canceled the picker
                            } else {
                              imageFolder = selectedDirectory;
                            }
                            setState(() {});
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return colorScheme.primaryContainer;
                            }
                            return colorScheme.primary;
                          })),
                          child: Text(
                            '${imageFolder == "" ? "Select" : "Change"} Image Folder',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          outputFolder == "" ? "No output folder selected" : outputFolder,
                          style: TextStyle(color: colorScheme.onBackground, fontWeight: FontWeight.w200),
                        ),
                        const Padding(padding: EdgeInsets.all(10.0)),
                        TextButton(
                          onPressed: () async {
                            String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

                            if (selectedDirectory == null) {
                              // User canceled the picker
                            } else {
                              outputFolder = selectedDirectory;
                            }
                            setState(() {});
                          },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return colorScheme.primaryContainer;
                            }
                            return colorScheme.primary;
                          })),
                          child: Text(
                            '${outputFolder == "" ? "Select" : "Change"} Output Folder',
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                        ),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(8)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextButton(
                          onPressed: () async {
                            if (imageFolder == "") {
                              widget.model.showAlert(colorScheme, context, "You have to select an image folder", [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Ok",
                                      style: TextStyle(color: colorScheme.onBackground),
                                    ))
                              ]);
                            } else if (outputFolder == "") {
                              widget.model.showAlert(colorScheme, context, "You have to select an output folder", [
                                TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: Text(
                                      "Ok",
                                      style: TextStyle(color: colorScheme.onBackground),
                                    ))
                              ]);
                            } else {
                              stop = false;
                              widget.model.startScanningProcess(this, imageFolder, outputFolder);
                            }
                          },
                          //  : () {
                          //   widget.model.startScanningProcess(this, imageFolder, outputFolder);
                          // },
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return colorScheme.primaryContainer;
                            }
                            return colorScheme.primary;
                          })),
                          child: Text(
                            // hasAllDependencies ? 
                            'Start',
                            //  : "Install Dependencies (Needs Adminstrator rights)",
                            style: TextStyle(color: colorScheme.onPrimary),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.all(8)),
                        running
                            ? TextButton(
                                onPressed: () async {
                                  stop = true;
                                  status = "Stopping...";
                                  setState(() {});
                                },
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return colorScheme.errorContainer;
                                  }
                                  return colorScheme.error;
                                })),
                                child: Text(
                                  'Stop',
                                  style: TextStyle(color: colorScheme.onError),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    const Padding(padding: EdgeInsets.all(20)),
                    Text(
                      status,
                      style: TextStyle(fontSize: 21, color: colorScheme.onBackground),
                    ),
                    const Padding(padding: EdgeInsets.all(10)),
                    running
                        ? Center(
                            child: SizedBox(
                                width: 150,
                                child: LinearProgressIndicator(
                                  backgroundColor: colorScheme.primary,
                                  color: colorScheme.onPrimary,
                                )),
                          )
                        : Container()
                  ]),
                  Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () {
                          var alert = AlertDialog(
                            backgroundColor: colorScheme.background,
                            title: Text(
                              "Simple photogrammetry gui is based on:",
                              style: TextStyle(color: colorScheme.onBackground),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                linkWidget("1. Colmap", "https://colmap.github.io/"),
                                linkWidget("2. OpenMVS", "https://github.com/cdcseacave/openMVS"),
                                linkWidget("3. mvs-texturing", "https://github.com/nmoehrle/mvs-texturing"),
                                linkWidget("4. pymeshlab", "https://github.com/cnr-isti-vclab/PyMeshLab"),
                              ],
                            ),
                          );
                          showDialog(context: context, builder: (_) => alert);
                        },
                        child: Container(
                          color: Colors.transparent,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Icon(Icons.question_mark,color: colorScheme.onBackground,),
                          ),
                        ),
                      ))
                ],
              ),
      );
    });
  }

  linkWidget(String text, String url) {
    return GestureDetector(
      onTap: () async {
        if (!await launchUrl(Uri.parse(url))) {
          throw Exception('Could not launch $url');
        }
      },
      child: Text(
        text,
        style: TextStyle(color: colorScheme.onBackground, decoration: TextDecoration.underline),
      ),
    );
  }
}
