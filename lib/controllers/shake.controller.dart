import 'dart:async';
import 'dart:math';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/service/settings.service.dart';

class ShakeController extends GetxController {
  final AudioController _audioController = Get.find<AudioController>();
  final SettingsService _settings = Get.find();

  final double _shakeThreshold =
      25.0; // Sensitivity (Lower = easier to trigger)
  final int _debounceTimeMs = 2000;

  StreamSubscription? _accelerometerSubscription;
  int _lastShakeTime = 0;

  @override
  void onInit() {
    super.onInit();
    if (_settings.enableShakeToSkip.value) _startListening();
  }

  @override
  void onClose() {
    _accelerometerSubscription?.cancel();
    super.onClose();
  }

  void _startListening() {
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      double acceleration = sqrt(
        pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2),
      );

      if (acceleration > _shakeThreshold) {
        _handleShake();
      }
    });
  }

  void _handleShake() {
    final now = DateTime.now().millisecondsSinceEpoch;

    // Check Debounce (Prevent double-skipping)
    if (now - _lastShakeTime > _debounceTimeMs) {
      _lastShakeTime = now;


      if (_audioController.audioPlayer.hasNext) {
        _audioController.next();
      }
    }
  }
}
