import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_iphone_duo_reserved_region/tw_iphone_duo_reserved_region.dart';

void main() {
  test('Provider 僅在 Reserved Region 內容變更時通知', () {
    const TwIphoneDuoReservedRegionProvider previous =
        TwIphoneDuoReservedRegionProvider(
          activeOcclusionRegions: <Rect>[Rect.fromLTWH(320, 0, 80, 60)],
          child: SizedBox.shrink(),
        );
    const TwIphoneDuoReservedRegionProvider same =
        TwIphoneDuoReservedRegionProvider(
          activeOcclusionRegions: <Rect>[Rect.fromLTWH(320, 0, 80, 60)],
          child: SizedBox.shrink(),
        );
    const TwIphoneDuoReservedRegionProvider changed =
        TwIphoneDuoReservedRegionProvider(
          activeOcclusionRegions: <Rect>[],
          child: SizedBox.shrink(),
        );

    expect(same.updateShouldNotify(previous), isFalse);
    expect(changed.updateShouldNotify(previous), isTrue);
  });

  testWidgets('Bridge 在首幀後查詢並注入 Reserved Region', (tester) async {
    int callCount = 0;
    List<Rect>? latestRegions;
    await tester.pumpWidget(
      TwIphoneDuoReservedRegionBridge(
        loader: () async {
          callCount += 1;
          return const <Rect>[Rect.fromLTWH(320, 0, 80, 60)];
        },
        child: _ReservedRegionProbe(
          onBuild: (List<Rect>? regions) {
            latestRegions = regions;
          },
        ),
      ),
    );
    await tester.pump();

    expect(callCount, 1);
    expect(latestRegions, const <Rect>[Rect.fromLTWH(320, 0, 80, 60)]);
  });

  testWidgets('Bridge 在 App 恢復前台時重新查詢', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(
      TwIphoneDuoReservedRegionBridge(
        loader: () async {
          callCount += 1;
          return const <Rect>[];
        },
        child: const _ReservedRegionProbe(),
      ),
    );
    await tester.pump();
    expect(callCount, 1);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();

    expect(callCount, 2);
  });

  testWidgets('Bridge 在視窗 metrics 變化時重新查詢', (tester) async {
    int callCount = 0;
    await tester.pumpWidget(
      TwIphoneDuoReservedRegionBridge(
        loader: () async {
          callCount += 1;
          return const <Rect>[];
        },
        child: const _ReservedRegionProbe(),
      ),
    );
    await tester.pump();
    expect(callCount, 1);

    tester.view.physicalSize = const Size(900, 600);
    addTearDown(tester.view.reset);
    await tester.pump();

    expect(callCount, 2);
  });

  testWidgets('Bridge 忽略較早請求的延遲結果', (tester) async {
    final Completer<List<Rect>?> firstRequest = Completer<List<Rect>?>();
    final Completer<List<Rect>?> secondRequest = Completer<List<Rect>?>();
    int callCount = 0;
    List<Rect>? latestRegions;
    await tester.pumpWidget(
      TwIphoneDuoReservedRegionBridge(
        loader: () {
          callCount += 1;
          return callCount == 1 ? firstRequest.future : secondRequest.future;
        },
        child: _ReservedRegionProbe(
          onBuild: (List<Rect>? regions) {
            latestRegions = regions;
          },
        ),
      ),
    );
    await tester.pump();

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    expect(callCount, 2);

    secondRequest.complete(const <Rect>[Rect.fromLTWH(320, 80, 80, 44)]);
    await tester.pump();
    await tester.pump();
    expect(latestRegions, const <Rect>[Rect.fromLTWH(320, 80, 80, 44)]);

    firstRequest.complete(const <Rect>[Rect.fromLTWH(320, 0, 80, 60)]);
    await tester.pump();
    await tester.pump();
    expect(latestRegions, const <Rect>[Rect.fromLTWH(320, 80, 80, 44)]);
  });
}

/// Reads the nearest Reserved Region Provider during widget tests.
class _ReservedRegionProbe extends StatelessWidget {
  const _ReservedRegionProbe({this.onBuild});

  /// Reports the provider value observed by this build.
  final ValueChanged<List<Rect>?>? onBuild;

  @override
  Widget build(BuildContext context) {
    onBuild?.call(
      TwIphoneDuoReservedRegionProvider.activeOcclusionRegionsOf(context),
    );
    Widget resultWidget = const SizedBox.shrink();
    return resultWidget;
  }
}
