import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/audio.controller.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';
import 'package:wavvy/screens/library/playlists/view/playlist.screen.dart';
import 'package:wavvy/widgets/bottom_bar.dart';

class AllLocalPlaylistsScreen extends GetView<PlaylistsController> {
  const AllLocalPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.scaffoldBackgroundColor,
      bottomNavigationBar: BottomMiniPlayer(showTabView: false),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: controller.showNewPlaylistDialog,
        icon: const Icon(Icons.add),
        label: const Text("New Playlist"),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: Obx(() {
                if (controller.audioController.localPlaylists.isEmpty) {
                  return const Center(child: Text("No custom playlists yet."));
                }
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: controller.audioController.localPlaylists.length,
                  itemBuilder: (context, index) {
                    final playlist =
                        controller.audioController.localPlaylists[index];
                    return _buildPlaylistCard(context, playlist);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistCard(
    BuildContext context,
    Map<String, dynamic> playlist,
  ) {
    return GestureDetector(
      onTap: () async {
        final playlistSongs = await controller.audioController
            .getSongsInPlaylist(playlist['id']);
        Get.to(
          () => PlaylistDetailScreen(
            playlistId: playlist['id'],
            playlistName: playlist['name'],
          ),
          transition: Transition.rightToLeft,
        );
      },
      child: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: context.theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Center(
                child: Icon(
                  Icons.queue_music_rounded,
                  size: 64,
                  color: context.theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist['name'],
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        spacing: 12,
        children: [
          IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(Icons.arrow_back),
          ),
          const Text(
            "My Playlists",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
