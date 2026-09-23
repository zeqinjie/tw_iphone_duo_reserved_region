import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:tw_iphone_duo_reserved_region/src/tw_iphone_duo_reserved_region_channel.dart';
import 'package:tw_iphone_duo_reserved_region/src/tw_iphone_duo_reserved_region_provider.dart';

/// Maintains iPhone Duo Reserved Region state above the application subtree.
class TwIphoneDuoReservedRegionBridge extends StatefulWidget {
  const TwIphoneDuoReservedRegionBridge({
    super.key,
    required this.child,
    this.loader,
  });

  /// Application subtree that consumes the latest geometry.
  final Widget child;

  /// Test-only query override; production uses the MethodChannel loader.
  @visibleForTesting
  final TwIphoneDuoReservedRegionLoader? loader;

  @override
  State<TwIphoneDuoReservedRegionBridge> createState() =>
      _TwIphoneDuoReservedRegionBridgeState();
}

/// Refreshes active regions after the first frame and lifecycle changes.
class _TwIphoneDuoReservedRegionBridgeState
    extends State<TwIphoneDuoReservedRegionBridge>
    with WidgetsBindingObserver {
  /// Latest query result; null keeps consumers on their fallback position.
  List<Rect>? _activeOcclusionRegions;

  /// Monotonic token used to discard stale asynchronous query results.
  int _requestSequence = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_refresh());
    });
  }

  @override
  void didChangeMetrics() {
    unawaited(_refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refresh());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Queries native geometry and lets only the newest request update state.
  Future<void> _refresh() async {
    if (!mounted) return;
    final int requestSequence = ++_requestSequence;
    final TwIphoneDuoReservedRegionLoader loader =
        widget.loader ?? const TwIphoneDuoReservedRegionChannel().load;
    final List<Rect>? activeOcclusionRegions = await loader();
    if (!mounted || requestSequence != _requestSequence) return;
    setState(() {
      _activeOcclusionRegions = activeOcclusionRegions;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget resultWidget = widget.child;
    resultWidget = TwIphoneDuoReservedRegionProvider(
      activeOcclusionRegions: _activeOcclusionRegions,
      child: resultWidget,
    );
    return resultWidget;
  }
}
