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
    final textColor = context.theme.textTheme.bodyLarge?.color;
    final bgColor = context.isDarkMode ? Colors.grey[900] : Colors.white;

    return SafeArea(
      bottom: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
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
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
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
                    icon: Icon(Icons.search_rounded, size: 24, color: textColor),
                    tooltip: "Search",
                    style: IconButton.styleFrom(
                      backgroundColor: context.theme.scaffoldBackgroundColor,
                    ),
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
                      size: 24,
                      color: textColor,
                    ),
                    tooltip: "Toggle Theme",
                    style: IconButton.styleFrom(
                      backgroundColor: context.theme.scaffoldBackgroundColor,
                    ),
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
