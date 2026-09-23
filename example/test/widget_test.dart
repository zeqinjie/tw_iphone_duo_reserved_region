import 'package:flutter_test/flutter_test.dart';
import 'package:tw_iphone_duo_reserved_region_example/main.dart';

void main() {
  testWidgets('shows the unavailable fallback state before a native result', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ReservedRegionExampleApp());

    expect(find.text('Reserved regions unavailable'), findsOneWidget);
    expect(
      find.text('Use your normal fallback layout on this device.'),
      findsOneWidget,
    );
  });
}
