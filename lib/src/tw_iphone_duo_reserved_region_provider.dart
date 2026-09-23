import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Provides active iPhone Duo system occlusion regions to descendants.
class TwIphoneDuoReservedRegionProvider extends InheritedWidget {
  const TwIphoneDuoReservedRegionProvider({
    super.key,
    required this.activeOcclusionRegions,
    required super.child,
  });

  /// Active occlusion rectangles in Flutter window logical coordinates.
  ///
  /// A null value means the native capability is unavailable. An empty list
  /// means the query succeeded and no active occlusion currently exists.
  final List<Rect>? activeOcclusionRegions;

  /// Returns the nearest query result and registers a dependency.
  static List<Rect>? activeOcclusionRegionsOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TwIphoneDuoReservedRegionProvider>()
        ?.activeOcclusionRegions;
  }

  @override
  bool updateShouldNotify(TwIphoneDuoReservedRegionProvider oldWidget) {
    return !listEquals(
      activeOcclusionRegions,
      oldWidget.activeOcclusionRegions,
    );
  }
}
