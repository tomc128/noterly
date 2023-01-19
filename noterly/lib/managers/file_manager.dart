import 'dart:convert';
import 'dart:io';

import 'package:noterly/models/app_data.dart';
import 'package:path_provider/path_provider.dart';

class FileManager {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/data.json');
  }

  static Future save(AppData data) async {
    final file = await _localFile;

    file.writeAsString(jsonEncode(data.toJson()));
  }

  static Future<AppData?> load() async {
    try {
      final file = await _localFile;

      final contents = await file.readAsString();

      return AppData.fromJson(jsonDecode(contents));
    } catch (e) {
      print('No previous save found. Error $e');
      return null;
    }
  }
}
