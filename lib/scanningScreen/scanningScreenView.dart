import 'dart:io';
import 'dart:isolate';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:roundcheckbox/roundcheckbox.dart';
import 'package:simple_photogrammetry_gui/TitleBar/TitleBar.dart';
import 'package:simple_photogrammetry_gui/main.dart';
import 'package:simple_photogrammetry_gui/runCommand.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hexcolor/hexcolor.dart';

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
  bool useGpu = is_non_cuda_version ? false : true;
  bool stop = false;
  bool reconstructAndTextureMesh = false;

  String status = "";

  bool hasAllDependencies = false;

  bool photogrammetry_or_splat = false;

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
        backgroundColor: HexColor("#282828"),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                TitleBar(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: GestureDetector(
                            onTap: () {
                              var alert = AlertDialog(
                                backgroundColor: HexColor("#282828"),
                                // title: Text(
                                //   "Scan Settings:",
                                //   style: TextStyle(color: HexColor("#ebdbb2")),
                                // ),
                                content: Container(
                                  height: 310,
                                  width: 400,
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text("SfM Settings",style: TextStyle(color: HexColor("#ebdbb2"),fontSize: 15,fontWeight: FontWeight.bold),),
                                      Padding(padding: EdgeInsets.all(2)),

                                      settingWidget("Max Cpu Threads (can help with ram usage) -1 == All",global_max_cpu_threads, (value) {
                                        global_max_cpu_threads = value;
                                      }),
                                      
                                      settingWidgetDropdown("Feature Matching Type",feature_matching_type, (value) {
                                        feature_matching_type = value;
                                      },[
                                        DropdownMenuEntry(value: 'exhaustive_matcher', label: 'exhaustive_matcher',style: MenuItemButton.styleFrom(
                                            foregroundColor: HexColor("#ebdbb2"), // Your text color here
                                          ),),
                                        DropdownMenuEntry(value: 'sequential_matcher', label: 'sequential_matcher',style: MenuItemButton.styleFrom(
                                            foregroundColor: HexColor("#ebdbb2"), // Your text color here
                                          ),),
                                      ]),
                                      
                                      settingWidget("Sequential Matcher Overlap",sequential_matcher_overlap, (value) {
                                        sequential_matcher_overlap = value;
                                      }),

                                      Padding(padding: EdgeInsets.all(2)),
                                      Text("Gaussian Splat Settings",style: TextStyle(color: HexColor("#ebdbb2"),fontSize: 15,fontWeight: FontWeight.bold),),
                                      Padding(padding: EdgeInsets.all(2)),

                                      settingWidget("Splat Training Steps",splat_training_steps, (value) {
                                        splat_training_steps = value;
                                      }),
                                      
                                    ],
                                  ),
                                ),
                                
                              );
                              showDialog(context: context, builder: (_) => alert);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.settings,color: HexColor("#ebdbb2"),),
                              ),
                            ),
                          ),
                  ),
                  Align(
                          alignment: Alignment.topRight,
                          child: GestureDetector(
                            onTap: () {
                              var alert = AlertDialog(
                                backgroundColor: HexColor("#282828"),
                                title: Text(
                                  "Simple photogrammetry gui is based on:",
                                  style: TextStyle(color: HexColor("#ebdbb2")),
                                ),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    linkWidget("1. Colmap", "https://colmap.github.io/"),
                                    linkWidget("2. OpenMVS", "https://github.com/cdcseacave/openMVS"),
                                    linkWidget("3. mvs-texturing", "https://github.com/nmoehrle/mvs-texturing"),
                                    linkWidget("4. pymeshlab", "https://github.com/cnr-isti-vclab/PyMeshLab"),
                                    linkWidget("5. brush", "https://github.com/ArthurBrussee/brush"),
                                    linkWidget("6. PoissonRecon", "https://github.com/mkazhdan/PoissonRecon"),
                                  ],
                                ),
                              );
                              showDialog(context: context, builder: (_) => alert);
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.question_mark,color: HexColor("#ebdbb2"),),
                              ),
                            ),
                          ))
                ],)
              ],
            ),
            isDownloadingDependencies
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          color: HexColor("#458588"),
                        ),
                        Text(
                          "downloading dependencies...",
                          style: TextStyle(color: HexColor("#ebdbb2")),
                        )
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 75.0),
                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                child: AnimatedContainer(duration: const Duration(milliseconds: 80),child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text("Photogrammetry",style: TextStyle(color: HexColor("#282828")),),
                                ),decoration: BoxDecoration( color: !photogrammetry_or_splat ? HexColor("#458588") : HexColor("#928374"),borderRadius: BorderRadius.only(topLeft: Radius.circular(10), bottomLeft: Radius.circular(10))),),
                                onTap: () {
                                  photogrammetry_or_splat = false;
                                  setState(() {});
                                },
                              ),
                              GestureDetector(
                                child: AnimatedContainer(duration: const Duration(milliseconds: 80),child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Text("Gaussian Splatting",style: TextStyle(color: HexColor("#282828")),),
                                ),decoration: BoxDecoration(color: photogrammetry_or_splat ? HexColor("#458588") : HexColor("#928374"),borderRadius: BorderRadius.only(topRight: Radius.circular(10), bottomRight: Radius.circular(10))),),
                                onTap: () {
                                  if(is_non_cuda_version) {
                                    var alert = AlertDialog(
                                      backgroundColor: HexColor("#282828"),
                                      title: Text(
                                        "Gaussian Splatting is unavailable in the Non-Cuda Version",
                                        style: TextStyle(color: HexColor("#ebdbb2")),
                                      ),
                                      // content: Column(
                                      //   mainAxisSize: MainAxisSize.min,
                                      //   children: [
                                      //     linkWidget("1. Colmap", "https://colmap.github.io/"),
                                      //     linkWidget("2. OpenMVS", "https://github.com/cdcseacave/openMVS"),
                                      //     linkWidget("3. mvs-texturing", "https://github.com/nmoehrle/mvs-texturing"),
                                      //     linkWidget("4. pymeshlab", "https://github.com/cnr-isti-vclab/PyMeshLab"),
                                      //     linkWidget("5. brush", "https://github.com/ArthurBrussee/brush"),
                                      //     linkWidget("6. PoissonRecon", "https://github.com/mkazhdan/PoissonRecon"),
                                      //   ],
                                      // ),
                                    );
                                    showDialog(context: context, builder: (_) => alert);
                                  }else{
                                    photogrammetry_or_splat = true;
                                    setState(() {});
                                  }
                                },
                              ),
                            ],
                          ),
                          /*const Padding(padding: EdgeInsets.all(8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              RoundCheckBox(
                                size: 30,
                                isChecked: reconstructAndTextureMesh,
                                checkedColor: HexColor("#458588"),
                                disabledColor: colorScheme.background,
                                uncheckedColor: colorScheme.background,
                                checkedWidget: Icon(
                                  Icons.check,
                                  color: HexColor("#282828"),
                                ),
                                onTap: (selected) {
                                  reconstructAndTextureMesh = (selected ?? false);
                                  setState(() {});
                                },
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(
                                'Reconstruct & Texture Mesh (High memory usage)',
                                style: TextStyle(color: HexColor("#ebdbb2"), fontWeight: FontWeight.normal),
                              )
                            ],
                          ),*/
                          const Padding(padding: EdgeInsets.all(10.0)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                imageFolder == "" ? "No image folder selected" : imageFolder,
                                style: TextStyle(color: HexColor("#ebdbb2"), fontWeight: FontWeight.w200),
                              ),
                              const Padding(padding: EdgeInsets.all(10.0)),
                              TextButton(
                                onPressed: () async {
                        
                                  
                        
                        
                                  if(Platform.isWindows || await checkZenity()) {
                        
                                    final String? directoryPath = await getDirectoryPath();
                                    if (directoryPath == null) {
                                      // Operation was canceled by the user.
                                      // return;
                                    }else{
                                      imageFolder = directoryPath;
                                    }
                        
                                  }else{
                                    widget.model.showAlert(colorScheme, context, "Missing Dependency", [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Ok",
                                            style: TextStyle(color: HexColor("#ebdbb2")),
                                          ))
                                    ],desc: "Please install zenity\n\nDebian / Ubuntu: sudo apt-get install zenity\n\nArch: sudo pacman -S zenity", height: 150.0);
                        
                                  }
                                  // String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                        
                                  // if (selectedDirectory == null) {
                                  //   // User canceled the picker
                                  // } else {
                                  //   imageFolder = selectedDirectory;
                                  // }
                                  setState(() {});
                                },
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return HexColor("#83a598");
                                  }
                                  return HexColor("#458588");
                                })),
                                child: Text(
                                  '${imageFolder == "" ? "Select" : "Change"} Image Folder',
                                  style: TextStyle(color: HexColor("#282828")),
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
                                style: TextStyle(color: HexColor("#ebdbb2"), fontWeight: FontWeight.w200),
                              ),
                              const Padding(padding: EdgeInsets.all(10.0)),
                              TextButton(
                                onPressed: () async {
                        
                                  if(Platform.isWindows || await checkZenity()) {
                        
                                    final String? directoryPath = await getDirectoryPath();
                                    if (directoryPath == null) {
                                      // Operation was canceled by the user.
                                      // return;
                                    } else {
                                      outputFolder = directoryPath;
                                    }
                        
                                  }else{
                                    widget.model.showAlert(colorScheme, context, "Missing Dependency", [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            "Ok",
                                            style: TextStyle(color: HexColor("#ebdbb2")),
                                          ))
                                    ],desc: "Please install zenity\n\nDebian / Ubuntu: sudo apt-get install zenity\n\nArch: sudo pacman -S zenity",height: 150.0);
                                  }
                        
                                  // String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
                                        
                                  // if (selectedDirectory == null) {
                                  //   // User canceled the picker
                                  // } else {
                                  //   outputFolder = selectedDirectory;
                                  // }
                                  setState(() {});
                                },
                                style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                  if (states.contains(MaterialState.pressed)) {
                                    return HexColor("#83a598");
                                  }
                                  return HexColor("#458588");
                                })),
                                child: Text(
                                  '${outputFolder == "" ? "Select" : "Change"} Output Folder',
                                  style: TextStyle(color: HexColor("#282828")),
                                ),
                              ),
                            ],
                          ),
                          const Padding(padding: EdgeInsets.all(8)),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              !photogrammetry_or_splat ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  running ? Container() : startButtonWidget("Start - High Quality",HexColor("#d79921"),HexColor("#fabd2f"),0),
                                  const Padding(padding: EdgeInsets.all(8)),
                                  running ? Container() : startButtonWidget("Start - Medium Quality",HexColor("#458588"),HexColor("#83a598"),1),
                                  const Padding(padding: EdgeInsets.all(8)),
                                  running ? Container() : startButtonWidget("Start - Low Quality",HexColor("#98971a"),HexColor("#b8bb26"),2),
                                ]
                              ) : running ? Container() : startButtonWidget("Start",HexColor("#458588"),HexColor("#83a598"),1),
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
                            style: TextStyle(fontSize: 21, color: HexColor("#ebdbb2")),
                          ),
                          const Padding(padding: EdgeInsets.all(10)),
                          running
                              ? Center(
                                  child: SizedBox(
                                      width: 150,
                                      child: LinearProgressIndicator(
                                        backgroundColor: HexColor("#458588"),
                                        color: HexColor("#282828"),
                                      )),
                                )
                              : Container()
                        ]),
                      ),
                      
                    ],
                  ),
            is_non_cuda_version ? Container(height: 70,) : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              RoundCheckBox(
                                size: 30,
                                isChecked: useGpu,
                                checkedColor: HexColor("#458588"),
                                disabledColor: HexColor("#282828"),
                                uncheckedColor: HexColor("#282828"),
                                checkedWidget: Icon(
                                  Icons.check,
                                  color: HexColor("#282828"),
                                ),
                                onTap: (selected) {
                                  useGpu = selected ?? true;
                                  setState(() {});
                                },
                              ),
                              const Padding(padding: EdgeInsets.all(5)),
                              Text(
                                'Use GPU when possible',
                                style: TextStyle(color: HexColor("#ebdbb2"), fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
            ),
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
        style: TextStyle(color: HexColor("#ebdbb2"), decoration: TextDecoration.underline),
      ),
    );
  }

  settingWidget(String hint, String startingText, Function(String value) onChange) {
    TextEditingController controller = TextEditingController();
    controller.text = startingText;
    return TextField(decoration: InputDecoration(label: Text(hint,style: TextStyle(color: HexColor("#ebdbb2"),)),
    // 2. The border when the user clicks/focuses on the dropdown
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: HexColor("#ebdbb2"), // The color when active
                width: 2.0,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: HexColor("#ebdbb2"), // The color when active
                width: 2.0,
              ),
            ),),controller: controller,onChanged: (value) {
      if(value == "") {
      }else{
        onChange(value);
      }
    },style: TextStyle(color: HexColor("#ebdbb2")));
    //  GestureDetector(
    //   onTap: () async {
    //     if (!await launchUrl(Uri.parse(url))) {
    //       throw Exception('Could not launch $url');
    //     }
    //   },
    //   child: Text(
    //     text,
    //     style: TextStyle(color: HexColor("#ebdbb2"), decoration: TextDecoration.underline),
    //   ),
    // );
  }

  settingWidgetDropdown(String hint, String startingText, Function(String value) onChange, List<DropdownMenuEntry<String>> items) {
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        DropdownMenu<String>(
          initialSelection: startingText,
          label: Text('Feature Matching Type', style: TextStyle(color: HexColor("#ebdbb2")),),
          onSelected: (String? newValue) {
            onChange(newValue??"exhaustive_matcher");
          },
          dropdownMenuEntries: items,
          textStyle: TextStyle(color: HexColor("#ebdbb2")),
          menuStyle: const MenuStyle(backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(40, 40, 40, 1))),
          inputDecorationTheme: InputDecorationTheme(
        
        
            // 2. The border when the user clicks/focuses on the dropdown
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: HexColor("#ebdbb2"), // The color when active
                width: 2.0,
              ),
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: HexColor("#ebdbb2"), // The color when active
                width: 2.0,
              ),
            ),
          )
          
        ),
      ],
    );
  }

  startButtonWidget(String text, Color buttonColor, Color buttonColorPress, int qualityLevel) {
    return TextButton(
                              onPressed: () async {
                                if (imageFolder == "") {
                                  widget.model.showAlert(colorScheme, context, "You have to select an image folder", [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text(
                                          "Ok",
                                          style: TextStyle(color: HexColor("#ebdbb2")),
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
                                          style: TextStyle(color: HexColor("#ebdbb2")),
                                        ))
                                  ]);
                                } else {
                                  stop = false;
                                  widget.model.startScanningProcess(this, imageFolder, outputFolder,qualityLevel, photogrammetry_or_splat);
                                }
                              },
                              //  : () {
                              //   widget.model.startScanningProcess(this, imageFolder, outputFolder);
                              // },
                              style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                                if (states.contains(MaterialState.pressed)) {
                                  return buttonColorPress;
                                }
                                return buttonColor;
                              })),
                              child: Text(
                                // hasAllDependencies ? 
                                text,
                                //  : "Install Dependencies (Needs Adminstrator rights)",
                                style: TextStyle(color: HexColor("#282828")),
                              ),
                            );
  }

  checkZenity() async {
    bool hasZenity = true;

    try{
      hasZenity = (await runCommand("zenity", ["--help"],checkOnlyError: true)) == "";
    }catch(e) {
      hasZenity = false;
    }

    return hasZenity;
  }
}
