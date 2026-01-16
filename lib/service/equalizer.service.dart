import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class EqualizerService extends GetxService {
  final AndroidEqualizer _androidEqualizer = AndroidEqualizer();

  // --- OBSERVABLES ---
  final RxBool isEnabled = false.obs;

  // Store the band objects
  final RxList<AndroidEqualizerBand> bands = <AndroidEqualizerBand>[].obs;

  final RxDouble minDecibels = (-15.0).obs;
  final RxDouble maxDecibels = (15.0).obs;

  AndroidEqualizer get equalizerInstance => _androidEqualizer;

  final RxString currentPreset = 'Custom'.obs;
  final Map<String, List<double>> presets = {
    'Flat': [0, 0, 0, 0, 0],
    'Bass Boost': [0.03, 0.04, 0, 0, 0],
    'Rock': [5, 3, -1, 3, 5],
    'Pop': [-1, 2, 4, 2, -1],
    'Jazz': [3, 2, -1, 2, 3],
    'Voice': [-2, -1, 3, 3, 1],
    'Treble': [0, 0, 0, 4, 6],
  };

  @override
  void onInit() {
    super.onInit();
    _initEqualizer();
  }

  /// Initialize: Await the Future parameters and read current state
  Future<void> _initEqualizer() async {
    try {
      final params = await _androidEqualizer.parameters;

      print(params);

      // Update bands list
      bands.assignAll(params.bands);

      // Update limits (convert Millibels to Decibels)
      if (params.minDecibels != null) {
        minDecibels.value = params.minDecibels! / 100.0;
      }
      if (params.maxDecibels != null) {
        maxDecibels.value = params.maxDecibels! / 100.0;
      }

      isEnabled.value = _androidEqualizer.enabled;
    } catch (e) {
      print("Equalizer Init Error: $e");
    }
  }

  /// Toggle the EQ on/off
  Future<void> toggleEnabled(bool value) async {
    try {
      await _androidEqualizer.setEnabled(value);
      isEnabled.value = value; // Update local state
    } catch (e) {
      print("Error toggling Equalizer: $e");
    }
  }

  /// Set the gain for a specific band
  Future<void> setBandGain(int bandIndex, double gainDb) async {
    try {
      if (bandIndex < 0 || bandIndex >= bands.length) return;

      final band = bands[bandIndex];

      // Convert dB to mB (1 dB = 100 mB)
      final double gainMb = gainDb * 100.0;

      await band.setGain(gainMb);
    } catch (e) {
      print("Error setting band gain: $e");
    }
  }

  Future<void> resetToFlat() async {
    for (int i = 0; i < bands.length; i++) {
      await setBandGain(i, 0.0);
    }
  }

  Future<void> applyPreset(String presetName) async {
    if (!presets.containsKey(presetName)) return;

    final values = presets[presetName]!;

    // Safety check: Loop through available bands
    final count = values.length < bands.length ? values.length : bands.length;

    for (int i = 0; i < count; i++) {
      final band = bands[i];
      final double targetDb = values[i];

      // FIX: Clamp the value between the device's actual physical limits
      // This prevents the "Too High" error where value > max
      final double clampedDb = targetDb.clamp(
        minDecibels.value,
        maxDecibels.value,
      );

      // Convert to millibels for the Android API
      await band.setGain(clampedDb * 100.0);
    }

    currentPreset.value = presetName;
  }
}
