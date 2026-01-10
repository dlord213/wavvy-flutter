import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:audio_service/audio_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wavvy/db/db.dart';
import 'package:wavvy/instances/audio_handler.instance.dart';
import 'package:wavvy/models/lyric.dart';
import 'package:wavvy/utils/player.utils.dart';
import 'package:wavvy/utils/snackbar.utils.dart';

enum SortOption { titleAZ, titleZA, dateNewest, dateOldest, artistAZ }

class AudioController extends GetxController {
  // --- Dependencies ---
  final AudioHandler _audioHandler = Get.find<AudioHandler>();
  final OnAudioQuery audioQuery = OnAudioQuery();
  final DbHelper _dbHelper = DbHelper();

  AudioPlayer get audioPlayer => (_audioHandler as WavvyAudioHandler).player;
  AndroidLoudnessEnhancer get enhancer =>
      (_audioHandler as WavvyAudioHandler).enhancer;

  // --- Workers (For proper disposal) ---
  final List<Worker> _workers = [];

  // --- Reactive Lists ---
  final RxList<SongModel> songs = <SongModel>[].obs;
  final RxList<SongModel> filteredSongs = <SongModel>[].obs;
  final RxList<SongModel> queue = <SongModel>[].obs;

  final RxList<AlbumModel> albums = <AlbumModel>[].obs;
  final RxList<ArtistModel> artists = <ArtistModel>[].obs;
  final Rx<SortOption> currentSort = SortOption.titleAZ.obs;

  final RxList<Map<String, dynamic>> localPlaylists =
      <Map<String, dynamic>>[].obs;

  // --- Smart Playlists State ---
  final RxList<SongModel> mostPlayedSongs = <SongModel>[].obs;
  final RxList<SongModel> recentSongs = <SongModel>[].obs;

  // Internal flag to prevent double counting the same song session
  int? _lastLoggedSongId;

  // --- Player State ---
  final Rxn<SongModel> currentSong = Rxn<SongModel>();
  final RxInt currentIndex = (-1).obs;
  final RxBool isPlaying = false.obs;
  final RxBool isShuffleModeEnabled = false.obs;
  final Rx<LoopMode> loopMode = LoopMode.off.obs;
  final Rxn<int> sleepTimerMinutes = Rxn<int>();
  Timer? _sleepTimer;

  // OPTIMIZATION: value changes here happen 60fps, ensure listeners are efficient
  final Rx<Duration> currentPosition = Duration.zero.obs;
  final Rx<Duration> totalDuration = Duration.zero.obs;

  // --- UI/Theme State ---
  final Rx<Color?> playerColor = Rx<Color?>(null);
  final Rx<Color> playerTextColor = Colors.white.obs;

  // --- Genius API / Sheet State ---
  final RxString artistBio = "".obs;
  final RxString artistImageUrl = "".obs;
  final RxBool isArtistLoading = false.obs;

  final String _geniusAccessToken =
      dotenv.env['GENIUS_ACCESS_TOKEN'].toString() ?? "";

  // --- LYRICS STATE ---
  final RxList<Lyric> lyrics = <Lyric>[].obs;
  final RxInt currentLyricIndex = (-1).obs;
  final RxBool isLyricsLoading = false.obs;
  final RxString lyricsError = "".obs;

  // --- UI Lyric State ---
  final ItemScrollController lyricsScrollController = ItemScrollController();
  final ItemPositionsListener lyricsPositionListener =
      ItemPositionsListener.create();

  // --- Internal Player Reference ---
  // ignore: deprecated_member_use
  ConcatenatingAudioSource? _effectivePlaylist;

  @override
  void onInit() {
    super.onInit();

    _dbHelper.initStatsTable().then((_) => refreshSmartPlaylists());

    _setupPlayerListeners();
    refreshLocalPlaylists();
    refreshSmartPlaylists();

    // Filter Songs
    _workers.add(ever(songs, (_) => filteredSongs.assignAll(songs)));

    _workers.add(
      interval(currentPosition, (position) {
        if (currentSong.value != null &&
            position.inSeconds > 30 &&
            _lastLoggedSongId != currentSong.value!.id) {
          _logCurrentSongPlay();
        }
      }, time: const Duration(milliseconds: 1000)),
    );

    // Song Change Listener (Debounced)
    // Prevents API spam and heavy palette generation when skipping tracks quickly
    _workers.add(
      debounce(currentSong, (song) {
        if (song != null) {
          _updatePalette(song.id);
          _updateArtistInfo();

          final int durationSeconds = (song.duration ?? 0) ~/ 1000;

          fetchLyrics(
            trackName: song.title,
            artistName: song.artist ?? "",
            albumName: song.album ?? "",
            duration: durationSeconds,
          );
        } else {
          playerColor.value = null;
          lyrics.clear();
        }
      }, time: const Duration(milliseconds: 300)),
    );

    // Sorting
    _workers.add(ever(currentSort, (_) => _applySort()));

    // Lyric Syncing (Interval)
    // Limits checks to every 200ms instead of every frame
    _workers.add(
      interval(currentPosition, (duration) {
        if (lyrics.isNotEmpty) _syncLyrics(duration);
      }, time: const Duration(milliseconds: 200)),
    );

    // Lyric Auto-Scroll
    _workers.add(
      ever(currentLyricIndex, (index) {
        if (index >= 0 &&
            !isLyricsLoading.value &&
            lyricsScrollController.isAttached) {
          lyricsScrollController.scrollTo(
            index: index,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeInOutCubic,
            alignment: 0.5,
          );
        }
      }),
    );
  }

  @override
  void onReady() {
    super.onReady();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchAllSongs());
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }

  // =========================================================
  // ACTIONS
  // =========================================================

  Future<void> openEqualizer() async {
    if (Platform.isAndroid) {
      try {
        final intent = AndroidIntent(
          action: 'android.media.action.DISPLAY_AUDIO_EFFECT_CONTROL_PANEL',
          flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
          arguments: {
            'android.media.extra.AUDIO_SESSION':
                audioPlayer.androidAudioSessionId,
          },
        );
        await intent.launch();
      } catch (e) {
        AppSnackbar.showErrorSnackBar(
          "Error",
          "No equalizer found on this device",
        );
      }
    }
  }

  Future<void> deleteSong(SongModel song) async {
    try {
      final file = File(song.data);
      if (await file.exists()) {
        await file.delete();

        songs.removeWhere((s) => s.id == song.id);
        queue.removeWhere((s) => s.id == song.id);
        filteredSongs.removeWhere((s) => s.id == song.id);

        if (currentSong.value?.id == song.id) {
          if (audioPlayer.hasNext) next();
        }

        Get.back();
        AppSnackbar.showSnackbar(
          "Deleted",
          "${song.title} removed from device.",
        );
      }
    } catch (e) {
      print("Delete error: $e");
      AppSnackbar.showErrorSnackBar(
        "Permission Denied",
        "Cannot delete file on this Android version.",
      );
    }
  }

  String getSongInfo(SongModel song) {
    return """
Title: ${song.title}
Artist: ${song.artist ?? '<unknown>'}
Album: ${song.album ?? '<unknown>'}
Duration: ${PlayerUtils.formatDuration(Duration(milliseconds: song.duration ?? 0))}
Size: ${PlayerUtils.formatBytes(song.size, 2)}
Path: ${song.data}
Format: ${song.fileExtension}
    """;
  }

  void toggleVolumeBoost() {
    if (enhancer.targetGain == 1.0) {
      enhancer.setTargetGain(12.0);
    } else {
      enhancer.setTargetGain(1.0);
    }

    print("DEBUG: ${enhancer.targetGain}");
  }

  // =========================================================
  // DATA FETCHING
  // =========================================================

  Future<void> fetchAllSongs() async {
    if (!await _checkAndRequestPermissions()) return;

    try {
      final results = await Future.wait([
        audioQuery.querySongs(
          ignoreCase: true,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          sortType: SongSortType.TITLE,
        ),
        audioQuery.queryAlbums(),
        audioQuery.queryArtists(),
      ]);

      final songResult = results[0] as List<SongModel>;
      final albumResult = results[1] as List<AlbumModel>;
      final artistResult = results[2] as List<ArtistModel>;

      // Filter invalid songs
      final validSongs = songResult.where((s) => s.isMusic == true).toList();

      songs.assignAll(validSongs);
      albums.assignAll(albumResult);
      artists.assignAll(artistResult);

      _applySort();
    } catch (e) {
      print("Error fetching library: $e");
    }
  }

  void _applySort() {
    final List<SongModel> sortedList = List.from(songs);

    switch (currentSort.value) {
      case SortOption.titleAZ:
        sortedList.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.titleZA:
        sortedList.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.dateNewest:
        sortedList.sort(
          (a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0),
        );
        break;
      case SortOption.dateOldest:
        sortedList.sort(
          (a, b) => (a.dateAdded ?? 0).compareTo(b.dateAdded ?? 0),
        );
        break;
      case SortOption.artistAZ:
        sortedList.sort((a, b) => (a.artist ?? "").compareTo(b.artist ?? ""));
        break;
    }

    songs.assignAll(sortedList);
    albums.refresh();
    artists.refresh();
  }

  void changeSortOption(SortOption option) {
    currentSort.value = option;
  }

  // =========================================================
  // LYRICS & GENIUS
  // =========================================================

  Future<void> fetchLyrics({
    required String trackName,
    required String artistName,
    required String albumName,
    required int duration,
  }) async {
    try {
      isLyricsLoading.value = true;
      lyricsError.value = "";
      lyrics.clear();
      currentLyricIndex.value = -1;

      final queryParameters = {
        'track_name': trackName,
        'artist_name': artistName,
        'album_name': albumName,
        'duration': duration.toString(),
      };

      final uri = Uri.https('lrclib.net', '/api/get', queryParameters);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final String? syncedLyrics = data['syncedLyrics'];
        final String? plainLyrics = data['plainLyrics'];

        if (syncedLyrics != null && syncedLyrics.isNotEmpty) {
          _parseLrc(syncedLyrics);
        } else if (plainLyrics != null && plainLyrics.isNotEmpty) {
          lyrics.add(Lyric(Duration.zero, plainLyrics));
        } else {
          lyricsError.value = "No lyrics found.";
        }
      } else if (response.statusCode == 404) {
        lyricsError.value = "Lyrics not found.";
      } else {
        lyricsError.value = "Error: ${response.statusCode}";
      }
    } catch (e) {
      lyricsError.value = "Network error.";
      lyrics.clear();
    } finally {
      isLyricsLoading.value = false;
    }
  }

  void _parseLrc(String lrc) {
    final parsedLyrics = PlayerUtils.parseLrc(lrc);
    lyrics.assignAll(parsedLyrics);
  }

  void _syncLyrics(Duration currentPos) {
    int newIndex = -1;
    final int startIndex = currentLyricIndex.value < 0
        ? 0
        : currentLyricIndex.value;

    for (int i = startIndex; i < lyrics.length; i++) {
      if (lyrics[i].time <= currentPos) {
        newIndex = i;
      } else {
        break;
      }
    }

    // If seeking backwards, fallback to full search
    if (newIndex == -1 ||
        (newIndex == startIndex && lyrics[startIndex].time > currentPos)) {
      for (int i = 0; i < lyrics.length; i++) {
        if (lyrics[i].time <= currentPos) {
          newIndex = i;
        } else {
          break;
        }
      }
    }

    if (newIndex != currentLyricIndex.value) {
      currentLyricIndex.value = newIndex;
    }
  }

  void _updateArtistInfo() {
    if (currentSong.value?.artist == "<unknown>") {
      isArtistLoading.value = false;
      artistBio.value = "";
      artistImageUrl.value = "";
      return;
    }

    if (currentSong.value?.artist != null) {
      fetchArtistInfo(currentSong.value!.artist!);
    }
  }

  Future<void> fetchArtistInfo(String artistName) async {
    if (_geniusAccessToken == 'YOUR_GENIUS_ACCESS_TOKEN_HERE') {
      artistBio.value = "Please add Token.";
      return;
    }

    try {
      isArtistLoading.value = true;
      artistBio.value = "";
      artistImageUrl.value = "";

      final searchUrl = Uri.parse(
        'https://api.genius.com/search?q=${Uri.encodeComponent(artistName)}',
      );
      final searchResponse = await http.get(
        searchUrl,
        headers: {'Authorization': 'Bearer $_geniusAccessToken'},
      );

      if (searchResponse.statusCode == 200) {
        final searchData = jsonDecode(searchResponse.body);
        final hits = searchData['response']['hits'] as List;

        if (hits.isNotEmpty) {
          final artistId = hits[0]['result']['primary_artist']['id'];
          final artistUrl = Uri.parse(
            'https://api.genius.com/artists/$artistId',
          );

          final artistResponse = await http.get(
            artistUrl,
            headers: {'Authorization': 'Bearer $_geniusAccessToken'},
          );

          if (artistResponse.statusCode == 200) {
            final artistData = jsonDecode(artistResponse.body);
            final artist = artistData['response']['artist'];
            final description = artist['description'];

            // Extract plain text or fallback to DOM parsing
            String bio = description['plain'] ?? "";
            if (bio.trim().isEmpty && description['dom'] != null) {
              bio = PlayerUtils.extractTextFromDom(description['dom']);
            }

            artistBio.value = bio.trim().isNotEmpty ? bio : "No bio available.";
            artistImageUrl.value = artist['image_url'] ?? "";
          }
        } else {
          artistBio.value = "Artist not found on Genius.";
        }
      }
    } catch (e) {
      artistBio.value = "Error: $e";
    } finally {
      isArtistLoading.value = false;
    }
  }

  // =========================================================
  // PLAYBACK & QUEUE LOGIC
  // =========================================================

  Future<void> playSong(SongModel song, {List<SongModel>? contextList}) async {
    try {
      final List<SongModel> newQueue = contextList ?? List.from(filteredSongs);
      final index = newQueue.indexWhere((s) => s.id == song.id);

      if (index == -1) return;

      queue.assignAll(newQueue);

      final sources = newQueue.map((s) => _createAudioSource(s)).toList();
      // ignore: deprecated_member_use
      _effectivePlaylist = ConcatenatingAudioSource(children: sources);

      await audioPlayer.setAudioSource(
        _effectivePlaylist!,
        initialIndex: index,
      );
      audioPlayer.play();
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  Future<void> addToQueue(SongModel song) async {
    if (_effectivePlaylist == null) {
      playSong(song, contextList: [song]);
      return;
    }
    queue.add(song);
    await _effectivePlaylist!.add(_createAudioSource(song));

    AppSnackbar.showSnackbar("Added to Queue", song.title);
  }

  Future<void> playNext(SongModel song) async {
    if (_effectivePlaylist == null || currentIndex.value == -1) {
      playSong(song, contextList: [song]);
      return;
    }

    final insertIndex = currentIndex.value + 1;
    queue.insert(insertIndex, song);
    await _effectivePlaylist!.insert(insertIndex, _createAudioSource(song));

    AppSnackbar.showSnackbar("Will play next", song.title);
  }

  AudioSource _createAudioSource(SongModel song) {
    return AudioSource.uri(Uri.parse(song.uri!), tag: song);
  }

  // =========================================================
  // CONTROLS
  // =========================================================

  void togglePlay() =>
      isPlaying.value ? audioPlayer.pause() : audioPlayer.play();
  void next() => audioPlayer.hasNext ? audioPlayer.seekToNext() : null;
  void previous() =>
      audioPlayer.hasPrevious ? audioPlayer.seekToPrevious() : null;
  void seek(Duration pos) => audioPlayer.seek(pos);

  void toggleShuffle() async {
    final enable = !isShuffleModeEnabled.value;
    await audioPlayer.setShuffleModeEnabled(enable);
    isShuffleModeEnabled.value = enable;
  }

  void cycleLoopMode() async {
    switch (loopMode.value) {
      case LoopMode.off:
        await audioPlayer.setLoopMode(LoopMode.all);
        break;
      case LoopMode.all:
        await audioPlayer.setLoopMode(LoopMode.one);
        break;
      case LoopMode.one:
        await audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
    loopMode.value = audioPlayer.loopMode;
  }

  // =========================================================
  // LISTENERS & HELPERS
  // =========================================================

  void _setupPlayerListeners() {
    audioPlayer.playerStateStream.listen((state) {
      if (isPlaying.value != state.playing) isPlaying.value = state.playing;
    });

    audioPlayer.positionStream.listen((p) => currentPosition.value = p);
    audioPlayer.durationStream.listen(
      (d) => totalDuration.value = d ?? Duration.zero,
    );

    audioPlayer.sequenceStateStream.listen((state) {
      if (state.currentSource != null) {
        final song = state.currentSource!.tag as SongModel;

        if (currentSong.value?.id != song.id) {
          currentSong.value = song;
        }

        if (currentIndex.value != state.currentIndex) {
          currentIndex.value = state.currentIndex!;
        }

        isShuffleModeEnabled.value = state.shuffleModeEnabled;
        loopMode.value = state.loopMode;
      }
    });
  }

  Future<void> _updatePalette(int songId) async {
    try {
      final Uint8List? bytes = await audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        format: ArtworkFormat.JPEG,
        size: 512,
      );

      if (bytes == null) {
        playerColor.value = Colors.grey;
        playerTextColor.value = Colors.white;
        return;
      }

      final PaletteGenerator palette = await PaletteGenerator.fromImageProvider(
        MemoryImage(bytes),
        maximumColorCount: 8,
      );

      final Color? extractedColor =
          palette.dominantColor?.color ??
          palette.darkMutedColor?.color ??
          palette.vibrantColor?.color;

      if (extractedColor != null) {
        playerColor.value = extractedColor;
        playerTextColor.value = extractedColor.computeLuminance() > 0.5
            ? Colors.black
            : Colors.white;
      } else {
        playerColor.value = null;
      }
    } catch (e) {
      playerColor.value = null;
    }
  }

  Future<bool> _checkAndRequestPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidInfo = await DeviceInfoPlugin().androidInfo;

    // --- 1. Request Notification Permission (Android 13+ / SDK 33+) ---
    // Essential for media controls in the notification bar
    if (androidInfo.version.sdkInt >= 33) {
      if (!(await Permission.notification.isGranted)) {
        await Permission.notification.request();
      }
    }

    // --- 2. Request Storage / Tag Editing Permissions ---

    // Android 11+ (SDK 30+) requires special "All Files Access" to edit tags
    if (androidInfo.version.sdkInt >= 30) {
      var status = await Permission.manageExternalStorage.status;

      if (!status.isGranted) {
        final result = await Permission.manageExternalStorage.request();
        return result.isGranted;
      }
      return true;
    }

    // Android 10 and below
    if (androidInfo.version.sdkInt >= 29) {
      return (await Permission.storage.request()).isGranted;
    }

    // Older Android
    return (await Permission.storage.request()).isGranted;
  }

  // =========================================================
  // PLAYLISTS
  // =========================================================

  Future<void> createLocalPlaylist(String name) async {
    final db = await _dbHelper.db;
    await db.insert('playlists', {
      'name': name,
      'created_at': DateTime.now().toIso8601String(),
    });
    refreshLocalPlaylists();
  }

  Future<void> refreshLocalPlaylists() async {
    final db = await _dbHelper.db;
    final List<Map<String, dynamic>> maps = await db.query('playlists');
    localPlaylists.assignAll(maps);
  }

  Future<void> addSongToLocalPlaylist(int playlistId, int songId) async {
    final db = await _dbHelper.db;
    // Check if song already exists in this playlist to avoid duplicates
    final existing = await db.query(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );

    if (existing.isEmpty) {
      await db.insert('playlist_songs', {
        'playlist_id': playlistId,
        'song_id': songId,
      });

      AppSnackbar.showSnackbar("Success", "Added to your playlist");
    } else {
      AppSnackbar.showSnackbar("Notice", "Song is already in this playlist");
    }
  }

  // Fetch songs for a specific playlist
  Future<List<SongModel>> getSongsInPlaylist(int playlistId) async {
    final db = await _dbHelper.db;
    final List<Map<String, dynamic>> results = await db.query(
      'playlist_songs',
      where: 'playlist_id = ?',
      whereArgs: [playlistId],
    );

    List<int> songIds = results.map((e) => e['song_id'] as int).toList();
    // Match the IDs with your loaded songs list
    return songs.where((s) => songIds.contains(s.id)).toList();
  }

  Future<void> removeFromLocalPlaylist(int playlistId, int songId) async {
    final db = await _dbHelper.db;
    await db.delete(
      'playlist_songs',
      where: 'playlist_id = ? AND song_id = ?',
      whereArgs: [playlistId, songId],
    );
    // Trigger UI refresh if you are observing the list
    update();
  }

  // =========================================================
  // METADATA/TAGS (Using metadata_god)
  // =========================================================
  Future<void> editSongTags(SongModel song) async {
    // 1. Setup Controllers with basic data from SongModel first
    final titleCtrl = TextEditingController(text: song.title);
    final artistCtrl = TextEditingController(text: song.artist ?? "");
    final albumCtrl = TextEditingController(text: song.album ?? "");
    final yearCtrl = TextEditingController(text: "");
    final genreCtrl = TextEditingController(text: "");

    // 2. Fetch deep metadata using MetadataGod
    //    (SongModel is fast but limited; MetadataGod reads the file headers)
    try {
      final metadata = await MetadataGod.readMetadata(file: song.data);
      if (metadata != null) {
        // Create a fallback helper
        String getVal(String? val, String fallback) =>
            (val == null || val.isEmpty) ? fallback : val;

        // Update controllers if metadata has more info than MediaStore
        titleCtrl.text = getVal(metadata.title, titleCtrl.text);
        artistCtrl.text = getVal(metadata.artist, artistCtrl.text);
        albumCtrl.text = getVal(metadata.album, albumCtrl.text);

        // Specific fields only available here
        yearCtrl.text = metadata.year?.toString() ?? "";
        genreCtrl.text = metadata.genre ?? "";
      }
    } catch (e) {
      print("Error reading tags: $e");
    }

    // 3. Show Dialog
    await Get.dialog(
      AlertDialog(
        backgroundColor: playerColor.value ?? Colors.grey[900],
        title: Text(
          "Edit Tags",
          style: TextStyle(color: playerTextColor.value),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTagField("Title", titleCtrl),
              _buildTagField("Artist", artistCtrl),
              _buildTagField("Album", albumCtrl),
              _buildTagField("Year", yearCtrl, isNumber: true),
              _buildTagField("Genre", genreCtrl),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: playerTextColor.value),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: playerTextColor.value,
              foregroundColor: playerColor.value,
            ),
            onPressed: () async {
              Get.back(); // Close dialog
              await _saveTags(
                song: song,
                title: titleCtrl.text,
                artist: artistCtrl.text,
                album: albumCtrl.text,
                year: yearCtrl.text,
                genre: genreCtrl.text,
              );
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  Widget _buildTagField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: TextStyle(color: playerTextColor.value),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: playerTextColor.value.withOpacity(0.7)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              color: playerTextColor.value.withOpacity(0.5),
            ),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: playerTextColor.value),
          ),
        ),
      ),
    );
  }

  Future<void> _saveTags({
    required SongModel song,
    required String title,
    required String artist,
    required String album,
    required String year,
    required String genre,
  }) async {
    try {
      Get.showSnackbar(
        GetSnackBar(
          message: "Saving metadata...",
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.grey[800]!,
        ),
      );

      // 1. Read existing metadata to preserve artwork and other fields
      Metadata? currentMetadata;
      try {
        currentMetadata = await MetadataGod.readMetadata(file: song.data);
      } catch (e) {
        print("Could not read existing metadata: $e");
      }

      // 2. Prepare new Metadata object
      //    We copy existing picture/track info so they aren't lost
      final newMetadata = Metadata(
        title: title,
        artist: artist,
        album: album,
        year: int.tryParse(year),
        genre: genre,
        // Preserve these fields from the old metadata:
        picture: currentMetadata?.picture,
        trackNumber: currentMetadata?.trackNumber,
        discNumber: currentMetadata?.discNumber,
        albumArtist: currentMetadata?.albumArtist,
        durationMs: currentMetadata?.durationMs,
      );

      // 3. Write to file
      await MetadataGod.writeMetadata(file: song.data, metadata: newMetadata);

      // 4. Refresh Library
      await fetchAllSongs();

      if (currentSong.value?.id == song.id) {
        try {
          final updatedSong = songs.firstWhere((s) => s.id == song.id);
          currentSong.value = updatedSong;
        } catch (e) {}
      }

      AppSnackbar.showSnackbar("Success", "Tags updated successfully");
    } catch (e) {
      print("Tag Edit Error: $e");

      AppSnackbar.showErrorSnackBar(
        "Error",
        "Could not write tags. Permission denied or file read-only.",
      );
    }
  }

  // =========================================================
  // EXTRAS
  // =========================================================

  void setSleepTimer(int? minutes) {
    _sleepTimer?.cancel();

    if (minutes == null) {
      sleepTimerMinutes.value = null;

      AppSnackbar.showSnackbar("Sleep Timer", "Timer cancelled");
      return;
    }

    sleepTimerMinutes.value = minutes;

    AppSnackbar.showSnackbar(
      "Sleep Timer",
      "Music will stop in $minutes minutes",
    );

    _sleepTimer = Timer(Duration(minutes: minutes), () {
      audioPlayer.pause();
      sleepTimerMinutes.value = null;
    });
  }

  void openSleepTimerDialog() {
    Get.dialog(
      AlertDialog(
        backgroundColor: playerColor.value ?? Colors.grey[900],
        title: Text(
          "Sleep Timer",
          style: TextStyle(color: playerTextColor.value),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...[15, 30, 45, 60, 90].map((minutes) {
              return ListTile(
                title: Text(
                  "$minutes minutes",
                  style: TextStyle(color: playerTextColor.value),
                ),
                trailing: sleepTimerMinutes.value == minutes
                    ? Icon(Icons.check, color: playerTextColor.value)
                    : null,
                onTap: () {
                  Get.back();
                  setSleepTimer(minutes);
                },
              );
            }),

            Divider(color: playerTextColor.value.withValues(alpha: 0.3)),

            ListTile(
              title: Text(
                "Turn Off Timer",
                style: TextStyle(
                  color: playerTextColor.value.withValues(alpha: 0.7),
                ),
              ),
              leading: Icon(
                Icons.timer_off_outlined,
                color: playerTextColor.value.withValues(alpha: 0.7),
              ),
              onTap: () {
                Get.back();
                setSleepTimer(null);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "Cancel",
              style: TextStyle(color: playerTextColor.value),
            ),
          ),
        ],
      ),
    );
  }

  void _logCurrentSongPlay() async {
    if (currentSong.value == null) return;

    final id = currentSong.value!.id;
    _lastLoggedSongId = id; // Mark as logged for this session

    await _dbHelper.logSongPlay(id);
    refreshSmartPlaylists(); // Update UI immediately
  }

  Future<void> refreshSmartPlaylists() async {
    final mostPlayedMaps = await _dbHelper.getMostPlayed(20);
    final recentMaps = await _dbHelper.getRecentlyPlayed(20);

    final songMap = {for (var s in songs) s.id: s};

    List<SongModel> tempMostPlayed = [];
    for (var map in mostPlayedMaps) {
      final song = songMap[map['song_id']];
      if (song != null) tempMostPlayed.add(song);
    }

    List<SongModel> tempRecent = [];
    for (var map in recentMaps) {
      final song = songMap[map['song_id']];
      if (song != null) tempRecent.add(song);
    }

    mostPlayedSongs.assignAll(tempMostPlayed);
    recentSongs.assignAll(tempRecent);
  }
}
