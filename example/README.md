# tw_iphone_duo_reserved_region example

This application demonstrates the three result states exposed by the plugin
and paints active reserved regions over the Flutter window.

Run it on an iOS simulator or device:

```console
flutter pub get
flutter run
```

The example can be generated and built with either Flutter's default Swift
Package Manager integration or the CocoaPods compatibility path.

On unsupported platforms or iOS versions, the screen shows the normal
fallback state. On a supported runtime, active regions appear as translucent
red rectangles while important content remains inside `SafeArea`.
