import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

enum StoragePermissionStatus { loading, granted, denied, permanentlyDenied }

class PermissionNotifier extends StateNotifier<StoragePermissionStatus> {
  PermissionNotifier() : super(StoragePermissionStatus.loading) {
    checkPermission();
  }

  Future<void> checkPermission() async {
    if (!Platform.isAndroid) {
      state = StoragePermissionStatus.granted;
      return;
    }

    const Permission permission = Permission.audio;
    final status = await permission.status;

    if (status.isGranted) {
      state = StoragePermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      state = StoragePermissionStatus.permanentlyDenied;
    } else {
      // Fallback check for older Android storage permission
      final storageStatus = await Permission.storage.status;
      if (storageStatus.isGranted) {
        state = StoragePermissionStatus.granted;
      } else if (storageStatus.isPermanentlyDenied) {
        state = StoragePermissionStatus.permanentlyDenied;
      } else {
        state = StoragePermissionStatus.denied;
      }
    }
  }

  Future<void> requestPermission() async {
    if (!Platform.isAndroid) {
      state = StoragePermissionStatus.granted;
      return;
    }

    const Permission permission = Permission.audio;
    final status = await permission.request();

    if (status.isGranted) {
      state = StoragePermissionStatus.granted;
    } else if (status.isPermanentlyDenied) {
      state = StoragePermissionStatus.permanentlyDenied;
    } else {
      final storageStatus = await Permission.storage.request();
      if (storageStatus.isGranted) {
        state = StoragePermissionStatus.granted;
      } else if (storageStatus.isPermanentlyDenied) {
        state = StoragePermissionStatus.permanentlyDenied;
      } else {
        state = StoragePermissionStatus.denied;
      }
    }
  }

  Future<void> openSettings() async {
    await openAppSettings();
  }
}

final permissionNotifierProvider =
    StateNotifierProvider<PermissionNotifier, StoragePermissionStatus>((ref) {
  return PermissionNotifier();
});
