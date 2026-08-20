import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

class TitleBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      color: Colors.grey[900],
      child: Row(
        children: [
          
          Expanded(child: DragToMoveArea(child: Container(padding: EdgeInsets.only(left: 10), alignment: Alignment.centerLeft, child: Text("Simple Photogrammetry Gui", style: TextStyle(color: Colors.white))))),
          
          
          IconButton(
            icon: const Icon(Icons.minimize, color: Colors.white),
            onPressed: () async {
              await windowManager.minimize();
            },
          ),
          
          
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              await windowManager.close();
            },
          ),
        ],
      ),
    );
  }
}