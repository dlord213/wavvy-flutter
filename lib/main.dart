import 'dart:isolate';
import 'dart:ui';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:wavvy/instances/audio_handler.instance.dart';
import 'package:wavvy/screens/audio.controller.dart';
import 'package:wavvy/screens/downloader/downloader.screen.dart';
import 'package:wavvy/screens/downloader/tiktok/tiktok.controller.dart';
import 'package:wavvy/screens/downloader/youtube/ytdlp.controller.dart';
import 'package:wavvy/screens/home/home.controller.dart';
import 'package:wavvy/screens/home/home.screen.dart';
import 'package:wavvy/player_sheets/full_player_sheet.controller.dart';
import 'package:wavvy/screens/library/albums/albums.controller.dart';
import 'package:wavvy/screens/library/albums/albums.screen.dart';
import 'package:wavvy/screens/library/artists/artists.controller.dart';
import 'package:wavvy/screens/library/artists/artists.screen.dart';
import 'package:wavvy/screens/library/playlists/playlists.controller.dart';
import 'package:wavvy/screens/library/playlists/playlists.screen.dart';
import 'package:wavvy/screens/search/search.controller.dart';
import 'package:wavvy/screens/search/search.screen.dart';
import 'package:wavvy/screens/setup/setup.controller.dart';
import 'package:wavvy/service/downloader.service.dart';

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName(
    'downloader_send_port',
  );

  if (send != null) {
    send.send([id, status, progress]);
  } else {
    print("DownloadCallback: SendPort not found");
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await FlutterDownloader.initialize(debug: kDebugMode);
  await FlutterDownloader.registerCallback(downloadCallback);
  await MetadataGod.initialize();

  Get.put(DownloadService());

  try {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());

    final audioHandler = await AudioService.init(
      builder: () => WavvyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.mirimomekiku.wavvy.channel.audio',
        androidNotificationChannelName: 'Wavvy Music',
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    Get.put<AudioHandler>(audioHandler, permanent: true);
  } catch (e) {
    print("INIT ERROR: $e");
  }

  runApp(MyApp());
}

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AudioController());
    Get.put(PlaylistsController());
    Get.put(YtdlpController());
    Get.put(TikTokController());
    Get.put(HomeController());
    Get.put(AlbumController());
    Get.put(ArtistController());
    Get.put(FullPlayerSheetController());
    Get.put(SearchPageController());
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future googleFontsPending;

  @override
  void initState() {
    super.initState();
    googleFontsPending = GoogleFonts.pendingFonts([]);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: googleFontsPending,
      builder: (context, asyncSnapshot) {
        return GetMaterialApp(
          title: 'Wavvy',
          debugShowCheckedModeBanner: false,
          theme: FlexThemeData.light(
            scheme: FlexScheme.sakura,
            useMaterial3: true,
            useMaterial3ErrorColors: true,
            textTheme: GoogleFonts.gabaritoTextTheme().copyWith(),
          ),
          darkTheme: FlexThemeData.dark(
            scheme: FlexScheme.mandyRed,
            useMaterial3: true,
            useMaterial3ErrorColors: true,
            textTheme: GoogleFonts.gabaritoTextTheme().copyWith(),
          ),
          themeMode: ThemeMode.system,
          home: HomeScreen(),
          routes: <String, WidgetBuilder>{
            "/home": (context) => HomeScreen(),
            "/search": (context) => SearchScreen(),
            "/albums": (context) => AllAlbumsScreen(),
            "/artists": (context) => AllArtistsScreen(),
            "/playlists": (context) => AllLocalPlaylistsScreen(),
            "/downloader": (context) => DownloaderHubScreen(),
          },
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}
