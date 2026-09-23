# Pub-ready Flutter Plugin Design

## Goal

Prepare `tw_iphone_duo_reserved_region` for a future public release on
pub.dev while keeping all work local. This iteration must not publish the
package, push a branch, or create a Git commit.

## Scope

- Preserve the existing Dart API and iOS method-channel protocol.
- Add an English `README.md` suitable for pub.dev.
- Add an MIT `LICENSE`.
- Add a complete Flutter app under `example/`.
- Align package, CocoaPods, and changelog versions at `1.0.0`.
- Complete pub.dev metadata without inventing unavailable assets such as
  screenshots.
- Improve API documentation and tests where publication checks reveal gaps.
- Run formatting, static analysis, tests, and a publish dry run.

## Public API and behavior

The package continues to expose three public types:

- `TwIphoneDuoReservedRegionBridge` owns refresh behavior and injects the
  latest result above an application subtree.
- `TwIphoneDuoReservedRegionProvider` exposes the result to descendants.
- `TwIphoneDuoReservedRegionChannel` performs the direct platform query for
  advanced integrations and testing.

No breaking API changes are planned. The native query remains
`getActiveOcclusionRegions` on `tw591/iphone_duo_reserved_regions`.

Results retain the existing three-state contract:

- `null`: the capability is unavailable or the query failed.
- Empty list: the query succeeded and no reserved region is active.
- Non-empty list: active rectangles in Flutter logical coordinates.

The bridge refreshes after its first frame, when window metrics change, and
when the application resumes. Stale asynchronous results cannot replace a
newer result.

## README

The README will cover:

1. What the plugin solves and the supported platform/system requirement.
2. Installation from pub.dev for the eventual release and a local path option
   for development before publication.
3. Wrapping the application with the bridge.
4. Reading and interpreting active regions.
5. A practical layout-avoidance example.
6. Coordinate-system and lifecycle semantics.
7. Graceful behavior on unsupported platforms and systems.
8. A link to the runnable example and a concise API reference.

English will be the primary language to suit the public pub.dev audience.

## Example application

The example will be a conventional Flutter application with its own
`pubspec.yaml`, analysis configuration, iOS runner scaffold, and test. Its
main screen will:

- Install `TwIphoneDuoReservedRegionBridge` above the app content.
- Display whether the capability is unavailable, inactive, or active.
- List the current rectangle values.
- Paint active regions as translucent overlays in the same coordinate space.
- Keep important sample content outside the reported rectangles to demonstrate
  the intended integration pattern.

The example must remain understandable on unsupported devices by clearly
showing the fallback state rather than failing.

## Package metadata and release files

`pubspec.yaml` will include the repository, issue tracker, and relevant topics.
The package, podspec, and changelog will consistently use version `1.0.0`.
The changelog will describe the public API, native iOS support, lifecycle
refresh behavior, tests, documentation, and example.

The MIT license will identify the existing author and current year. Screenshot
metadata will be omitted until real screenshots are available.

## Error handling

Unsupported platforms return `null` without invoking the channel. Missing
plugins, platform exceptions, malformed payloads, and unexpected errors are
reported through `FlutterError.reportError` and resolve to `null`. The example
must present this state as unavailable instead of treating it as a crash.

## Verification

The completed local tree must pass:

- `dart format --output=none --set-exit-if-changed .`
- `flutter analyze`
- `flutter test`
- Example analysis and tests when not covered by the root commands.
- `dart pub publish --dry-run`

The dry run is validation only. No publication, Git commit, or remote push is
authorized.

## Out of scope

- Publishing to pub.dev.
- Pushing code or tags to a remote.
- Creating a Git commit.
- Expanding the plugin with new layout widgets or unrelated APIs.
- Fabricating screenshots or device results that have not been captured.
