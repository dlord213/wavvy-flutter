import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/screens/custom_equalizer/equalizer.screen.dart';
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
    final bgColor = _audioController.playerColor.value;
    final textColor = _audioController.playerTextColor.value;
    final subTextColor = textColor.withValues(alpha: 0.7);

    showModalBottomSheet(
      context: context,
      backgroundColor: bgColor,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                const SizedBox(height: 8),
                // --- HEADER ---
                _buildHeader(song, textColor, subTextColor),
                Divider(color: textColor.withValues(alpha: 0.2)),

                // --- SCROLLABLE OPTIONS ---
                Expanded(
                  child: ListView(
                    controller: controller,
                    padding: EdgeInsets.zero,
                    children: [
                      if (options.showPlayNext)
                        _buildOption(
                          icon: Icons.playlist_play,
                          label: "Play Next",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.playNext(song);
                          },
                        ),

                      if (options.showAddToQueue)
                        _buildOption(
                          icon: Icons.queue_music,
                          label: "Add to Queue",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.addToQueue(song);
                          },
                        ),

                      if (options.showAddToPlaylist)
                        _buildOption(
                          icon: Icons.playlist_add,
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

                      if (options.showGoToArtist)
                        _buildOption(
                          icon: Icons.person,
                          label: "Go to Artist",
                          color: textColor,
                          onTap: () => _handleGoToArtist(context, song),
                        ),

                      if (options.showGoToAlbum)
                        _buildOption(
                          icon: Icons.album,
                          label: "Go to Album",
                          color: textColor,
                          onTap: () => _handleGoToAlbum(context, song),
                        ),

                      if (options.showShare)
                        _buildOption(
                          icon: Icons.share,
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

                      if (options.showCustomEqualizer)
                        _buildOption(
                          icon: Icons.equalizer_rounded,
                          label: "Custom equalizer",
                          color: textColor,
                          onTap: () {
                            Navigator.pop(context);
                            Get.to(() => const EqualizerScreen());
                          },
                        ),

                      if (options.showDelete)
                        _buildOption(
                          icon: Icons.delete_outline,
                          label: "Delete",
                          color: Colors.redAccent,
                          onTap: () {
                            Navigator.pop(context);
                            _audioController.deleteSong(song);
                          },
                        ),

                      const SizedBox(height: 20),
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
      leading: QueryArtworkWidget(
        id: song.id,
        type: ArtworkType.AUDIO,
        artworkBorder: BorderRadius.circular(8),
        nullArtworkWidget: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.music_note, color: Colors.white),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        song.artist ?? "Unknown Artist",
        maxLines: 1,
        style: TextStyle(color: subColor),
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
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w500),
      ),
      onTap: onTap,
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
}
