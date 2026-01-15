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

  @override
  void onInit() {
    super.onInit();
    _initEqualizer();
  }

  /// Initialize: Await the Future parameters and read current state
  Future<void> _initEqualizer() async {
    try {
      // FIX 1: 'parameters' is a Future, so we await it
      final params = await _androidEqualizer.parameters;

      // Update bands list
      bands.assignAll(params.bands);

      // Update limits (convert Millibels to Decibels)
      if (params.minDecibels != null) {
        minDecibels.value = params.minDecibels! / 100.0;
      }
      if (params.maxDecibels != null) {
        maxDecibels.value = params.maxDecibels! / 100.0;
      }

      // FIX 2: 'enabled' is a bool, read it directly
      isEnabled.value = _androidEqualizer.enabled;
    } catch (e) {
      print("Equalizer Init Error: $e");
      // This usually happens if the AudioPipeline isn't attached to the player yet
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

      // FIX 3: Call setGain on the BAND object
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
}
