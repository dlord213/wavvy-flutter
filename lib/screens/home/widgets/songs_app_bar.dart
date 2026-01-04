import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/audio.controller.dart';

class SongsAppBar extends GetView<AudioController> {
  const SongsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = context.isDarkMode ? Colors.white : Colors.black;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: BoxBorder.fromLTRB(
          bottom: BorderSide(width: 1, color: context.theme.dividerColor),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Text(
                    "Wavvy",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: textColor,
                    ),
                  ),
                ],
              ),

              Row(
                spacing: 4,
                children: [
                  IconButton(
                    onPressed: () {
                      Get.toNamed("/search");
                    },
                    icon: Icon(Icons.search, size: 26, color: textColor),
                  ),
                  context.isDarkMode
                      ? IconButton(
                          onPressed: () {
                            Get.changeThemeMode(ThemeMode.light);
                          },
                          icon: Icon(
                            Icons.light_mode_rounded,
                            size: 26,
                            color: textColor,
                          ),
                        )
                      : IconButton(
                          onPressed: () {
                            Get.changeThemeMode(ThemeMode.dark);
                          },
                          icon: Icon(
                            Icons.dark_mode_rounded,
                            size: 26,
                            color: textColor,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
