import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wavvy/instances/audio_handler.instance.dart';
import 'package:wavvy/screens/audio.controller.dart';
import 'package:wavvy/screens/home/home.controller.dart';
import 'package:wavvy/screens/home/home.screen.dart';
import 'package:wavvy/player_sheets/full_player_sheet.controller.dart';
import 'package:wavvy/screens/library/albums/albums.controller.dart';
import 'package:wavvy/screens/library/albums/albums.screen.dart';
import 'package:wavvy/screens/library/artists/artists.controller.dart';
import 'package:wavvy/screens/library/artists/artists.screen.dart';
import 'package:wavvy/screens/search/search.controller.dart';
import 'package:wavvy/screens/search/search.screen.dart';
import 'package:wavvy/screens/setup/setup.controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    Get.put(SetupController());
    Get.put(HomeController());
    Get.put(AlbumController());
    Get.put(ArtistController());
    Get.put(FullPlayerSheetController());
    Get.put(SearchPageController());
  }
}

class MyApp extends StatefulWidget {
  MyApp({super.key});

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
          },
          initialBinding: InitialBinding(),
        );
      },
    );
  }
}
