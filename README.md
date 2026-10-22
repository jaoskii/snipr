# snipr

Clip it. Ship it. A Flutter app for gaming clips: trim and compress highlights to fit Discord and other upload limits, then mark up screenshots before sharing them. Everything runs on the device.

## Features

- **Video studio**: trim a highlight on the timeline, pick a platform preset (Discord free, Discord mobile 10 MB, social, messaging or a custom size) and compress with a two-pass FFmpeg encode that lands under the limit
- **Screenshot studio**: arrows, boxes, spotlight, redaction and meme captions
- **History**: past clips and edits stored locally in SQLite
- **Quick share** straight to other apps

## Stack

Flutter · Riverpod · ffmpeg_kit_flutter_new · video_player · sqflite · share_plus

## Run

```bash
flutter pub get
flutter run
```

Requires Flutter with Dart 3. Android is the supported target for now.

## Tests

```bash
flutter test
```
