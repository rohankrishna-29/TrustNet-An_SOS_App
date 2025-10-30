import 'package:permission_handler/permission_handler.dart';
import 'package:open_file_manager/open_file_manager.dart';
import 'package:flutter/foundation.dart';

class FileUtils {
  static Future<void> openRecordingsFolder() async {
    if (await Permission.manageExternalStorage.isGranted ||
        await Permission.storage.isGranted) {
      await _openFolder();
    } else {
      if (await Permission.manageExternalStorage.request().isGranted ||
          await Permission.storage.request().isGranted) {
        await _openFolder();
      } else {
        debugPrint("Storage permission denied");
      }
    }
  }

  static Future<void> _openFolder() async {
    try {
      await openFileManager(
        androidConfig: AndroidConfig(
          folderType: AndroidFolderType.other,
          folderPath: 'Music/TrustNet',
        ),
      );
    } catch (e) {
      debugPrint("Error opening folder: $e");
    }
  }
}
