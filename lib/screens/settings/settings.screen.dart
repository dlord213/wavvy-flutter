import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:get/get.dart';
import 'package:wavvy/service/settings.service.dart';
import 'package:wavvy/widgets/floating_app_bar.dart';
import 'package:wavvy/widgets/theme_selector.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the service we created earlier
    final SettingsService controller = Get.find<SettingsService>();
    final theme = context.theme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: theme.scaffoldBackgroundColor,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: context.isDarkMode
            ? Brightness.light
            : Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: AppBarConnection(
            appBars: [
              AppBar(
                behavior: const MaterialAppBarBehavior(floating: true),
                body: FloatingAppBar(
                  title: "Settings",
                  showSearch: false,
                  leading: IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
              ),
            ],
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const SizedBox(height: 8),
                const ThemeSelector(),

                const SizedBox(height: 8),

                // --- PLAYER FEATURES ---
                _buildSectionHeader(context, "Player Features"),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      title: "Double Tap to Seek",
                      subtitle: "Double tap artwork to skip 10s",
                      icon: Icons.touch_app_rounded,
                      color: Colors.blueAccent,
                      value: controller.enableDoubleTapSeek,
                      onChanged: controller.toggleDoubleTapSeek,
                    ),
                    _buildDivider(context),
                    _buildSwitchTile(
                      title: "Shake to Skip",
                      subtitle: "Shake your device to skip track",
                      icon: Icons.vibration_rounded,
                      color: Colors.orangeAccent,
                      value: controller.enableShakeToSkip,
                      onChanged: controller.toggleShakeToSkip,
                    ),
                    _buildDivider(context),
                    // _buildSwitchTile(
                    //   title: "Fade In/Out",
                    //   subtitle: "Smooth transition between tracks",
                    //   icon: Icons.blur_linear_rounded,
                    //   color: Colors.teal,
                    //   value: controller.enableFadeInOut,
                    //   onChanged: controller.toggleFadeInOut,
                    // ),
                    _buildDivider(context),
                    _buildSwitchTile(
                      title: "Dynamic Colors",
                      subtitle: "Theme player based on album art",
                      icon: Icons.palette_rounded,
                      color: Colors.purpleAccent,
                      value: controller.enableDynamicColors,
                      onChanged: controller.toggleDynamicColors,
                    ),
                    _buildDivider(context),
                    _buildSwitchTile(
                      title: "Dark mode",
                      subtitle: "Switch to dark mode",
                      icon: Icons.palette_rounded,
                      color: Colors.purpleAccent,
                      value: controller.isDarkMode,
                      onChanged: controller.toggleDarkMode,
                    ),
                  ],
                ),

                // --- CONTENT & LIBRARY ---
                _buildSectionHeader(context, "Content & Library"),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      title: "Fetch Lyrics",
                      subtitle: "Automatically find song lyrics",
                      icon: Icons.lyrics_rounded,
                      color: Colors.pinkAccent,
                      value: controller.enableLyricsFetching,
                      onChanged: controller.toggleLyricsFetching,
                    ),
                    _buildDivider(context),
                    _buildSwitchTile(
                      title: "Artist Info",
                      subtitle: "Load bios and artist images",
                      icon: Icons.person_search_rounded,
                      color: Colors.indigoAccent,
                      value: controller.enableArtistInfoFetching,
                      onChanged: controller.toggleArtistInfoFetching,
                    ),
                    _buildDivider(context),
                    _buildSwitchTile(
                      title: "Show Stats",
                      subtitle: "Most played & recently played",
                      icon: Icons.bar_chart_rounded,
                      color: Colors.green,
                      value: controller.showStats,
                      onChanged: controller.toggleShowStats,
                    ),
                  ],
                ),

                // --- PRIVACY ---
                _buildSectionHeader(context, "Privacy"),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      title: "Incognito Mode",
                      subtitle: "Don't record listening history",
                      icon: Icons.visibility_off_rounded,
                      color: Colors.grey,
                      value: controller.isIncognitoMode,
                      onChanged: controller.toggleIncognito,
                    ),
                  ],
                ),

                // --- SYSTEM ---
                _buildSectionHeader(context, "System"),
                _buildSettingsCard(
                  context,
                  children: [
                    _buildSwitchTile(
                      title: "Enable Downloader",
                      subtitle: "Allow downloading external content",
                      icon: Icons.download_rounded,
                      color: Colors.redAccent,
                      value: controller.enableDownloader,
                      onChanged: controller.toggleDownloader,
                    ),
                    _buildDivider(context),
                    // _buildSwitchTile(
                    //   title: "Keep Screen On",
                    //   subtitle: "Prevent sleep while viewing lyrics",
                    //   icon: Icons.wb_sunny_rounded,
                    //   color: Colors.amber,
                    //   value: controller.enableWakeLock,
                    //   onChanged: controller.toggleWakeLock,
                    // ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGETS ---

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.theme.primaryColor,
          fontWeight: FontWeight.bold,
          fontSize: 14,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.isDarkMode ? Colors.grey[900] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required RxBool value,
    required Function(bool) onChanged,
  }) {
    return Obx(
      () => SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        activeThumbColor: Get.theme.primaryColor,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Get.theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
          ),
        ),
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        value: value.value,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 60,
      endIndent: 0,
      color: context.theme.dividerColor.withValues(alpha: 0.5),
    );
  }
}
