import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/audio_effects/effects.screen.dart';
import 'package:wavvy/screens/library/albums/view/album.screen.dart';
import 'package:wavvy/screens/library/artists/view/artist.screen.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';
import 'package:wavvy/utils/player.utils.dart';
import 'package:wavvy/utils/snackbar.utils.dart';

class SongMenuOptions {
  final bool showPlayNext;
  final bool showAddToQueue;
  final bool showAddToPlaylist;
  final bool showGoToArtist;
  final bool showGoToAlbum;
  final bool showSleepTimer;
  final bool showEditTags;
  final bool showDelete;
  final bool showShare;
  final bool showCustomEqualizer;
  final bool showSystemEqualizer;
  final bool showSongInfo;

  const SongMenuOptions({
    this.showPlayNext = true,
    this.showAddToQueue = true,
    this.showAddToPlaylist = true,
    this.showGoToArtist = true,
    this.showGoToAlbum = true,
    this.showSleepTimer = true,
    this.showEditTags = true,
    this.showDelete = false,
    this.showShare = true,
    this.showCustomEqualizer = false,
    this.showSystemEqualizer = false,
    this.showSongInfo = false,
  });
}

class SongMenuHelper {
  // Dependencies
  static final AudioController _audioController = Get.find<AudioController>();
  static final PlaylistsController _playlistController =
      Get.find<PlaylistsController>();

  static void show(
    BuildContext context,
    SongModel song, {
    SongMenuOptions options = const SongMenuOptions(),
  }) {
    final bgColor = _audioController.playerColor.value ?? context.theme.scaffoldBackgroundColor;
    final textColor = _audioController.playerColor.value != null 
        ? _audioController.playerTextColor.value 
        : (context.theme.textTheme.bodyLarge?.color ?? Colors.black);
    final subTextColor = textColor.withValues(alpha: 0.7);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                // Drag handle pill
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2.5),
                  ),
                ),
                const SizedBox(height: 8),

                // --- HEADER ---
                _buildHeader(song, textColor, subTextColor),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: textColor.withValues(alpha: 0.1), height: 16),
                ),

                // --- SCROLLABLE OPTIONS ---
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: const EdgeInsets.only(bottom: 24),
                    children: [
                      if (options.showPlayNext)
                        _buildOption(
                          icon: Icons.playlist_play_rounded,
                          label: "Play Next",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.playNext(song);
                          },
                        ),

                      if (options.showAddToQueue)
                        _buildOption(
                          icon: Icons.queue_music_rounded,
                          label: "Add to Queue",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.addToQueue(song);
                          },
                        ),

                      if (options.showAddToPlaylist)
                        _buildOption(
                          icon: Icons.playlist_add_rounded,
                          label: "Add to Playlist",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _playlistController.showAddToPlaylistSheet(
                              context,
                              song,
                            );
                          },
                        ),

                      if (options.showCustomEqualizer)
                        _buildOption(
                          icon: Icons.equalizer_rounded,
                          label: "Custom equalizer",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const AudioEffectsScreen());
                          },
                        ),

                      if (options.showSystemEqualizer)
                        _buildOption(
                          icon: Icons.surround_sound_rounded,
                          label: "System equalizer",
                          color: textColor,
                          onTap: () {
                            PlayerUtils.openEqualizer(
                              _audioController
                                  .audioPlayer
                                  .androidAudioSessionId,
                            );
                          },
                        ),

                      if (options.showGoToArtist)
                        _buildOption(
                          icon: Icons.person_rounded,
                          label: "Go to Artist",
                          color: textColor,
                          onTap: () => _handleGoToArtist(context, song),
                        ),

                      if (options.showGoToAlbum)
                        _buildOption(
                          icon: Icons.album_rounded,
                          label: "Go to Album",
                          color: textColor,
                          onTap: () => _handleGoToAlbum(context, song),
                        ),

                      if (options.showShare)
                        _buildOption(
                          icon: Icons.ios_share_rounded,
                          label: "Share",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            PlayerUtils.shareSong(song);
                          },
                        ),

                      if (options.showSleepTimer)
                        _buildOption(
                          icon: Icons.timer_rounded,
                          label: "Sleep timer",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.openSleepTimerDialog();
                          },
                        ),

                      if (options.showEditTags)
                        _buildOption(
                          icon: Icons.edit_rounded,
                          label: "Edit tags",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.editSongTags(song);
                          },
                        ),

                      if (options.showDelete)
                        _buildOption(
                          icon: Icons.delete_outline_rounded,
                          label: "Delete",
                          color: Colors.redAccent,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.deleteSong(song);
                          },
                        ),

                      if (options.showSongInfo)
                        _buildOption(
                          icon: Icons.info_outline_rounded,
                          label: "Song Info",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            showInfoDialog(
                              context,
                              song,
                              context.theme.scaffoldBackgroundColor,
                              textColor,
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  static Widget _buildHeader(SongModel song, Color textColor, Color subColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      leading: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: QueryArtworkWidget(
          id: song.id,
          type: ArtworkType.AUDIO,
          artworkBorder: BorderRadius.circular(16),
          artworkWidth: 64,
          artworkHeight: 64,
          nullArtworkWidget: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: textColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.music_note_rounded, color: textColor, size: 30),
          ),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: textColor,
          fontSize: 18,
          letterSpacing: -0.5,
        ),
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4.0),
        child: Text(
          song.artist ?? "Unknown Artist",
          maxLines: 1,
          style: TextStyle(color: subColor, fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  static Widget _buildOption({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.05),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  static void _handleGoToArtist(BuildContext context, SongModel song) {
    Navigator.pop(context);
    final artistModel = _audioController.artists.firstWhereOrNull(
      (a) => a.id == song.artistId,
    );

    if (artistModel != null) {
      Get.to(() => ArtistDetailScreen(artist: artistModel));
    } else {
      AppSnackbar.showErrorSnackBar("Error", "Artist info not found");
    }
  }

  static void _handleGoToAlbum(BuildContext context, SongModel song) {
    Navigator.pop(context);
    final albumModel = _audioController.albums.firstWhereOrNull(
      (a) => a.id == song.albumId,
    );

    if (albumModel != null) {
      Get.to(() => AlbumDetailScreen(album: albumModel));
    } else {
      AppSnackbar.showErrorSnackBar("Error", "Album info not found");
    }
  }

  static void showInfoDialog(
    BuildContext context,
    SongModel song,
    Color bgColor,
    Color textColor,
  ) {
    Get.defaultDialog(
      title: "Song Details",
      titleStyle: TextStyle(
        color: context.theme.colorScheme.onSurface,
        fontWeight: FontWeight.w800,
        fontSize: 22,
        letterSpacing: -0.5,
      ),
      backgroundColor: context.theme.colorScheme.surfaceContainer,
      contentPadding: const EdgeInsets.all(24),
      radius: 20,
      content: Text(
        _audioController.getSongInfo(song),
        style: TextStyle(
          color: context.theme.colorScheme.onSurface.withValues(alpha: 0.8),
          height: 1.5,
        ),
      ),
      confirm: TextButton(
        onPressed: () => Get.back(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          backgroundColor: context.theme.primaryColor.withValues(alpha: 0.1),
        ),
        child: Text("Close", style: TextStyle(fontWeight: FontWeight.bold, color: context.theme.primaryColor)),
      ),
    );
  }
}
