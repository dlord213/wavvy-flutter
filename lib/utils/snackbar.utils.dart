import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppSnackbar {
  static void showSnackbar(String title, String subtitle) {
    if (Get.context == null) return;

    Get.snackbar(
      title,
      subtitle,
      snackPosition: SnackPosition.TOP,
      barBlur: 0,
      backgroundColor: Get.context?.theme.colorScheme.surfaceContainer,
      colorText: Get.context?.theme.colorScheme.onSurface,
      isDismissible: true,
      dismissDirection: DismissDirection.down,
      animationDuration: const Duration(milliseconds: 250),
    );
  }

  static void showErrorSnackBar(String title, String subtitle) {
    if (Get.context == null) return;

    Get.snackbar(
      title,
      subtitle,
      snackPosition: SnackPosition.TOP,
      barBlur: 0,
      backgroundColor: Get.context?.theme.colorScheme.errorContainer,
      colorText: Get.context?.theme.colorScheme.onErrorContainer,
      isDismissible: true,
      dismissDirection: DismissDirection.down,
      animationDuration: const Duration(milliseconds: 250),
    );
  }
}
