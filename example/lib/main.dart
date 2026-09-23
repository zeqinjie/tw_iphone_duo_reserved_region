import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tw_iphone_duo_reserved_region/tw_iphone_duo_reserved_region.dart';

void main() {
  runApp(const ReservedRegionExampleApp());
}

class ReservedRegionExampleApp extends StatelessWidget {
  const ReservedRegionExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const TwIphoneDuoReservedRegionBridge(
        child: ReservedRegionDemoPage(),
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

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text('iPhone Duo Reserved Regions', style: textTheme.headlineMedium),
          const SizedBox(height: 24),
          if (currentRegions == null) ...<Widget>[
            Text('Reserved regions unavailable', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Use your normal fallback layout on this device.'),
          ] else if (currentRegions.isEmpty) ...<Widget>[
            Text('No active reserved regions', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('The native query succeeded without active occlusion.'),
          ] else ...<Widget>[
            Text('Active reserved regions', style: textTheme.titleLarge),
            const SizedBox(height: 8),
            for (final (int index, Rect region) in currentRegions.indexed)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('${index + 1}. $region'),
              ),
          ],
        ],
      ),
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
