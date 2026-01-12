import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class SettingsService extends GetxService {
  final SharedPreferencesAsync _prefs = SharedPreferencesAsync();

  // --- KEYS ---
  static const String _kDoubleTapSeek = 'feature_double_tap_seek';
  static const String _kShakeToSkip = 'feature_shake_to_skip';
  static const String _kFadeInOut = 'feature_fade_in_out';
  static const String _kDynamicColors = 'feature_dynamic_colors';
  static const String _kFetchLyrics = 'feature_fetch_lyrics';
  static const String _kFetchArtistInfo = 'feature_fetch_artist_info';
  static const String _kShowStats = 'feature_show_stats';
  static const String _kEnableDownloader = 'feature_enable_downloader';
  static const String _kWakeLock = 'feature_wake_lock';
  static const String _kDarkMode = 'feature_dark_mode';
  static const String _kIncognito = 'feature_incognito';
  static const String _kThemeSchemeIndex = 'theme_scheme_index';

  // --- OBSERVABLES ---
  final RxBool enableDoubleTapSeek = true.obs;
  final RxBool enableShakeToSkip = false.obs;
  final RxBool enableFadeInOut = false.obs;
  final RxBool enableDynamicColors = true.obs;
  final RxBool enableLyricsFetching = true.obs;
  final RxBool enableArtistInfoFetching = true.obs;
  final RxBool showStats = true.obs;
  final RxBool enableDownloader = true.obs;
  final RxBool enableWakeLock = false.obs;
  final RxBool isDarkMode = false.obs;
  final RxBool isIncognitoMode = false.obs;
  final RxInt currentThemeIndex = 0.obs;

  // --- INITIALIZATION ---
  Future<SettingsService> init() async {
    await _loadSettings();
    return this;
  }

  Future<void> _loadSettings() async {
    enableDoubleTapSeek.value = await _prefs.getBool(_kDoubleTapSeek) ?? true;
    enableShakeToSkip.value = await _prefs.getBool(_kShakeToSkip) ?? false;
    enableFadeInOut.value = await _prefs.getBool(_kFadeInOut) ?? true;
    enableDynamicColors.value = await _prefs.getBool(_kDynamicColors) ?? true;
    enableLyricsFetching.value = await _prefs.getBool(_kFetchLyrics) ?? true;
    enableArtistInfoFetching.value =
        await _prefs.getBool(_kFetchArtistInfo) ?? true;
    showStats.value = await _prefs.getBool(_kShowStats) ?? true;
    enableDownloader.value = await _prefs.getBool(_kEnableDownloader) ?? true;
    enableWakeLock.value = await _prefs.getBool(_kWakeLock) ?? false;
    isIncognitoMode.value = await _prefs.getBool(_kIncognito) ?? false;
    currentThemeIndex.value = await _prefs.getInt(_kThemeSchemeIndex) ?? 0;

    bool? storedTheme = await _prefs.getBool(_kDarkMode);
    if (storedTheme == null) {
      // First run: Check system platform brightness
      isDarkMode.value = Get.isPlatformDarkMode;
    } else {
      isDarkMode.value = storedTheme;
    }

    // --- APPLY SIDE EFFECTS ---
    _applyWakeLock();
    _applyTheme();
  }

  // --- ACTIONS ---

  Future<void> toggleDoubleTapSeek(bool value) async {
    enableDoubleTapSeek.value = value;
    await _prefs.setBool(_kDoubleTapSeek, value);
  }

  Future<void> toggleShakeToSkip(bool value) async {
    enableShakeToSkip.value = value;
    await _prefs.setBool(_kShakeToSkip, value);
  }

  Future<void> toggleFadeInOut(bool value) async {
    enableFadeInOut.value = value;
    await _prefs.setBool(_kFadeInOut, value);
  }

  Future<void> toggleDynamicColors(bool value) async {
    enableDynamicColors.value = value;
    await _prefs.setBool(_kDynamicColors, value);
  }

  Future<void> toggleLyricsFetching(bool value) async {
    enableLyricsFetching.value = value;
    await _prefs.setBool(_kFetchLyrics, value);
  }

  Future<void> toggleArtistInfoFetching(bool value) async {
    enableArtistInfoFetching.value = value;
    await _prefs.setBool(_kFetchArtistInfo, value);
  }

  Future<void> toggleShowStats(bool value) async {
    showStats.value = value;
    await _prefs.setBool(_kShowStats, value);
  }

  Future<void> toggleDownloader(bool value) async {
    enableDownloader.value = value;
    await _prefs.setBool(_kEnableDownloader, value);
  }

  Future<void> toggleWakeLock(bool value) async {
    enableWakeLock.value = value;
    await _prefs.setBool(_kWakeLock, value);
    _applyWakeLock();
  }

  Future<void> toggleDarkMode(bool value) async {
    isDarkMode.value = value;
    await _prefs.setBool(_kDarkMode, value);
    Get.changeThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> toggleIncognito(bool value) async {
    isIncognitoMode.value = value;
    await _prefs.setBool(_kIncognito, value);
  }

  // --- HELPERS ---

  void _applyWakeLock() {
    WakelockPlus.toggle(enable: enableWakeLock.value);
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  ThemeData getLightTheme() => FlexThemeData.light(
    scheme: FlexScheme.values[currentThemeIndex.value],
    useMaterial3: true,
    useMaterial3ErrorColors: true,
    fontFamily: GoogleFonts.gabarito().fontFamily,
  );

  ThemeData getDarkTheme() => FlexThemeData.dark(
    scheme: FlexScheme.values[currentThemeIndex.value],
    useMaterial3: true,
    useMaterial3ErrorColors: true,
    fontFamily: GoogleFonts.gabarito().fontFamily,
  );

  Future<void> updateThemeIndex(int index) async {
    currentThemeIndex.value = index;
    await _prefs.setInt(_kThemeSchemeIndex, index);
    _applyTheme();
  }
}
