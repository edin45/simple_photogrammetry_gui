import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';
import 'dart:io';

int? getFreeMemoryWindowsMB() {
  final memoryStatus = calloc<MEMORYSTATUSEX>();
  memoryStatus.ref.dwLength = sizeOf<MEMORYSTATUSEX>();

  try {
    final result = GlobalMemoryStatusEx(memoryStatus);
    
    if (result != 0) {
      final freeBytes = memoryStatus.ref.ullAvailPhys;
      return freeBytes ~/ (1024 * 1024);
    }
  } finally {
    free(memoryStatus);
  }
  return null;
}


Future<int?> getFreeMemoryLinuxMB() async {
  if (!Platform.isLinux) return null;
  
  try {
    final file = File('/proc/meminfo');
    final lines = await file.readAsLines();
    
    for (final line in lines) {
      if (line.startsWith('MemAvailable:')) {
        
        final kbStr = line.replaceAll(RegExp(r'[^0-9]'), '');
        final kb = int.parse(kbStr);
        return kb ~/ 1024;
      }
    }
  } catch (e) {
    print('Failed to read /proc/meminfo: $e');
  }
  return null;
}

Future<int?> getFreeMemory() async {
  if(Platform.isWindows) {
    return getFreeMemoryWindowsMB();
  }else{
    return await getFreeMemoryLinuxMB();
  }
}