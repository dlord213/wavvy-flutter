import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/player_sheets/full_player_sheet.controller.dart';
import 'package:wavvy/player_sheets/full_player_sheet.dart';
import 'package:wavvy/service/settings.service.dart';

class BottomMiniPlayer extends GetView<AudioController> {
  final bool showTabView;

  BottomMiniPlayer({super.key, this.showTabView = true});
  final FullPlayerSheetController sheetController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final SettingsService _settings = Get.find();

    return Obx(() {
      final song = controller.currentSong.value;

      final backgroundColor = controller.playerColor.value ?? 
          (context.isDarkMode ? Colors.grey[900]! : Colors.white);

      final textColor = controller.playerColor.value != null
          ? controller.playerTextColor.value
          : context.theme.colorScheme.onSurfaceVariant;

      final subTextColor = textColor.withValues(alpha: 0.7);

      final double totalHeight;
      if (song != null) {
        totalHeight = (showTabView ? 140 : 88) + bottomPadding;
      } else {
        totalHeight = (showTabView ? 60 : 0) + bottomPadding;
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
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.only(
            left: 12, 
            right: 12, 
            bottom: bottomPadding > 0 ? bottomPadding : 12
          ),
          height: song != null ? totalHeight - bottomPadding : (showTabView ? 60 : 0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- (Only if song exists) ---
              if (song != null) ...[
                const SizedBox(height: 8),
                Obx(() {
                  final max = controller.totalDuration.value.inMilliseconds.toDouble();
                  final current = controller.currentPosition.value.inMilliseconds.toDouble();
                  final value = (max > 0) ? (current / max).clamp(0.0, 1.0) : 0.0;

                  return Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: value,
                        backgroundColor: textColor.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          controller.playerColor.value != null 
                             ? backgroundColor.lighten(30) 
                             : context.theme.primaryColor,
                        ),
                      ),
                    ),
                  );
                }),
                
                const SizedBox(height: 8),

                SizedBox(
                  height: 64,
                  child: Row(
                    children: [
                      // Artwork
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: QueryArtworkWidget(
                              id: song.id,
                              type: ArtworkType.AUDIO,
                              artworkFit: BoxFit.cover,
                              artworkWidth: 52,
                              artworkHeight: 52,
                              nullArtworkWidget: Container(
                                width: 52,
                                height: 52,
                                color: textColor.withValues(alpha: 0.05),
                                child: Icon(Icons.music_note_rounded, color: textColor),
                              ),
                            ),
                          ),
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
                                fontWeight: FontWeight.w700,
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
                                fontWeight: FontWeight.w500,
                                color: subTextColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Controls
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.skip_previous_rounded,
                                color: textColor,
                                size: 30,
                              ),
                              onPressed: controller.previous,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: textColor.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  controller.isPlaying.value
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: textColor,
                                  size: 30,
                                ),
                                onPressed: controller.togglePlay,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.skip_next_rounded,
                                color: textColor,
                                size: 30,
                              ),
                              onPressed: controller.next,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // --- (Only if showTabView) ---
              if (showTabView) ...[
                if (song != null) const SizedBox(height: 4),
                SizedBox(
                  height: 48,
                  child: TabBar(
                    dividerColor: Colors.transparent,
                    labelColor: controller.playerColor.value != null 
                        ? textColor 
                        : context.theme.primaryColor,
                    unselectedLabelColor: subTextColor.withValues(alpha: 0.5),
                    indicatorColor: Colors.transparent, // Handle indication via tab style, or keep line
                    // Custom indicator
                    indicator: UnderlineTabIndicator(
                      borderSide: BorderSide(
                        width: 3, 
                        color: controller.playerColor.value != null 
                            ? backgroundColor.lighten(30) 
                            : context.theme.primaryColor
                      ),
                      insets: const EdgeInsets.symmetric(horizontal: 32),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    tabs: [
                      Tab(icon: Icon(Icons.music_note_rounded)),
                      Tab(icon: Icon(Icons.library_books_rounded)),
                      if (_settings.enableDownloader.value)
                        Tab(icon: Icon(Icons.downloading_rounded)),
                    ],
                  ),
                ),
                if (song == null) const Spacer(),
              ]
            ],
          ),
        ),
      );
    });
  }
}
