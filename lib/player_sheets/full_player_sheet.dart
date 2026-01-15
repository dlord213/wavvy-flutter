import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wavvy/player_sheets/full_player_sheet.controller.dart';
import 'package:wavvy/service/settings.service.dart';
import 'package:wavvy/utils/player.utils.dart';
import 'package:wavvy/widgets/lyric_card.dart';
import 'package:wavvy/widgets/seekable_artwork.dart';
import 'package:wavvy/widgets/song_menu.dart';

class FullPlayerSheet extends GetView<FullPlayerSheetController> {
  FullPlayerSheet({super.key});

  final FullPlayerSheetController sheetController = Get.find();

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final SettingsService _settings = Get.find();

    return Obx(() {
      final song = controller.audioController.currentSong.value;
      if (song == null) return const SizedBox.shrink();

      final seedColor =
          controller.audioController.playerColor.value ??
          context.theme.primaryColor;
      final mainTextColor = controller.audioController.playerTextColor.value;
      final subTextColor = mainTextColor.withValues(alpha: 0.7);
      final navBarColor = seedColor.darken(40);

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navBarColor,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness:
              controller.audioController.playerTextColor.value == Colors.black
              ? Brightness.dark
              : Brightness.light,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [seedColor, seedColor.darken(20), navBarColor],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: context.mediaQueryPadding.top + 36,
              bottom: context.mediaQueryPadding.bottom,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,

              // --- APP BAR (Shared) ---
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: mainTextColor,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: Obx(() {
                  switch (controller.sheetPageIndex.value) {
                    case 1:
                      return Text(
                        "Queue",
                        style: TextStyle(color: mainTextColor),
                      );
                    case 2:
                      return Text(
                        "Lyrics",
                        style: TextStyle(color: mainTextColor),
                      );
                    case 3:
                      return Text(
                        "Artist Info",
                        style: TextStyle(color: mainTextColor),
                      );
                    default:
                      return Text(
                        song.album ?? "Now Playing",
                        style: TextStyle(color: subTextColor, fontSize: 14),
                      );
                  }
                }),
                actions: [
                  IconButton(
                    icon: Obx(
                      () => Icon(
                        Icons.more_vert,
                        color: controller.audioController.playerTextColor.value,
                      ),
                    ),
                    onPressed: () {
                      SongMenuHelper.show(
                        context,
                        song,
                        options: SongMenuOptions(showCustomEqualizer: true),
                      );
                    },
                  ),
                ],
              ),

              // --- BODY (PageView) ---
              body: Column(
                children: [
                  Expanded(
                    child: PageView(
                      controller: controller.pageController,
                      scrollBehavior: MaterialScrollBehavior(),
                      physics: NeverScrollableScrollPhysics(),
                      onPageChanged: (index) {
                        controller.sheetPageIndex.value = index;
                        if (index == 2) {
                          controller.audioController.fetchArtistInfo(
                            song.artist ?? "",
                          );
                        }
                      },
                      children: [
                        // Page 0: MAIN PLAYER
                        _buildPlayerPage(
                          context,
                          song,
                          screenWidth,
                          mainTextColor,
                          subTextColor,
                          seedColor,
                        ),

                        // Page 1: QUEUE
                        _buildQueuePage(mainTextColor, subTextColor, seedColor),

                        // Page 2: LYRICS (LRCLib)
                        _buildLyricsPage(context),

                        // Page 3: ARTIST INFO (Genius)
                        _buildArtistPage(mainTextColor, subTextColor),
                      ],
                    ),
                  ),

                  // --- BOTTOM TABS ---
                  SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTabButton(
                          0,
                          "Player",
                          Icons.music_note,
                          mainTextColor,
                          seedColor.brighten(10),
                        ),
                        _buildTabButton(
                          1,
                          "Queue",
                          Icons.queue_music,
                          mainTextColor,
                          seedColor.brighten(10),
                        ),
                        if (_settings.enableLyricsFetching.value)
                          _buildTabButton(
                            2,
                            "Lyrics",
                            Icons.lyrics_rounded,
                            mainTextColor,
                            seedColor.brighten(10),
                          ),
                        if (_settings.enableArtistInfoFetching.value)
                          _buildTabButton(
                            3,
                            "Artist",
                            Icons.person_rounded,
                            mainTextColor,
                            seedColor.brighten(10),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  // --- WIDGET BUILDERS ---

  Widget _buildTabButton(
    int index,
    String label,
    IconData icon,
    Color color,
    Color activeColor,
  ) {
    return Obx(() {
      final isSelected = controller.sheetPageIndex.value == index;
      return TextButton.icon(
        onPressed: () => controller.pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        icon: Icon(
          icon,
          color: isSelected ? activeColor : color.withValues(alpha: 0.3),
          size: 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : color.withValues(alpha: 0.3),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    });
  }

  Widget _buildPlayerPage(
    BuildContext context,
    SongModel song,
    double screenWidth,
    Color mainTextColor,
    Color subTextColor,
    Color activeColor,
  ) {
    final artworkSize = screenWidth - 48;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          const Spacer(flex: 2),

          Container(
            height: artworkSize,
            width: artworkSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 25,
                  offset: const Offset(0, 8),
                  spreadRadius: -5,
                ),
              ],
            ),
            child: AnimatedSeekableArtwork(
              song: song,
              size: artworkSize,
              iconColor: subTextColor,
              controller: controller,
            ),
          ),

          const Spacer(flex: 3),

          // Title & Artist
          Column(
            children: [
              Text(
                song.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: mainTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                song.artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: subTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Seek Bar
          Obx(() {
            final max = controller
                .audioController
                .totalDuration
                .value
                .inMilliseconds
                .toDouble();
            final current = controller
                .audioController
                .currentPosition
                .value
                .inMilliseconds
                .toDouble();
            final sliderValue = (max > 0) ? current.clamp(0.0, max) : 0.0;

            return Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: mainTextColor,
                    inactiveTrackColor: mainTextColor.withValues(alpha: 0.2),
                    thumbColor: mainTextColor,
                    trackHeight: 6,
                    trackShape: const RoundedRectSliderTrackShape(),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 8,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 16,
                    ),
                  ),
                  child: Slider(
                    min: 0,
                    max: max > 0 ? max : 1.0,
                    value: sliderValue,
                    onChanged: (val) => controller.audioController.seek(
                      Duration(milliseconds: val.toInt()),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PlayerUtils.formatDuration(
                          controller.audioController.currentPosition.value,
                        ),
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        PlayerUtils.formatDuration(
                          controller.audioController.totalDuration.value,
                        ),
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: controller.audioController.toggleShuffle,
                icon: Icon(Icons.shuffle_rounded),
                color: controller.audioController.isShuffleModeEnabled.value
                    ? activeColor.brighten(20)
                    : subTextColor,
                iconSize: 28,
              ),

              IconButton(
                onPressed: controller.audioController.previous,
                icon: const Icon(Icons.skip_previous_rounded),
                color: mainTextColor,
                iconSize: 42,
              ),

              Container(
                decoration: BoxDecoration(
                  color: mainTextColor,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  iconSize: 48,
                  onPressed: controller.audioController.togglePlay,
                  icon: Icon(
                    controller.audioController.isPlaying.value
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: mainTextColor.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                  ),
                ),
              ),

              IconButton(
                onPressed: controller.audioController.next,
                icon: const Icon(Icons.skip_next_rounded),
                color: mainTextColor,
                iconSize: 42,
              ),

              IconButton(
                onPressed: controller.audioController.cycleLoopMode,
                icon: Icon(
                  PlayerUtils.getLoopIcon(
                    controller.audioController.loopMode.value,
                  ),
                ),
                color: controller.audioController.loopMode.value == LoopMode.off
                    ? subTextColor
                    : activeColor.brighten(20),
                iconSize: 28,
              ),
            ],
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }

  Widget _buildQueuePage(
    Color textColor,
    Color subTextColor,
    Color activeColor,
  ) {
    return Obx(() {
      final queue = controller.audioController.queue;
      final currentIndex = controller.audioController.currentIndex.value;

      final ScrollController scrollController = ScrollController();
      if (currentIndex > 0 && queue.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (scrollController.hasClients) {}
        });
      }

      return ListView.builder(
        controller: scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: queue.length,
        itemBuilder: (context, index) {
          final s = queue[index];
          final isPlaying = currentIndex == index;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isPlaying
                  ? activeColor.withValues(alpha: 0.2)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isPlaying
                  ? Border.all(color: activeColor.withValues(alpha: 0.5))
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: QueryArtworkWidget(
                id: s.id,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.music_note_rounded, color: subTextColor),
                ),
                artworkBorder: BorderRadius.circular(8),
              ),
              title: Text(
                s.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPlaying ? activeColor.brighten(20) : textColor,
                  fontWeight: isPlaying ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                s.artist ?? "Unknown",
                maxLines: 1,
                style: TextStyle(color: subTextColor, fontSize: 13),
              ),
              onTap: () {
                if (currentIndex != index) {
                  controller.audioController.audioPlayer.seek(
                    Duration.zero,
                    index: index,
                  );
                  controller.audioController.audioPlayer.play();
                }
              },
            ),
          );
        },
      );
    });
  }

  Widget _buildLyricsPage(BuildContext context) {
    return Obx(() {
      final mainTextColor = controller.audioController.playerTextColor.value;
      final activeColor = mainTextColor.brighten(30);

      if (controller.audioController.isLyricsLoading.value) {
        return Center(child: CircularProgressIndicator(color: mainTextColor));
      }

      if (controller.audioController.lyrics.isEmpty) {
        return Center(child: Text("No Lyrics"));
      }

      return Stack(
        children: [
          ScrollablePositionedList.builder(
            itemCount: controller.audioController.lyrics.length,
            itemScrollController:
                controller.audioController.lyricsScrollController,
            itemPositionsListener:
                controller.audioController.lyricsPositionListener,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 100,
            ),
            itemBuilder: (context, index) {
              final line = controller.audioController.lyrics[index];
              final isActive =
                  index == controller.audioController.currentLyricIndex.value;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  line.text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isActive
                        ? activeColor
                        : mainTextColor.withValues(alpha: 0.4),
                    fontSize: isActive ? 20 : 18,
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton.extended(
              elevation: 0,
              backgroundColor: activeColor,
              foregroundColor: activeColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              icon: const Icon(Icons.ios_share),
              label: const Text("Share Card"),
              onPressed: () {
                final song = controller.audioController.currentSong.value;
                if (song != null) {
                  Get.to(
                    () => LyricCardGenerator(
                      song: song,
                      lyrics: controller.audioController.lyrics,
                      themeColor: activeColor,
                    ),
                  );
                }
              },
            ),
          ),
        ],
      );
    });
  }

  Widget _buildArtistPage(Color textColor, Color subTextColor) {
    return Obx(() {
      if (controller.audioController.isArtistLoading.value) {
        return Center(child: CircularProgressIndicator(color: textColor));
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            if (controller.audioController.artistImageUrl.value.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Image.network(
                  controller.audioController.artistImageUrl.value,
                  width: 160,
                  height: 160,
                  fit: BoxFit.cover,
                  errorBuilder: (c, o, s) =>
                      Icon(Icons.person, size: 100, color: subTextColor),
                ),
              )
            else
              Icon(Icons.person, size: 100, color: subTextColor),

            const SizedBox(height: 24),
            Text(
              controller.audioController.currentSong.value?.artist ??
                  "About the Artist",
              style: TextStyle(
                color: textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller.audioController.artistBio.value.isEmpty
                  ? "No information found."
                  : controller.audioController.artistBio.value,
              style: TextStyle(color: subTextColor, fontSize: 16, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    });
  }
}
