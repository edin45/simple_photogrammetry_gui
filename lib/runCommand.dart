import 'dart:io';
import 'package:process_run/process_run.dart';

runCommand(String command, List<String> attr, {String? workingFolder}) async {
  
  return Platform.isWindows ? await (workingFolder == null ? Process.run(command, attr) : Process.run(command, attr,workingDirectory: workingFolder)).then((ProcessResult results) {
    String err = results.stderr.toString();
    print('err: $err');
    if (err.contains('Permission denied') || err.contains("PermissionDenied")) {
      err = "permission_denied";
    }
    print('command_out: ${results.stdout}');
    return err == "" ? results.stdout : err;
  }) : (workingFolder == null ? await Shell().run(command) : await Shell(workingDirectory: workingFolder).run(command));
}
