import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Loads active iPhone Duo reserved-region rectangles for the Flutter window.
typedef TwIphoneDuoReservedRegionLoader = Future<List<Rect>?> Function();

/// Queries and validates iOS reserved-region geometry through MethodChannel.
class TwIphoneDuoReservedRegionChannel {
  const TwIphoneDuoReservedRegionChannel();

  /// Native channel dedicated to iPhone Duo reserved-region geometry.
  static const MethodChannel _channel = MethodChannel(
    'tw591/iphone_duo_reserved_regions',
  );

  /// Loads active occlusion rectangles in Flutter logical coordinates.
  ///
  /// Null means the native capability is unavailable or the query failed. An
  /// empty list means the query succeeded and no active occlusion exists.
  Future<List<Rect>?> load() async {
    if (defaultTargetPlatform != TargetPlatform.iOS) return null;
    try {
      final dynamic result = await _channel.invokeMethod<dynamic>(
        'getActiveOcclusionRegions',
      );
      if (result == null) return null;
      if (result is! List<dynamic>) {
        _reportFailure(
          const FormatException('Reserved Region 回傳格式不是陣列'),
          StackTrace.current,
        );
        return null;
      }
      final List<Rect> regions = <Rect>[];
      for (final dynamic item in result) {
        final Rect? region = _parseRegion(item);
        if (region == null) {
          _reportFailure(
            const FormatException('Reserved Region 矩形格式無效'),
            StackTrace.current,
          );
          return null;
        }
        regions.add(region);
      }
      return List<Rect>.unmodifiable(regions);
    } on MissingPluginException catch (error, stackTrace) {
      _reportFailure(error, stackTrace);
      return null;
    } on PlatformException catch (error, stackTrace) {
      _reportFailure(error, stackTrace);
      return null;
    } on Object catch (error, stackTrace) {
      _reportFailure(error, stackTrace);
      return null;
    }
  }

  /// Converts one native dictionary into a validated rectangle.
  Rect? _parseRegion(dynamic item) {
    if (item is! Map<dynamic, dynamic>) return null;
    final dynamic leftValue = item['left'];
    final dynamic topValue = item['top'];
    final dynamic widthValue = item['width'];
    final dynamic heightValue = item['height'];
    if (leftValue is! num ||
        topValue is! num ||
        widthValue is! num ||
        heightValue is! num) {
      return null;
    }
    final double left = leftValue.toDouble();
    final double top = topValue.toDouble();
    final double width = widthValue.toDouble();
    final double height = heightValue.toDouble();
    if (!left.isFinite ||
        !top.isFinite ||
        !width.isFinite ||
        !height.isFinite ||
        width < 0 ||
        height < 0) {
      return null;
    }
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Reports integration failures while preserving the safe fallback path.
  void _reportFailure(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'tw_iphone_duo_reserved_region',
        context: ErrorDescription('讀取 iPhone Duo Reserved Region 時'),
      ),
    );
  }
}
