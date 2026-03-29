import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/service/effects.service.dart';
import 'package:wavvy/service/equalizer.service.dart';

class AudioEffectsScreen extends StatelessWidget {
  const AudioEffectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Audio Control", style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -0.5)),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700),
            unselectedLabelColor: theme.disabledColor,
            tabs: const [
              Tab(text: "Equalizer"),
              Tab(text: "Effects"),
            ],
          ),
        ),
        body: const TabBarView(children: [_EqualizerTab(), _EffectsTab()]),
      ),
    );
  }
}

// ==========================================
// TAB 1: EQUALIZER
// ==========================================
class _EqualizerTab extends StatelessWidget {
  const _EqualizerTab();

  @override
  Widget build(BuildContext context) {
    final EqualizerService controller = Get.find<EqualizerService>();
    final theme = context.theme;

    return Obx(() {
      return Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                )
              ]
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Equalizer Control",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // PRESET SELECTOR
                      PopupMenuButton<String>(
                        onSelected: controller.applyPreset,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        itemBuilder: (context) {
                          return controller.presets.keys.map((String choice) {
                            return PopupMenuItem<String>(
                              value: choice,
                              child: Text(choice, style: const TextStyle(fontWeight: FontWeight.w500)),
                            );
                          }).toList();
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              controller.currentPreset.value,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Icon(Icons.keyboard_arrow_down_rounded, color: theme.primaryColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: controller.isEnabled.value,
                  activeColor: theme.primaryColor,
                  onChanged: (val) => controller.toggleEnabled(val),
                ),
              ],
            ),
          ),

          // Bands Sliders
          Expanded(
            child: controller.bands.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.equalizer_rounded, size: 64, color: theme.disabledColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        const Text("EQ Not Available", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(controller.bands.length, (index) {
                            return _buildSliderColumn(
                              context,
                              controller,
                              index,
                              theme,
                              controller.isEnabled.value,
                            );
                          }),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildSliderColumn(
    BuildContext context,
    EqualizerService controller,
    int index,
    ThemeData theme,
    bool isEnabled,
  ) {
    final band = controller.bands[index];
    final freqHz = band.centerFrequency;
    String freqLabel = freqHz >= 1000
        ? "${(freqHz / 1000).toStringAsFixed(0)}k"
        : "${freqHz.toInt()}";

    return StreamBuilder<double>(
      stream: band.gainStream,
      initialData: band.gain,
      builder: (context, snapshot) {
        final gainMb = snapshot.data ?? 0.0;
        final currentGainDb = gainMb / 100.0;
        final minDb = controller.minDecibels.value;
        final maxDb = controller.maxDecibels.value;
        final safeSliderValue = currentGainDb.clamp(minDb, maxDb);

        return Container(
          width: 50,
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isEnabled
                      ? theme.primaryColor.withValues(alpha: 0.1)
                      : theme.disabledColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  "${safeSliderValue > 0 ? '+' : ''}${safeSliderValue.toStringAsFixed(1)}",
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isEnabled ? theme.primaryColor : theme.disabledColor,
                    fontFeatures: [const FontFeature.tabularFigures()],
                  ),
                ),
              ),

              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      trackShape: const RoundedRectSliderTrackShape(),
                      activeTrackColor: theme.primaryColor,
                      inactiveTrackColor: theme.disabledColor.withValues(alpha: 0.2),
                      thumbColor: Colors.white,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 10,
                        elevation: 4,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      disabledActiveTrackColor: theme.disabledColor.withValues(alpha: 0.5),
                      disabledInactiveTrackColor: theme.disabledColor.withValues(alpha: 0.1),
                      disabledThumbColor: theme.disabledColor,
                    ),
                    child: Slider(
                      value: safeSliderValue,
                      min: minDb,
                      max: maxDb,
                      onChanged: isEnabled
                          ? (val) => controller.setBandGain(index, val)
                          : null,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Text(
                freqLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isEnabled ? theme.colorScheme.onSurface : theme.disabledColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// TAB 2: NATIVE EFFECTS
// ==========================================
class _EffectsTab extends StatelessWidget {
  const _EffectsTab();

  @override
  Widget build(BuildContext context) {
    final NativeEffectsService controller = Get.find<NativeEffectsService>();
    final theme = context.theme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Dynamics",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: () {
                  controller.setBassBoost(0.0);
                  controller.setVirtualizer(0.0);
                  controller.setReverb("None");
                },
                icon: const Icon(Icons.refresh_rounded),
                color: theme.disabledColor,
                tooltip: "Reset Effects",
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildEffectControl(
                  context,
                  title: "Bass Boost",
                  icon: Icons.speaker_group_rounded,
                  rxValue: controller.bassBoostStrength,
                  rxEnabled: controller.isBassBoostEnabled,
                  onChanged: (val) => controller.setBassBoost(val),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildEffectControl(
                  context,
                  title: "Virtualizer",
                  icon: Icons.surround_sound_rounded,
                  rxValue: controller.virtualizerStrength,
                  rxEnabled: controller.isVirtualizerEnabled,
                  onChanged: (val) => controller.setVirtualizer(val),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEffectControl(
    BuildContext context, {
    required String title,
    required IconData icon,
    required RxDouble rxValue,
    required RxBool rxEnabled,
    required Function(double) onChanged,
  }) {
    return Obx(() {
      final double normalizedValue = rxValue.value / 1000;
      final bool isEnabled = rxEnabled.value;
      final color = context.theme.primaryColor;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 240,
        decoration: BoxDecoration(
          color: isEnabled ? color.withValues(alpha: 0.05) : context.theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isEnabled ? color.withValues(alpha: 0.3) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            if (!isEnabled)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isEnabled ? color.withValues(alpha: 0.1) : context.theme.disabledColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: isEnabled ? color : context.theme.disabledColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14,
                color: isEnabled ? context.theme.textTheme.bodyLarge?.color : context.theme.disabledColor,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 80,
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 12,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 4,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
                    ),
                    activeTrackColor: color,
                    inactiveTrackColor: context.theme.disabledColor.withValues(alpha: 0.15),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(value: normalizedValue, onChanged: onChanged),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "${(normalizedValue * 100).toInt()}%",
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: isEnabled ? color : context.theme.disabledColor,
              ),
            ),
          ],
        ),
      );
    });
  }
}
