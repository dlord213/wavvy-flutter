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
          title: const Text("Audio Control"),
          centerTitle: true,
          bottom: TabBar(
            indicatorColor: theme.primaryColor,
            labelColor: theme.primaryColor,
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Enable Equalizer",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Adjust frequencies",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: controller.resetToFlat,
                  icon: const Icon(Icons.refresh_rounded),
                  tooltip: "Reset",
                  color: theme.disabledColor,
                ),
                const SizedBox(width: 8),
                Switch(
                  value: controller.isEnabled.value,
                  activeThumbColor: theme.primaryColor,
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
                        Icon(
                          Icons.equalizer_rounded,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        const Text("Equalizer not available"),
                      ],
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(controller.bands.length, (
                            index,
                          ) {
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

    String label = freqHz >= 1000
        ? "${(freqHz / 1000).toStringAsFixed(0)}k"
        : "${freqHz.toInt()}";

    return StreamBuilder<double>(
      stream: band.gainStream,
      builder: (context, snapshot) {
        final gainMb = snapshot.data ?? band.gain;
        final currentGainDb = gainMb / 100.0;

        return Container(
          width: 50,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // dB Label
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "${currentGainDb > 0 ? '+' : ''}${currentGainDb.toStringAsFixed(1)}",
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isEnabled
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.disabledColor,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Slider
              Expanded(
                child: RotatedBox(
                  quarterTurns: 3,
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 20,
                      ),
                      activeTrackColor: theme.primaryColor,
                      thumbColor: theme.primaryColor,
                      inactiveTrackColor: theme.disabledColor.withValues(
                        alpha: 0.1,
                      ),
                    ),
                    child: Slider(
                      min: controller.minDecibels.value,
                      max: controller.maxDecibels.value,
                      value: currentGainDb,
                      onChanged: isEnabled
                          ? (val) => controller.setBandGain(index, val)
                          : null,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Frequency Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? theme.textTheme.bodyMedium?.color?.withValues(
                          alpha: 0.7,
                        )
                      : theme.disabledColor,
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
          // Reset Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  controller.setBassBoost(0.0);
                  controller.setVirtualizer(0.0);
                  controller.setReverb("None");
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text("Reset Effects"),
                style: TextButton.styleFrom(
                  foregroundColor: theme.disabledColor,
                ),
              ),
            ],
          ),

          // --- Bass & Virtualizer ---
          Text(
            "Dynamics",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
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

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 20),

          // --- Reverb ---
          Text(
            "Environment (Reverb)",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.primaryColor,
            ),
          ),
          const SizedBox(height: 16),

          Obx(() {
            final current = controller.currentReverbPreset.value;
            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildReverbChip(context, controller, "None", current),
                _buildReverbChip(
                  context,
                  controller,
                  "SmallRoom",
                  current,
                  label: "Small Room",
                ),
                _buildReverbChip(
                  context,
                  controller,
                  "MediumRoom",
                  current,
                  label: "Medium Room",
                ),
                _buildReverbChip(
                  context,
                  controller,
                  "LargeRoom",
                  current,
                  label: "Large Room",
                ),
                _buildReverbChip(
                  context,
                  controller,
                  "MediumHall",
                  current,
                  label: "Medium Hall",
                ),
                _buildReverbChip(
                  context,
                  controller,
                  "LargeHall",
                  current,
                  label: "Large Hall",
                ),
                _buildReverbChip(context, controller, "Plate", current),
              ],
            );
          }),
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

      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: context.theme.cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isEnabled
                ? color.withValues(alpha: 0.3)
                : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (isEnabled)
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: isEnabled ? color : context.theme.disabledColor),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isEnabled
                    ? context.theme.textTheme.bodyLarge?.color
                    : context.theme.disabledColor,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 100,
              child: RotatedBox(
                quarterTurns: 3,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 24,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 12,
                      elevation: 2,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 20,
                    ),
                    activeTrackColor: color,
                    inactiveTrackColor: context.theme.disabledColor.withValues(
                      alpha: 0.1,
                    ),
                    thumbColor: Colors.white,
                  ),
                  child: Slider(value: normalizedValue, onChanged: onChanged),
                ),
              ),
            ),
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

  Widget _buildReverbChip(
    BuildContext context,
    NativeEffectsService controller,
    String id,
    String currentSelection, {
    String? label,
  }) {
    final isSelected = currentSelection == id;
    final color = context.theme.primaryColor;

    return ChoiceChip(
      label: Text(label ?? id),
      selected: isSelected,
      onSelected: (_) => controller.setReverb(id),
      backgroundColor: context.theme.cardColor,
      selectedColor: color.withValues(alpha: 0.2),
      checkmarkColor: color,
      labelStyle: TextStyle(
        color: isSelected ? color : context.theme.textTheme.bodyMedium?.color,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      side: BorderSide(color: isSelected ? color : Colors.transparent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
