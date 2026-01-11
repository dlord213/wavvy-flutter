import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/setup/setup.controller.dart'; // Adjust import path

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(SetupController());

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Icon(
              Icons.music_note,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 30),

            const SizedBox(
              width: 30,
              height: 30,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 20),

            Text(
              "Loading Library...",
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
