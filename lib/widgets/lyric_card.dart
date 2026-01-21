import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:wavvy/models/lyric.dart';
import 'package:wavvy/controllers/audio.controller.dart';
import 'package:wavvy/utils/snackbar.utils.dart';

class LyricCardGenerator extends StatefulWidget {
  final SongModel song;
  final List<Lyric> lyrics;
  final Color themeColor;

  const LyricCardGenerator({
    super.key,
    required this.song,
    required this.lyrics,
    required this.themeColor,
  });

  @override
  State<LyricCardGenerator> createState() => _LyricCardGeneratorState();
}

class _LyricCardGeneratorState extends State<LyricCardGenerator> {
  final ScreenshotController _screenshotController = ScreenshotController();
  final Set<int> _selectedIndices = {}; // Track selected lines
  final int _maxLines = 1; // Increased limit slightly for better cards
  Uint8List? _artworkBytes;
  bool _isLoadingArt = true;

  @override
  void initState() {
    super.initState();
    _loadArtwork();
    // Auto-select current line
    try {
      if (Get.isRegistered<AudioController>()) {
        final currentIdx = Get.find<AudioController>().currentLyricIndex.value;
        if (currentIdx != -1 && currentIdx < widget.lyrics.length) {
          _selectedIndices.add(currentIdx);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadArtwork() async {
    final OnAudioQuery audioQuery = OnAudioQuery();
    try {
      final bytes = await audioQuery.queryArtwork(
        widget.song.id,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 1000,
        quality: 100,
      );
      if (mounted) {
        setState(() {
          _artworkBytes = bytes;
          _isLoadingArt = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingArt = false);
    }
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        if (_selectedIndices.length < _maxLines) {
          _selectedIndices.add(index);
        } else {}
      }
    });
  }

  Future<void> _shareCard() async {
    try {
      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/wavvy_lyric_card.png';

      final imageBytes = await _screenshotController.capture(pixelRatio: 3.0);

      if (imageBytes != null) {
        final file = File(imagePath);
        await file.writeAsBytes(imageBytes);

        await Share.shareXFiles([
          XFile(file.path),
        ], text: 'Listening to ${widget.song.title} on Wavvy 🎵');
      }
    } catch (e) {
      AppSnackbar.showErrorSnackBar("Error sharing", "$e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final sortedIndices = _selectedIndices.toList()..sort();
    final selectedLyrics = sortedIndices.map((i) => widget.lyrics[i]).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: FilledButton.icon(
              onPressed: sortedIndices.isEmpty ? null : _shareCard,
              icon: const Icon(Icons.ios_share, size: 18),
              label: const Text("Share"),
              style: FilledButton.styleFrom(
                backgroundColor: widget.themeColor,
                foregroundColor: widget.themeColor.computeLuminance() > 0.5
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- PREVIEW AREA ---
          Expanded(
            flex: 6,
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 16,
                  ),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: _buildCard(selectedLyrics),
                  ),
                ),
              ),
            ),
          ),

          // --- SELECTION AREA ---
          Expanded(
            flex: 4,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Select Lyrics",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${_selectedIndices.length}/$_maxLines lines",
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: widget.lyrics.length,
                      itemBuilder: (context, index) {
                        final line = widget.lyrics[index];
                        final isSelected = _selectedIndices.contains(index);

                        return GestureDetector(
                          onTap: () => _toggleSelection(index),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? widget.themeColor.withValues(alpha: 0.2)
                                  : Colors.black26,
                              border: Border.all(
                                color: isSelected
                                    ? widget.themeColor
                                    : Colors.transparent,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    line.text,
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[400],
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: widget.themeColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- THE ACTUAL CARD DESIGN ---
  Widget _buildCard(List<Lyric> lines) {
    return AspectRatio(
      aspectRatio: 4 / 5, // Standard Social Media Portrait
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: Colors.grey[900],
          image: _artworkBytes != null
              ? DecorationImage(
                  image: MemoryImage(_artworkBytes!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                child: Container(color: Colors.black.withValues(alpha: 0.3)),
              ),

              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.2),
                      Colors.black.withValues(alpha: 0.4),
                      Colors.black.withValues(alpha: 0.8),
                    ],
                  ),
                ),
              ),

              // 3. Content
              Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Artwork Thumb (Clean Shadow)
                    if (_artworkBytes != null)
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black45,
                              blurRadius: 20,
                              offset: Offset(0, 8),
                            ),
                          ],
                          image: DecorationImage(
                            image: MemoryImage(_artworkBytes!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Lyrics
                    if (lines.isEmpty)
                      Text(
                        "Tap lyrics below to preview",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 16,
                          fontWeight: FontWeight.w300,
                        ),
                      )
                    else
                      ...lines.map(
                        (l) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Text(
                            l.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              height: 1.2,
                              letterSpacing: -0.5,
                              shadows: [
                                Shadow(
                                  color: Colors.black87,
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    const Spacer(),

                    // Footer / Brand Tag
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.music_note_rounded,
                            color: widget.themeColor,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "${widget.song.title} • ${widget.song.artist}",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Wavvy",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.3),
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
