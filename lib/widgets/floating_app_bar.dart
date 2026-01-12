import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FloatingAppBar extends StatelessWidget {
  final String title;
  final bool showSearch;
  final bool showThemeToggle;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onSearchTap;

  const FloatingAppBar({
    super.key,
    this.title = "Wavvy",
    this.showSearch = true,
    this.showThemeToggle = false,
    this.leading,
    this.actions,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(
          bottom: BorderSide(width: 1, color: context.theme.dividerColor),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // --- LEFT SIDE (Leading + Title) ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: textColor,
                  ),
                ),
              ],
            ),

            // --- RIGHT SIDE (Actions) ---
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (actions != null) ...actions!,

                if (showSearch) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: onSearchTap ?? () => Get.toNamed("/search"),
                    icon: Icon(Icons.search, size: 26, color: textColor),
                    tooltip: "Search",
                  ),
                ],

                if (showThemeToggle) ...[
                  const SizedBox(width: 4),
                  IconButton(
                    onPressed: () {
                      if (Get.isDarkMode) {
                        Get.changeThemeMode(ThemeMode.light);
                      } else {
                        Get.changeThemeMode(ThemeMode.dark);
                      }
                    },
                    icon: Icon(
                      context.isDarkMode
                          ? Icons.light_mode_rounded
                          : Icons.dark_mode_rounded,
                      size: 26,
                      color: textColor,
                    ),
                    tooltip: "Toggle Theme",
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
