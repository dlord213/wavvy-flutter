import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:wavvy/player_sheets/full_player_sheet.controller.dart';
import 'package:wavvy/service/settings.service.dart';

class AnimatedSeekableArtwork extends StatefulWidget {
  final SongModel song;
  final double size;
  final Color iconColor;
  final FullPlayerSheetController controller;

  const AnimatedSeekableArtwork({
    super.key,
    required this.song,
    required this.size,
    required this.iconColor,
    required this.controller,
  });

  @override
  State<AnimatedSeekableArtwork> createState() =>
      _AnimatedSeekableArtworkState();
}

class _AnimatedSeekableArtworkState extends State<AnimatedSeekableArtwork> {
  bool _showForward = false;
  bool _showRewind = false;
  Timer? _timer;
  final SettingsService _settings = Get.find();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _triggerOverlay({required bool forward}) {
    _timer?.cancel();
    setState(() {
      if (forward) {
        _showForward = true;
        _showRewind = false;
      } else {
        _showRewind = true;
        _showForward = false;
      }
    });

    // Hide after 600ms
    _timer = Timer(const Duration(milliseconds: 600), () {
      if (mounted) {
        setState(() {
          _showForward = false;
          _showRewind = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        QueryArtworkWidget(
          id: widget.song.id,
          type: ArtworkType.AUDIO,
          artworkFit: BoxFit.cover,
          artworkBorder: BorderRadius.circular(12),
          artworkWidth: widget.size,
          artworkHeight: widget.size,
          size: 1000,
          nullArtworkWidget: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.music_note, size: 80, color: widget.iconColor),
          ),
        ),

        Positioned(
          left: 0,
          right: widget.size / 2,
          child: _buildOverlayIcon(
            isVisible: _showRewind,
            icon: Icons.replay_10_rounded,
            text: "-10",
          ),
        ),

        Positioned(
          left: widget.size / 2,
          right: 0,
          child: _buildOverlayIcon(
            isVisible: _showForward,
            icon: Icons.forward_10_rounded,
            text: "+10",
          ),
        ),

        if (_settings.enableDoubleTapSeek.value)
          Positioned.fill(
            child: Row(
              children: [
                // LEFT (Rewind)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: () {
                      _triggerOverlay(forward: false);
                      widget.controller.audioController.seek(
                        const Duration(seconds: -10),
                        relative: true,
                      );
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
                const Expanded(flex: 1, child: SizedBox()),
                // RIGHT (Forward)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onDoubleTap: () {
                      _triggerOverlay(forward: true);
                      widget.controller.audioController.seek(
                        const Duration(seconds: 10),
                        relative: true,
                      );
                    },
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildOverlayIcon({
    required bool isVisible,
    required IconData icon,
    required String text,
  }) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      opacity: isVisible ? 1.0 : 0.0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(
              alpha: 0.6,
            ), // Translucent dark background
            shape: BoxShape.circle,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Icon(icon, color: Colors.white, size: 40)],
          ),
        ),
      ),
    );
  }
}
