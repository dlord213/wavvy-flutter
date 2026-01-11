import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wavvy/constants/app_settings.dart';
import 'package:wavvy/db/db.dart';

class SetupController extends GetxController {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final DbHelper _dbHelper = DbHelper();

  final RxBool isDarkMode = false.obs;

  @override
  void onReady() {
    super.onReady();
    _startAppSequence();
  }

  // --- MAIN SEQUENCE ---
  Future<void> _startAppSequence() async {
    await _loadTheme();

    bool hasPermissions = await _checkAndRequestPermissions();
    if (!hasPermissions) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      await _dbHelper.db;
    } catch (e) {
      print("Database Init Error: $e");
    }

    Get.offAllNamed('/home');
  }

  // --- PERMISSIONS ---
  Future<bool> _checkAndRequestPermissions() async {
    if (!Platform.isAndroid) return true;
    final androidInfo = await DeviceInfoPlugin().androidInfo;

    // 1. Android 13+ (SDK 33+): Must ask for specific Media permissions
    if (androidInfo.version.sdkInt >= 33) {
      // Notifications
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      // Audio (CRITICAL for on_audio_query)
      var audioStatus = await Permission.audio.status;
      if (!audioStatus.isGranted) {
        audioStatus = await Permission.audio.request();
      }

      // We return the status of AUDIO, not manage_external_storage
      return audioStatus.isGranted;
    }

    // 2. Android 11 & 12 (SDK 30-32): specific logic
    if (androidInfo.version.sdkInt >= 30) {
      // Manage External Storage (For Tag Editing)
      var manageStatus = await Permission.manageExternalStorage.status;
      if (!manageStatus.isGranted) {
        await Permission.manageExternalStorage.request();
      }

      // Read Storage (For Reading Files)
      // Some devices still need this alongside Manage External Storage
      var storageStatus = await Permission.storage.status;
      if (!storageStatus.isGranted) {
        storageStatus = await Permission.storage.request();
      }

      return storageStatus.isGranted ||
          await Permission.manageExternalStorage.isGranted;
    }

    // 3. Android 10 and below
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  void _showPermissionDeniedDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Permissions Required"),
        content: const Text(
          "Wavvy needs storage access to play your music.\n\nPlease grant permissions in Settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("Open Settings"),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // --- THEME LOGIC ---
  Future<void> _loadTheme() async {
    final bool storedThemeState =
        await _prefs.getBool(APP_SETTINGS.DARK_MODE_TURNED_ON.keyValue) ??
        false;

    isDarkMode.value = storedThemeState;
    Get.changeThemeMode(storedThemeState ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleDarkMode() async {
    isDarkMode.value = !isDarkMode.value;
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);

    await _prefs.setBool(
      APP_SETTINGS.DARK_MODE_TURNED_ON.keyValue,
      isDarkMode.value,
    );
  }
}
