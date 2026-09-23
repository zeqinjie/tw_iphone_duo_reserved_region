# Pub-ready Flutter Plugin Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `tw_iphone_duo_reserved_region` complete and verifiable for a future public pub.dev release without publishing or changing its existing API.

**Architecture:** Keep the Dart bridge/provider/channel and Objective-C method-channel implementation unchanged unless validation exposes a defect. Add publication metadata and long-form usage documentation at the package root, then add a self-contained Flutter example that consumes the public package API and visualizes returned logical-coordinate rectangles.

**Tech Stack:** Flutter 3.38.10, Dart 3.10.9, Objective-C iOS plugin, `flutter_test`, pub.dev package validation.

**Spec:** `docs/superpowers/specs/2026-09-23-pub-ready-plugin-design.md`

## Global Constraints

- Preserve the existing Dart public API and native channel protocol.
- Keep the Dart SDK constraint at `>=3.10.0 <4.0.0` and Flutter constraint at `>=3.38.0`.
- Keep iOS deployment target `15.5` and runtime availability guard `iOS 27.1`.
- Use version `1.0.0` in `pubspec.yaml`, the podspec, and `CHANGELOG.md`.
- Use English as the primary public documentation language.
- Use the MIT License with copyright year 2026 and author `zhengzeqin`.
- Do not invent screenshots or claim results from untested devices.
- Do not create a Git commit, push any remote, create a tag, or publish to pub.dev.

---

### Task 1: Release metadata and legal files

**Files:**
- Modify: `pubspec.yaml`
- Modify: `ios/tw_iphone_duo_reserved_region.podspec`
- Replace: `CHANGELOG.md`
- Create: `LICENSE`

**Interfaces:**
- Consumes: Existing package name, GitHub repository URL, version, SDK floors, and iOS plugin registration.
- Produces: Consistent version `1.0.0` and complete metadata consumed by pub.dev and CocoaPods.

- [ ] **Step 1: Run the publication validator to capture the baseline failures**

Run:

```bash
dart pub publish --dry-run
```

Expected: non-zero exit or warnings about missing `README.md`, `LICENSE`, example, and incomplete publication files. Save the diagnostic categories in the implementation notes; do not publish.

- [ ] **Step 2: Complete `pubspec.yaml` publication metadata**

Keep the existing fields and add these fields after `homepage`:

```yaml
repository: https://github.com/zeqinjie/tw_iphone_duo_reserved_region
issue_tracker: https://github.com/zeqinjie/tw_iphone_duo_reserved_region/issues
topics:
  - ios
  - layout
  - safe-area
```

Do not add `screenshots` until real image files exist.

- [ ] **Step 3: Align the podspec version and license**

Change these exact values in `ios/tw_iphone_duo_reserved_region.podspec`:

```ruby
s.version          = '1.0.0'
s.license          = { :type => 'MIT', :file => '../LICENSE' }
```

Keep the deployment target and source file declarations unchanged.

- [ ] **Step 4: Add the MIT license**

Create `LICENSE` with:

```text
MIT License

Copyright (c) 2026 zhengzeqin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

- [ ] **Step 5: Replace the changelog with the public `1.0.0` entry**

Use this content in `CHANGELOG.md`:

```markdown
## 1.0.0

- Added active iPhone Duo reserved-region queries on supported iOS versions.
- Added `TwIphoneDuoReservedRegionBridge` for lifecycle-aware refreshes.
- Added `TwIphoneDuoReservedRegionProvider` for subtree access to logical-coordinate regions.
- Added safe fallbacks for unsupported platforms, unavailable native capabilities, and invalid payloads.
- Added package documentation, automated tests, and a runnable example application.
```

- [ ] **Step 6: Verify metadata parses**

Run:

```bash
flutter pub get
```

Expected: exit code 0 with dependencies resolved and no pubspec syntax error.

---

### Task 2: Public README and API guidance

**Files:**
- Create: `README.md`

**Interfaces:**
- Consumes: `TwIphoneDuoReservedRegionBridge`, `TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(BuildContext)`, and `TwIphoneDuoReservedRegionChannel.load()`.
- Produces: Copy-pasteable integration instructions and an explicit `List<Rect>?` result contract.

- [ ] **Step 1: Write the package overview and compatibility notes**

Start `README.md` with the package name and a concise statement that it exposes active iPhone Duo occlusion regions in Flutter logical coordinates. State:

```markdown
## Platform support

| Platform | Behavior |
| --- | --- |
| iOS 27.1 or later | Queries active occlusion reserved regions. |
| Earlier iOS versions | Returns `null` so the app can use its normal fallback layout. |
| Other Flutter platforms | Returns `null` without invoking a platform channel. |
```

Clarify that the package's deployment target is iOS 15.5 even though the reserved-region API is guarded at runtime.

- [ ] **Step 2: Document installation before and after publication**

Include both forms without claiming the package is already published:

```yaml
# After the package is published on pub.dev:
dependencies:
  tw_iphone_duo_reserved_region: ^1.0.0

# Before publication, from a local checkout:
dependencies:
  tw_iphone_duo_reserved_region:
    path: ../tw_iphone_duo_reserved_region
```

- [ ] **Step 3: Document the recommended bridge integration**

Include a complete `main()` example that wraps `MaterialApp` in `TwIphoneDuoReservedRegionBridge`, imports only the package barrel file, and reads regions with:

```dart
final List<Rect>? regions =
    TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(context);
```

Explain that the bridge refreshes after the first frame, on metrics changes, and when the app resumes.

- [ ] **Step 4: Document result and coordinate semantics**

Add a table with these exact meanings:

| Value | Meaning |
| --- | --- |
| `null` | The capability is unavailable or the query failed. Keep the fallback layout. |
| `[]` | The query succeeded and no occlusion region is currently active. |
| Non-empty list | Active rectangles in Flutter window logical coordinates. |

Explain that consumers should compare or intersect these rectangles with their content bounds rather than treating them as padding values.

- [ ] **Step 5: Document direct channel access and limitations**

Show `await const TwIphoneDuoReservedRegionChannel().load()` for integrations that own their refresh lifecycle. Add limitations stating that the result describes the current Flutter view, availability depends on the installed iOS SDK/runtime, and the package does not reposition widgets automatically.

- [ ] **Step 6: Link the runnable example and license**

End with links to `example/lib/main.dart` and `LICENSE`, and avoid badges whose targets do not yet exist.

- [ ] **Step 7: Check Markdown content for stale version text**

Run:

```bash
rg -n '0\.0\.1|published on pub\.dev' README.md CHANGELOG.md pubspec.yaml ios/tw_iphone_duo_reserved_region.podspec
```

Expected: no matches. The installation comment may say "After the package is published on pub.dev"; if the exact scan matches it, reword it to "For a future pub.dev release" so there is no present-tense publication claim.

---

### Task 3: Runnable example application

**Files:**
- Create: `example/pubspec.yaml`
- Create: `example/analysis_options.yaml`
- Create: `example/lib/main.dart`
- Create: `example/test/widget_test.dart`
- Create/update generated iOS runner files under: `example/ios/`
- Create/update generated project files required by Flutter under: `example/`

**Interfaces:**
- Consumes: `TwIphoneDuoReservedRegionBridge` and `TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(BuildContext)`.
- Produces: `ReservedRegionExampleApp`, a runnable iOS demonstration, and a widget test that verifies unsupported/fallback rendering.

- [ ] **Step 1: Generate the conventional Flutter example scaffold**

Run from the package root:

```bash
flutter create --platforms=ios --org com.zeqinjie --project-name tw_iphone_duo_reserved_region_example example
```

Expected: Flutter creates a valid iOS example project. Review generated files before editing and retain the standard runner configuration.

- [ ] **Step 2: Configure the example package dependency**

Replace `example/pubspec.yaml` with:

```yaml
name: tw_iphone_duo_reserved_region_example
description: Demonstrates the tw_iphone_duo_reserved_region plugin.
publish_to: none

version: 1.0.0+1

environment:
  sdk: ">=3.10.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  tw_iphone_duo_reserved_region:
    path: ../

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0

flutter:
  uses-material-design: true
```

Set `example/analysis_options.yaml` to:

```yaml
include: package:flutter_lints/flutter.yaml
```

- [ ] **Step 3: Write the failing fallback-state widget test**

Replace `example/test/widget_test.dart` with:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_iphone_duo_reserved_region_example/main.dart';

void main() {
  testWidgets('shows the unavailable fallback state before a native result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReservedRegionExampleApp());

    expect(find.text('Reserved regions unavailable'), findsOneWidget);
    expect(find.text('Use your normal fallback layout on this device.'), findsOneWidget);
  });
}
```

- [ ] **Step 4: Run the example test to verify it fails**

Run:

```bash
cd example && flutter test test/widget_test.dart
```

Expected: FAIL because `ReservedRegionExampleApp` and its fallback UI are not implemented yet.

- [ ] **Step 5: Implement the example app and region overlay**

Replace `example/lib/main.dart` with this focused implementation:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:tw_iphone_duo_reserved_region/tw_iphone_duo_reserved_region.dart';

void main() {
  runApp(const ReservedRegionExampleApp());
}

class ReservedRegionExampleApp extends StatelessWidget {
  const ReservedRegionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const TwIphoneDuoReservedRegionBridge(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: ReservedRegionDemoPage(),
      ),
    );
  }
}

class ReservedRegionDemoPage extends StatelessWidget {
  const ReservedRegionDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Rect>? regions =
        TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          SafeArea(child: _RegionSummary(regions: regions)),
          if (regions != null)
            IgnorePointer(child: CustomPaint(painter: _RegionPainter(regions))),
        ],
      ),
    );
  }
}

class _RegionSummary extends StatelessWidget {
  const _RegionSummary({required this.regions});

  final List<Rect>? regions;

  @override
  Widget build(BuildContext context) {
    final List<Rect>? currentRegions = regions;
    final TextTheme textTheme = Theme.of(context).textTheme;

    if (currentRegions == null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Reserved regions unavailable', style: textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text('Use your normal fallback layout on this device.'),
          ],
        ),
      );
    }

    if (currentRegions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No active reserved regions'),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: currentRegions.length + 1,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        if (index == 0) {
          return Text('Active reserved regions', style: textTheme.headlineSmall);
        }
        return Text('${index.toString()}. ${currentRegions[index - 1]}');
      },
    );
  }
}

class _RegionPainter extends CustomPainter {
  const _RegionPainter(this.regions);

  final List<Rect> regions;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()..color = Colors.red.withValues(alpha: 0.24);
    final Paint border = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final Rect region in regions) {
      canvas.drawRect(region, fill);
      canvas.drawRect(region, border);
    }
  }

  @override
  bool shouldRepaint(_RegionPainter oldDelegate) {
    return !listEquals(regions, oldDelegate.regions);
  }
}
```

Keep the screen content inside `SafeArea`, and do not add a `Scaffold.appBar`;
the translucent overlay remains in the full-window `Stack` coordinate space
so it matches the window-relative values.

- [ ] **Step 6: Run the example test to verify it passes**

Run:

```bash
cd example && flutter test test/widget_test.dart
```

Expected: PASS with one widget test.

- [ ] **Step 7: Resolve example dependencies and analyze it**

Run:

```bash
cd example && flutter pub get && flutter analyze
```

Expected: both commands exit 0 with no analyzer issues.

---

### Task 4: Package-wide publication verification

**Files:**
- Modify only files named by concrete diagnostics from the commands below.

**Interfaces:**
- Consumes: All release metadata, documentation, example, existing Dart API, Objective-C implementation, and tests.
- Produces: A clean, locally validated publication candidate with no remote side effects.

- [ ] **Step 1: Format all Dart sources**

Run:

```bash
dart format .
dart format --output=none --set-exit-if-changed .
```

Expected: the first command formats files if needed; the second exits 0.

- [ ] **Step 2: Run package analysis**

Run:

```bash
flutter analyze
```

Expected: exit code 0 and `No issues found!`. Fix only diagnostics caused by or directly affecting this package/publication work, then rerun the command.

- [ ] **Step 3: Run root and example tests**

Run:

```bash
flutter test
(cd example && flutter test)
```

Expected: all channel, bridge, provider, and example widget tests pass.

- [ ] **Step 4: Run the final publication dry run**

Run:

```bash
dart pub publish --dry-run
```

Expected: exit code 0 or publication-ready output with no errors. Warnings must be evaluated individually; fix actionable package-quality warnings, but do not publish and do not fabricate missing assets.

- [ ] **Step 5: Review the exact local diff and repository state**

Run:

```bash
git status --short
git diff --check
git diff --stat
git diff -- README.md LICENSE CHANGELOG.md pubspec.yaml ios/tw_iphone_duo_reserved_region.podspec example
```

Expected: only intentional local files are modified or untracked, `git diff --check` exits 0, and no commit exists beyond the original repository history.

- [ ] **Step 6: Report completion without remote actions**

Report the files added/changed, verification commands and outcomes, any remaining dry-run warning, and reiterate that no Git commit, remote push, tag, or pub.dev publication occurred.
