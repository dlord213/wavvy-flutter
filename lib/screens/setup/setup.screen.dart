import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/setup/setup.controller.dart';

class InitializationScreen extends GetView<SetupController> {
  const InitializationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: 12,
            children: [
              Icon(Icons.storage_rounded, size: 80),
              Column(
                spacing: 4,
                children: [
                  Text(
                    "Grant access to storage",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  Text("This is required to access your media/audio files."),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: FilledButton.tonal(
                        onPressed: () {
                          controller.requestStoragePermission();
                        },
                        child: Text("Grant"),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
