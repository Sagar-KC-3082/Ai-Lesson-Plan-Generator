import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';

class StoragePermissionHandler {
  static Future<bool> requestStoragePermission() async {
    try {
      // Try multiple permission types for better compatibility
      
      // First try: Photos permission (Android 13+)
      if (await Permission.photos.isGranted) {
        print('Photos permission already granted');
        return true;
      }
      
      // Second try: Storage permission (Android 12 and below)
      if (await Permission.storage.isGranted) {
        print('Storage permission already granted');
        return true;
      }
      
      // Request photos permission first (modern approach)
      var status = await Permission.photos.request();
      if (status.isGranted) {
        print('Photos permission granted');
        return true;
      }
      
      // If photos permission denied, try storage permission
      if (status.isDenied || status.isPermanentlyDenied) {
        print('Photos permission denied, trying storage permission');
        status = await Permission.storage.request();
        if (status.isGranted) {
          print('Storage permission granted');
          return true;
        }
      }
      
      print('Permission request result: $status');
      return status.isGranted;
    } catch (e) {
      print('Error requesting storage permission: $e');
      return false;
    }
  }

  static Future<bool> hasStoragePermission() async {
    try {
      // Check if any storage-related permission is granted
      final photosGranted = await Permission.photos.isGranted;
      final storageGranted = await Permission.storage.isGranted;
      
      print('Photos permission: $photosGranted, Storage permission: $storageGranted');
      
      return photosGranted || storageGranted;
    } catch (e) {
      print('Error checking storage permission: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
  
  static Future<bool> hasExternalStorage() async {
    try {
      // Check if external storage is available
      final externalDir = await ExternalPath.getExternalStoragePublicDirectory(
        ExternalPath.DIRECTORY_DOWNLOADS,
      );
      return externalDir != null && externalDir.isNotEmpty;
    } catch (e) {
      print('External storage check failed: $e');
      return false;
    }
  }
}
