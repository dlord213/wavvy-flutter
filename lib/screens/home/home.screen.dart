import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/downloader/downloader.screen.dart';
import 'package:wavvy/screens/home/home.controller.dart';
import 'package:wavvy/screens/home/widgets/downloader_app_bar.dart';
import 'package:wavvy/screens/home/widgets/library_app_bar.dart';
import 'package:wavvy/screens/home/view/library_view.dart';
import 'package:wavvy/screens/home/widgets/songs_app_bar.dart';
import 'package:wavvy/screens/downloader/youtube/ytdlp.screen.dart';
import 'package:wavvy/screens/home/widgets/songs_header_app_bar.dart';
import 'package:wavvy/widgets/bottom_bar.dart';
import 'package:wavvy/screens/home/view/songs_view.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final backgroundColor = controller.getBgColor(context);
      final navBarColor = controller.getNavbarColor(context);

      final Brightness iconBrightness =
          ThemeData.estimateBrightnessForColor(navBarColor) == Brightness.dark
          ? Brightness.light
          : Brightness.dark;

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: navBarColor,
          systemNavigationBarIconBrightness: iconBrightness,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: context.isDarkMode
              ? Brightness.light
              : Brightness.dark,
        ),
        child: DefaultTabController(
          length: 3,
          child: Scaffold(
            backgroundColor: backgroundColor,
            bottomNavigationBar: BottomMiniPlayer(),
            body: SafeArea(
              child: TabBarView(
                children: [
                  AppBarConnection(
                    appBars: [
                      AppBar(
                        behavior: const MaterialAppBarBehavior(
                          dragOnlyExpanding: true,
                        ),
                        body: SongsHeaderAppBar(),
                      ),
                      AppBar(
                        behavior: const MaterialAppBarBehavior(floating: true),
                        body: const SongsAppBar(),
                      ),
                    ],
                    child: SongsView(),
                  ),
                  AppBarConnection(
                    appBars: [
                      AppBar(
                        behavior: const MaterialAppBarBehavior(floating: true),
                        body: const LibraryAppBar(),
                      ),
                    ],
                    child: LibraryView(),
                  ),
                  AppBarConnection(
                    appBars: [
                      AppBar(
                        behavior: const MaterialAppBarBehavior(floating: true),
                        body: const DownloaderHubAppBar(),
                      ),
                    ],
                    child: DownloaderHubScreen(),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
