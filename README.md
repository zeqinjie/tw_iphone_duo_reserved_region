# tw_iphone_duo_reserved_region

English | [简体中文](README.zh-CN.md)

A Flutter plugin that exposes active iPhone Duo reserved regions as rectangles
in Flutter window logical coordinates. Use the reported geometry to keep
important controls and content clear of system-owned occlusion regions.

The plugin is intentionally small: it reports geometry and refreshes it at the
right lifecycle moments, while your application remains in control of its
layout.

## Platform support

| Platform | Behavior |
| --- | --- |
| iOS 27.1 or later | Queries active occlusion reserved regions. |
| Earlier iOS versions | Returns `null` so the app can use its normal fallback layout. |
| Other Flutter platforms | Returns `null` without invoking a platform channel. |

The package deployment target is iOS 15.5. The reserved-region API is guarded
at runtime, so the same application binary can still run on earlier supported
iOS versions.

## Installation

Add the published package from pub.dev:

```yaml
dependencies:
  tw_iphone_duo_reserved_region: ^1.0.0
```

For local development, use a checkout instead:

```yaml
dependencies:
  tw_iphone_duo_reserved_region:
    path: ../tw_iphone_duo_reserved_region
```

Then resolve packages:

```console
flutter pub get
```

## Native dependency management

The iOS implementation supports both Swift Package Manager and CocoaPods.
Flutter 3.44 and later use Swift Package Manager by default. Projects that
still use CocoaPods can continue to integrate the same native implementation
through the bundled podspec.

The plugin requires Flutter 3.44 or later and an iOS deployment target of at
least 15.5. Native compilation also requires Xcode 27.1 or later with the iOS
27.1 SDK because the implementation references the reserved-region APIs at
compile time.

## Usage

Install `TwIphoneDuoReservedRegionBridge` above the part of the widget tree
that needs access to reserved regions. Wrapping the application keeps the
reported rectangles in the same window coordinate space used by top-level
layouts.

```dart
import 'package:flutter/material.dart';
import 'package:tw_iphone_duo_reserved_region/tw_iphone_duo_reserved_region.dart';

void main() {
  runApp(
    const TwIphoneDuoReservedRegionBridge(
      child: MaterialApp(home: HomePage()),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Rect>? regions =
        TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(_statusFor(regions)),
        ),
      ),
    );
  }

  String _statusFor(List<Rect>? regions) {
    if (regions == null) return 'Reserved regions unavailable';
    if (regions.isEmpty) return 'No active reserved regions';
    return '${regions.length} active reserved region(s)';
  }
}
```

The bridge queries after the first frame, when window metrics change, and when
the application returns to the foreground. It discards stale asynchronous
responses when a newer refresh completes first.

## Result semantics

| Value | Meaning |
| --- | --- |
| `null` | The capability is unavailable or the query failed. Keep the fallback layout. |
| `[]` | The query succeeded and no occlusion region is currently active. |
| Non-empty list | Active rectangles in Flutter window logical coordinates. |

The rectangles are geometry, not padding values. Compare or intersect them
with the window-space bounds of important content, then choose the movement or
alternative layout that best fits your interface.

For example, this helper calculates how far a window-space content rectangle
must move down to clear intersecting regions:

```dart
double downwardClearance(Rect contentBounds, List<Rect> regions) {
  double clearance = 0;
  for (final Rect region in regions) {
    if (!contentBounds.overlaps(region)) continue;
    final double required = region.bottom - contentBounds.top;
    if (required > clearance) clearance = required;
  }
  return clearance;
}
```

If the content lives below an app bar, navigator, or another translated
ancestor, convert its bounds to window coordinates before checking overlap.
For a `RenderBox`, `localToGlobal(Offset.zero)` gives the window-space origin.

## Direct queries

Applications that already own their refresh lifecycle can query the platform
channel directly:

```dart
final List<Rect>? regions =
    await const TwIphoneDuoReservedRegionChannel().load();
```

Most applications should prefer the bridge because it handles relevant
lifecycle refreshes and shares one result with the subtree.

## Error behavior

Unsupported platforms return `null` without contacting a platform channel.
Missing plugin registration, platform exceptions, malformed native payloads,
and unexpected query failures are reported through `FlutterError.reportError`
and also resolve to `null`, preserving the fallback layout path.

## Limitations

- The result describes the current Flutter view only.
- Building requires Xcode 27.1 or later with the iOS 27.1 SDK; runtime results
  remain available only on supported iOS versions and devices.
- The plugin reports geometry; it does not reposition widgets automatically.
- The package does not synthesize regions on unsupported devices or platforms.

See the runnable [example application](example/lib/main.dart) for status UI and
a window-aligned region overlay.

## License

This package is available under the [MIT License](LICENSE).
