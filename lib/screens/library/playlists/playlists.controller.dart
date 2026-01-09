import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/screens/audio.controller.dart';

class PlaylistsController extends GetxController {
  final AudioController audioController = Get.find();

  AudioController get player => audioController;

  void showNewPlaylistDialog() {
    final textController = TextEditingController();
    Get.defaultDialog(
      title: "New Playlist",
      content: TextField(controller: textController, autofocus: true),
      onConfirm: () {
        audioController.createLocalPlaylist(textController.text);
        Get.back();
      },
    );
  }

  void showRemoveDialog(int playlistId, int songId) {
    Get.defaultDialog(
      title: "Remove Song",
      middleText: "Remove this song from the playlist?",
      textConfirm: "Remove",
      confirmTextColor: Colors.white,
      onConfirm: () async {
        await audioController.removeFromLocalPlaylist(playlistId, songId);
        Get.back();
      },
    );
  }

  void showAddToPlaylistSheet(BuildContext context, SongModel song) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Add to Playlist",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (audioController.localPlaylists.isEmpty) {
                    return Center(child: Text("No playlists found"));
                  }
                  return ListView.builder(
                    itemCount: audioController.localPlaylists.length,
                    itemBuilder: (context, index) {
                      final playlist = audioController.localPlaylists[index];
                      return ListTile(
                        leading: Icon(Icons.queue_music),
                        title: Text(playlist['name'], style: TextStyle()),
                        onTap: () {
                          audioController.addSongToLocalPlaylist(
                            playlist['id'],
                            song.id,
                          );
                          Navigator.pop(context);
                        },
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        );
      },
    );
  }
}
