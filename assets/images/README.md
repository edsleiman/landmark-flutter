# Logo image goes here

Drop your splash/logo image at `assets/images/landmark_logo.png` and the
splash screen (`lib/screens/splash_screen.dart`) will use it automatically.

Until then, the splash screen falls back to a simple generic icon — that's
expected, not a bug.

This file exists only so the folder isn't empty — git doesn't track empty
directories, and `pubspec.yaml` declares this as an asset directory, which
Flutter requires to physically exist on disk.
