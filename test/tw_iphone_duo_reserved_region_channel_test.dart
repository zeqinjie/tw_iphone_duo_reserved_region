import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tw_iphone_duo_reserved_region/tw_iphone_duo_reserved_region.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel(
    'tw591/iphone_duo_reserved_regions',
  );

  setUp(() {
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  });

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('將原生矩形資料轉為 Rect', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          expect(call.method, 'getActiveOcclusionRegions');
          return <Map<String, double>>[
            <String, double>{'left': 320, 'top': 0, 'width': 80, 'height': 60},
          ];
        });

    expect(await const TwIphoneDuoReservedRegionChannel().load(), const <Rect>[
      Rect.fromLTWH(320, 0, 80, 60),
    ]);
  });

  test('原生回傳 null 時標記查詢能力不可用', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async => null);

    expect(await const TwIphoneDuoReservedRegionChannel().load(), isNull);
  });

  test('原生回傳空陣列時保留成功且無遮擋語意', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (MethodCall call) async => <dynamic>[],
        );

    expect(await const TwIphoneDuoReservedRegionChannel().load(), isEmpty);
  });

  for (final dynamic invalidPayload in <dynamic>[
    <dynamic>['invalid'],
    <dynamic>[
      <String, dynamic>{'left': 0, 'top': 0, 'width': 20},
    ],
    <dynamic>[
      <String, dynamic>{'left': '0', 'top': 0, 'width': 20, 'height': 20},
    ],
    <dynamic>[
      <String, dynamic>{
        'left': double.infinity,
        'top': 0,
        'width': 20,
        'height': 20,
      },
    ],
    <dynamic>[
      <String, dynamic>{'left': 0, 'top': 0, 'width': -1, 'height': 20},
    ],
  ]) {
    test('原生矩形格式無效時回退並記錄一次錯誤 $invalidPayload', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            channel,
            (MethodCall call) async => invalidPayload,
          );
      final List<FlutterErrorDetails> reportedErrors = <FlutterErrorDetails>[];

      final List<Rect>? result = await _captureFlutterErrors(
        reportedErrors: reportedErrors,
        action: const TwIphoneDuoReservedRegionChannel().load,
      );

      expect(result, isNull);
      expect(reportedErrors, hasLength(1));
    });
  }

  test('MethodChannel 回傳非陣列時回退並記錄一次錯誤', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
          channel,
          (MethodCall call) async => <String, dynamic>{},
        );
    final List<FlutterErrorDetails> reportedErrors = <FlutterErrorDetails>[];

    final List<Rect>? result = await _captureFlutterErrors(
      reportedErrors: reportedErrors,
      action: const TwIphoneDuoReservedRegionChannel().load,
    );

    expect(result, isNull);
    expect(reportedErrors, hasLength(1));
  });

  test('MethodChannel 未註冊時回退並記錄一次錯誤', () async {
    final List<FlutterErrorDetails> reportedErrors = <FlutterErrorDetails>[];

    final List<Rect>? result = await _captureFlutterErrors(
      reportedErrors: reportedErrors,
      action: const TwIphoneDuoReservedRegionChannel().load,
    );

    expect(result, isNull);
    expect(reportedErrors, hasLength(1));
    expect(reportedErrors.single.exception, isA<MissingPluginException>());
  });

  test('MethodChannel 平台錯誤時回退並記錄一次錯誤', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          throw PlatformException(code: 'query_failed');
        });
    final List<FlutterErrorDetails> reportedErrors = <FlutterErrorDetails>[];

    final List<Rect>? result = await _captureFlutterErrors(
      reportedErrors: reportedErrors,
      action: const TwIphoneDuoReservedRegionChannel().load,
    );

    expect(result, isNull);
    expect(reportedErrors, hasLength(1));
    expect(reportedErrors.single.exception, isA<PlatformException>());
  });

  test('非 iOS 平台不呼叫 MethodChannel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    int callCount = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (MethodCall call) async {
          callCount += 1;
          return <dynamic>[];
        });

    expect(await const TwIphoneDuoReservedRegionChannel().load(), isNull);
    expect(callCount, 0);
  });
}

/// 暫存錯誤路徑測試預期收到的 Flutter 診斷。
Future<T> _captureFlutterErrors<T>({
  required List<FlutterErrorDetails> reportedErrors,
  required Future<T> Function() action,
}) async {
  final FlutterExceptionHandler? originalOnError = FlutterError.onError;
  FlutterError.onError = reportedErrors.add;
  try {
    return await action();
  } finally {
    FlutterError.onError = originalOnError;
  }
}
