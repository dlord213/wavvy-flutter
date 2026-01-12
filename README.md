# Wavvy
***A modern, feature-rich offline music player for Android built with Flutter.***

Wavvy combines a beautiful, adaptive UI with powerful playback features, automatic metadata fetching, and an integrated downloader for YouTube and TikTok.

### Screenshots
| ![A descriptive alt text](./screenshots/home.jpg) | ![A descriptive alt text](./screenshots/library.jpg) | ![A descriptive alt text](./screenshots/sheet.jpg) |
| ------------------------------------------------- | ---------------------------------------------------- | -------------------------------------------------- |
| ![A descriptive alt text](./screenshots/lyrics.jpg) | ![A descriptive alt text](./screenshots/queue.jpg) | ![A descriptive alt text](./screenshots/artist.jpg) |

## ✨ Features
  🎧 Playback & Audio
  - Gapless Playback: Powered by just_audio for seamless transitions.
  - Audio Effects: Includes Fade In/Out, Skip Silence, and Speed/Pitch control.
  - Format Support: Plays MP3, FLAC, M4A, WAV, and more.
  - System Integration: Full background playback, notification controls, and lock screen media support.

### 🎨 UI & Customization
  - Adaptive Themes: The player UI automatically extracts colors from the current album art.
  - Dynamic Theming: Choose from 50+ color schemes (powered by flex_color_scheme) with automatic Dark/Light mode switching.
  - Immersive Player: A beautiful, gesture-driven player sheet with animated artwork and lyrics.

### 📝 Lyrics & Metadata
  - Live Synced Lyrics: Automatically fetches time-stamped lyrics from LRCLib.
  - Artist Insights: Integrates with Genius API to show artist biographies and high-res photos.
  - Lyric Cards: Select lyrics and generate beautiful, shareable cards for Instagram Stories or WhatsApp Status.
  - Tag Editing: Edit song metadata (Title, Artist, Album) directly within the app.

## 🔒 Permissions
Wavvy requires storage access to index your local music library.

- Android 13+ (SDK 33): Requests `READ_MEDIA_AUDIO` and `READ_MEDIA_IMAGES`.
- Android 12 & below: Requests `READ_EXTERNAL_STORAGE`.

Notifications: Required for playback controls on newer Android versions.

Note: The app will prompt for these permissions on the first launch. If denied, the library will be empty.
