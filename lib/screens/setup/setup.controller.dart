import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wavvy/constants/app_settings.dart';
import 'package:wavvy/screens/audio.controller.dart';

class SetupController extends GetxController {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();
  final RxBool isDarkMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      await _loadTheme();

      final bool shouldSetup =
          await _prefs.getBool(APP_SETTINGS.SHOULD_SETUP.keyValue) ?? true;

      if (shouldSetup) {
        await requestStoragePermission();
      } else {
        if (await _hasPermission()) {
          _forceAudioRefresh();
        } else {
          await requestStoragePermission();
        }
      }
    } catch (e) {
      print("Error during initialization: $e");
    }
  }

  Future<bool> _hasPermission() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      return await Permission.audio.isGranted;
    }
    return await Permission.storage.isGranted;
  }

  Future<void> requestStoragePermission() async {
    PermissionStatus status;

    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        status = await Permission.audio.request();
      } else {
        status = await Permission.storage.request();
      }
    } else {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      print("Permission Granted!");
      await _finalizeSetup();
    } else if (status.isPermanentlyDenied) {
      openAppSettings();
    } else {
      print("Permission Denied");
    }
  }

  Future<void> _finalizeSetup() async {
    await _prefs.setBool(APP_SETTINGS.STORAGE_ACCESS_GRANTED.keyValue, true);
    await _prefs.setBool(APP_SETTINGS.SHOULD_SETUP.keyValue, false);

    await _forceAudioRefresh();

    // Get.offAllNamed("/home");
  }

  Future<void> _forceAudioRefresh() async {
    if (Get.isRegistered<AudioController>()) {
      final audioController = Get.find<AudioController>();
      print("Setup complete. Forzing AudioController to fetch songs...");
      await audioController.fetchAllSongs();
    }
  }

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
