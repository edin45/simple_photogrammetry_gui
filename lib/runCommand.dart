import 'dart:io';

runCommand(String command, List<String> attr) async {
  return await Process.run(command, attr).then((ProcessResult results) {
    String err = results.stderr.toString();
    print('err: $err');
    if (err.contains('Permission denied') || err.contains("PermissionDenied")) {
      err = "permission_denied";
    }
    print('command_out: ${results.stdout}');
    return err == "" ? results.stdout : err;
  });
}
