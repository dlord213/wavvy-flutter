import 'package:flutter/material.dart' hide AppBar;
import 'package:flutter/services.dart';
import 'package:flutter_appbar/flutter_appbar.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/downloader/downloader.screen.dart';
import 'package:wavvy/screens/home/home.controller.dart';
import 'package:wavvy/screens/home/view/library_view.dart';
import 'package:wavvy/screens/home/widgets/songs_header_app_bar.dart';
import 'package:wavvy/service/settings.service.dart';
import 'package:wavvy/widgets/bottom_bar.dart';
import 'package:wavvy/screens/home/view/songs_view.dart';
import 'package:wavvy/widgets/floating_app_bar.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsService _settings = Get.find();

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
                      if (_settings.showStats.value)
                        AppBar(
                          behavior: const MaterialAppBarBehavior(
                            dragOnlyExpanding: true,
                          ),
                          body: SongsHeaderAppBar(),
                        ),
                      AppBar(
                        behavior: const MaterialAppBarBehavior(floating: true),
                        body: FloatingAppBar(
                          showSearch: true,
                          title: "Wavvy",
                          actions: [
                            IconButton(
                              onPressed: () => Get.toNamed("/settings"),
                              icon: Icon(Icons.settings_rounded),
                            ),
                          ],
                        ),
                      ),
                    ],
                    child: SongsView(),
                  ),
                  AppBarConnection(
                    appBars: [
                      AppBar(
                        behavior: const MaterialAppBarBehavior(floating: true),
                        body: FloatingAppBar(
                          showSearch: true,
                          title: "Library",
                        ),
                      ),
                    ],
                    child: LibraryView(),
                  ),
                  AppBarConnection(
                    appBars: [
                      AppBar(
                        behavior: const MaterialAppBarBehavior(floating: true),
                        body: FloatingAppBar(
                          showSearch: true,
                          title: "Downloader",
                        ),
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
