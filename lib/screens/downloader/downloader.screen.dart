import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:wavvy/screens/downloader/tiktok/tiktok.screen.dart';
import 'package:wavvy/screens/downloader/youtube/ytdlp.screen.dart';

class DownloaderHubScreen extends StatelessWidget {
  const DownloaderHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        children: [
          _buildNavTile(
            context,
            title: "YouTube Downloader",
            subtitle: "Search and download music/video",
            icon: Icons.play_circle_fill,
            color: Colors.red,
            onTap: () => Get.to(() => YtdlpSearchScreen()),
          ),
          _buildNavTile(
            context,
            title: "TikTok Downloader",
            subtitle: "Download without watermark",
            icon: Icons.music_note,
            color: Colors.red,
            onTap: () => Get.to(() => TikTokSearchScreen()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
