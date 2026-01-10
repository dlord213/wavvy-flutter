import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart'; // Needed for SongModel

class WavvyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final _enhancer = AndroidLoudnessEnhancer();
  final _equalizer = AndroidEqualizer();
  late AudioPipeline pipeline = AudioPipeline(
    androidAudioEffects: [_enhancer, _equalizer],
  );
  late final AudioPlayer _player = AudioPlayer(audioPipeline: pipeline);

  WavvyAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    _enhancer.setEnabled(true);
    _enhancer.setTargetGain(1.0);

    _equalizer.setEnabled(true);
    _player.setSkipSilenceEnabled(false);

    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(
        playbackState.value.copyWith(
          controls: [
            MediaControl.skipToPrevious,
            if (playing) MediaControl.pause else MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          systemActions: const {
            MediaAction.seek,
            MediaAction.seekForward,
            MediaAction.seekBackward,
          },
          androidCompactActionIndices: const [0, 1, 2],
          processingState: const {
            ProcessingState.idle: AudioProcessingState.idle,
            ProcessingState.loading: AudioProcessingState.loading,
            ProcessingState.buffering: AudioProcessingState.buffering,
            ProcessingState.ready: AudioProcessingState.ready,
            ProcessingState.completed: AudioProcessingState.completed,
          }[_player.processingState]!,
          playing: playing,
          updatePosition: _player.position,
          bufferedPosition: _player.bufferedPosition,
          speed: _player.speed,
          queueIndex: event.currentIndex,
        ),
      );
    });

    // Broadcast Current Song Metadata to System Notification
    _player.sequenceStateStream.listen((state) {
      if (state.currentSource == null) return;

      final song = state.currentSource!.tag as SongModel;
      Uri? artUri;
      if (song.albumId != null) {
        artUri = Uri.parse(
          "content://media/external/audio/albumart/${song.albumId}",
        );
      }

      mediaItem.add(
        MediaItem(
          id: song.id.toString(),
          album: song.album ?? "Unknown Album",
          title: song.title,
          artist: song.artist ?? "Unknown Artist",
          duration: Duration(milliseconds: song.duration ?? 0),
          artUri: artUri,
        ),
      );
    });
  }

  AudioPlayer get player => _player;
  AndroidLoudnessEnhancer get enhancer => _enhancer;

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() => _player.stop();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();
}
