import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/service/equalizer.service.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EqualizerService controller = Get.find<EqualizerService>();
    final theme = context.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Equalizer"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: controller.resetToFlat,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Reset",
          ),
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
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
                        "Adjust audio frequencies",
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  Switch(
                    value: controller.isEnabled.value,
                    activeColor: theme.primaryColor,
                    onChanged: (val) => controller.toggleEnabled(val),
                  ),
                ],
              ),
            ),
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
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
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
      }),
    );
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
    String label;
    if (freqHz >= 1000) {
      label = "${(freqHz / 1000).toStringAsFixed(0)}k";
    } else {
      label = "${freqHz.toInt()}";
    }

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
                      inactiveTrackColor: theme.disabledColor.withOpacity(0.1),
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
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? theme.textTheme.bodyMedium?.color?.withOpacity(0.7)
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
