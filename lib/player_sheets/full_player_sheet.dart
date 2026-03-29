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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [seedColor, seedColor.darken(15), navBarColor],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              top: context.mediaQueryPadding.top + 24,
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
                    size: 32,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                centerTitle: true,
                title: Obx(() {
                  switch (controller.sheetPageIndex.value) {
                    case 1:
                      return Text(
                        "Playing Next",
                        style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 16),
                      );
                    case 2:
                      return Text(
                        "Lyrics",
                        style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 16),
                      );
                    case 3:
                      return Text(
                        "Artist",
                        style: TextStyle(color: mainTextColor, fontWeight: FontWeight.bold, fontSize: 16),
                      );
                    default:
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "PLAYING FROM ALBUM",
                            style: TextStyle(
                              color: subTextColor, 
                              fontSize: 10, 
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            song.album ?? "Single",
                            style: TextStyle(
                              color: mainTextColor, 
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                  }
                }),
                actions: [
                  IconButton(
                    icon: Obx(
                      () => Icon(
                        Icons.more_horiz_rounded,
                        color: controller.audioController.playerTextColor.value,
                        size: 28,
                      ),
                    ),
                    onPressed: () {
                      SongMenuHelper.show(
                        context,
                        song,
                        options: const SongMenuOptions(
                          showCustomEqualizer: true,
                          showSystemEqualizer: true,
                          showSongInfo: true,
                        ),
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
                      scrollBehavior: const MaterialScrollBehavior(),
                      physics: const NeverScrollableScrollPhysics(),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildTabButton(
                          0,
                          "Player",
                          Icons.music_note_rounded,
                          mainTextColor,
                          seedColor.brighten(20),
                        ),
                        const SizedBox(width: 8),
                        _buildTabButton(
                          1,
                          "Queue",
                          Icons.queue_music_rounded,
                          mainTextColor,
                          seedColor.brighten(20),
                        ),
                        if (_settings.enableLyricsFetching.value) ...[
                          const SizedBox(width: 8),
                          _buildTabButton(
                            2,
                            "Lyrics",
                            Icons.lyrics_rounded,
                            mainTextColor,
                            seedColor.brighten(20),
                          ),
                        ],
                        if (_settings.enableArtistInfoFetching.value) ...[
                          const SizedBox(width: 8),
                          _buildTabButton(
                            3,
                            "Artist",
                            Icons.person_rounded,
                            mainTextColor,
                            seedColor.brighten(20),
                          ),
                        ],
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
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: () => controller.pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
        icon: Icon(
          icon,
          color: isSelected ? activeColor : color.withValues(alpha: 0.5),
          size: 20,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : color.withValues(alpha: 0.5),
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
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
    final artworkSize = screenWidth - 64;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0),
      child: Column(
        children: [
          const Spacer(flex: 2),

          Container(
            height: artworkSize,
            width: artworkSize,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                  spreadRadius: -10,
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
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: mainTextColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                song.artist ?? "Unknown Artist",
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: subTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 36),

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
                    trackHeight: 8,
                    trackShape: const RoundedRectSliderTrackShape(),
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 4,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 24,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        PlayerUtils.formatDuration(
                          controller.audioController.currentPosition.value,
                        ),
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        PlayerUtils.formatDuration(
                          controller.audioController.totalDuration.value,
                        ),
                        style: TextStyle(
                          color: subTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
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
                icon: const Icon(Icons.shuffle_rounded),
                color: controller.audioController.isShuffleModeEnabled.value
                    ? activeColor.brighten(30)
                    : subTextColor,
                iconSize: 28,
              ),

              IconButton(
                onPressed: controller.audioController.previous,
                icon: const Icon(Icons.skip_previous_rounded),
                color: mainTextColor,
                iconSize: 44,
              ),

              Container(
                decoration: BoxDecoration(
                  color: mainTextColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: mainTextColor.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    )
                  ],
                ),
                padding: const EdgeInsets.all(4),
                child: IconButton(
                  iconSize: 56,
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
                iconSize: 44,
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
                    : activeColor.brighten(30),
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
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isPlaying
                  ? activeColor.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              border: isPlaying
                  ? Border.all(color: activeColor.withValues(alpha: 0.3))
                  : null,
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 6,
              ),
              leading: QueryArtworkWidget(
                id: s.id,
                type: ArtworkType.AUDIO,
                nullArtworkWidget: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.music_note_rounded, color: subTextColor),
                ),
                artworkBorder: BorderRadius.circular(12),
                artworkWidth: 52,
                artworkHeight: 52,
              ),
              title: Text(
                s.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPlaying ? activeColor.brighten(30) : textColor,
                  fontWeight: isPlaying ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              subtitle: Text(
                s.artist ?? "Unknown",
                maxLines: 1,
                style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.w500),
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
        return Center(
          child: Text(
            "No Lyrics found", 
            style: TextStyle(color: mainTextColor.withValues(alpha: 0.5), fontSize: 18, fontWeight: FontWeight.bold)
          )
        );
      }

      return Stack(
        children: [
          ScrollablePositionedList.builder(
            itemCount: controller.audioController.lyrics.length,
            physics: const BouncingScrollPhysics(),
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
                    fontSize: isActive ? 24 : 18,
                    fontWeight: isActive ? FontWeight.w900 : FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
              );
            },
          ),

          Positioned(
            bottom: 24,
            right: 24,
            child: FloatingActionButton.extended(
              elevation: 4,
              backgroundColor: activeColor,
              foregroundColor: activeColor.computeLuminance() > 0.5
                  ? Colors.black
                  : Colors.white,
              icon: const Icon(Icons.ios_share_rounded),
              label: const Text("Share Card", style: TextStyle(fontWeight: FontWeight.bold)),
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
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            if (controller.audioController.artistImageUrl.value.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ]
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Image.network(
                    controller.audioController.artistImageUrl.value,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) =>
                        Container(
                          width: 200,
                          height: 200,
                          color: textColor.withValues(alpha: 0.05),
                          child: Icon(Icons.person_rounded, size: 80, color: subTextColor),
                        )
                  ),
                ),
              )
            else
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: textColor.withValues(alpha: 0.05),
                ),
                child: Icon(Icons.person_rounded, size: 80, color: subTextColor),
              ),

            const SizedBox(height: 32),
            Text(
              controller.audioController.currentSong.value?.artist ??
                  "About the Artist",
              style: TextStyle(
                color: textColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Text(
              controller.audioController.artistBio.value.isEmpty
                  ? "No information found."
                  : controller.audioController.artistBio.value,
              style: TextStyle(
                color: subTextColor, 
                fontSize: 16, 
                height: 1.6,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
          ],
        ),
      );
    });
  }
}
