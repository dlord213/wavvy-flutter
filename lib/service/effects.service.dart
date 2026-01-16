import 'package:flutter/services.dart';
import 'package:get/get.dart';

class NativeEffectsService extends GetxService {
  static const _channel = MethodChannel('com.mirimomekiku.wavvy/audio_effects');

  // --- OBSERVABLES ---
  final RxBool isBassBoostEnabled = false.obs;
  final RxDouble bassBoostStrength = 0.0.obs; // 0 to 1000

  final RxBool isVirtualizerEnabled = false.obs;
  final RxDouble virtualizerStrength = 0.0.obs; // 0 to 1000

  final RxString currentReverbPreset = "None".obs;

  Future<void> initEffects(int sessionId) async {
    try {
      await _channel.invokeMethod('initEffects', {'sessionId': sessionId});
    } catch (e) {
      print("Failed to init native effects: $e");
    }
  }

  Future<void> setBassBoost(double strength) async {
    // Strength: 0.0 to 1.0 (mapped to 0-1000 natively)
    try {
      final int val = (strength * 1000).toInt();
      await _channel.invokeMethod('setBassBoost', {'strength': val});

      isBassBoostEnabled.value = val > 0;
      bassBoostStrength.value = val.toDouble();
    } catch (e) {
      print("Bass Boost Error: $e");
    }
  }

  Future<void> setVirtualizer(double strength) async {
    try {
      final int val = (strength * 1000).toInt();
      await _channel.invokeMethod('setVirtualizer', {'strength': val});

      isVirtualizerEnabled.value = val > 0;
      virtualizerStrength.value = val.toDouble();
    } catch (e) {
      print("Virtualizer Error: $e");
    }
  }

  Future<void> setReverb(String preset) async {
    // Presets: None, SmallRoom, MediumRoom, LargeRoom, MediumHall, LargeHall, Plate
    try {
      await _channel.invokeMethod('setReverb', {'preset': preset});
      currentReverbPreset.value = preset;
    } catch (e) {
      print("Reverb Error: $e");
    }
  }

  // Cleanup when app closes (optional, usually OS handles it)
  Future<void> release() async {
    await _channel.invokeMethod('releaseEffects');
  }
}
