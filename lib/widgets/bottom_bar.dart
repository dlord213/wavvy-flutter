import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/audio.controller.dart';
import 'package:wavvy/player_sheets/full_player_sheet.controller.dart';
import 'package:wavvy/player_sheets/full_player_sheet.dart';

class BottomMiniPlayer extends GetView<AudioController> {
  final bool showTabView;

  BottomMiniPlayer({super.key, this.showTabView = true});
  final FullPlayerSheetController sheetController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;

    return Obx(() {
      final song = controller.currentSong.value;

      final backgroundColor =
          controller.playerColor.value ??
          context.theme.colorScheme.surfaceContainerHighest;

      final textColor = controller.playerColor.value != null
          ? controller.playerTextColor.value
          : context.theme.colorScheme.onSurfaceVariant;

      final subTextColor = textColor.withValues(alpha: 0.7);

      final double totalHeight;
      if (song != null) {
        totalHeight = (showTabView ? 130 : 80) + bottomPadding;
      } else {
        totalHeight = (showTabView ? 50 : 0) + bottomPadding;
      }

      return GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useSafeArea: false,
            backgroundColor: Colors.transparent,
            builder: (context) {
              sheetController.updateSheetPageIndex(0);
              return FullPlayerSheet();
            },
          );
        },
        child: AnimatedContainer(
          padding: EdgeInsets.only(bottom: bottomPadding),
          duration: const Duration(milliseconds: 300),
          height: totalHeight,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- (Only if song exists) ---
              if (song != null) ...[
                Obx(() {
                  final max = controller.totalDuration.value.inMilliseconds
                      .toDouble();
                  final current = controller
                      .currentPosition
                      .value
                      .inMilliseconds
                      .toDouble();
                  final value = (max > 0)
                      ? (current / max).clamp(0.0, 1.0)
                      : 0.0;

                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 12),
                    child: LinearProgressIndicator(
                      value: value,
                      backgroundColor: Colors.transparent,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        backgroundColor.lighten(30),
                      ),
                      minHeight: 4,
                    ),
                  );
                }),

                SizedBox(
                  height: 76,
                  child: Row(
                    children: [
                      // Artwork
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: QueryArtworkWidget(
                          id: song.id,
                          type: ArtworkType.AUDIO,
                          artworkFit: BoxFit.cover,
                          artworkWidth: 48,
                          artworkHeight: 48,
                          nullArtworkWidget: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(Icons.music_note, color: textColor),
                          ),
                          artworkBorder: BorderRadius.circular(6),
                        ),
                      ),

                      // Texts
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              song.artist ?? "Unknown",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: textColor,
                              size: 28,
                            ),
                            onPressed: controller.previous,
                          ),
                          IconButton(
                            icon: Icon(
                              controller.isPlaying.value
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: textColor,
                              size: 28,
                            ),
                            onPressed: controller.togglePlay,
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: textColor,
                              size: 28,
                            ),
                            onPressed: controller.next,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // --- (Only if showTabView) ---
              if (showTabView)
                SizedBox(
                  height: 48,
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    labelColor: textColor,
                    unselectedLabelColor: subTextColor.withValues(alpha: 0.5),
                    indicatorColor: backgroundColor.lighten(30),
                    indicatorSize: TabBarIndicatorSize.label,
                    tabs: const [
                      Tab(icon: Icon(Icons.music_note)),
                      Tab(icon: Icon(Icons.library_books)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}
