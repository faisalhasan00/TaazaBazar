import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A rich, animated mock vector map displaying live route, farm origin,
/// moving rider marker, and destination home pin.
class MockDeliveryMap extends StatefulWidget {
  final String originName;
  final String destinationName;
  final String etaText;
  final String distanceText;

  const MockDeliveryMap({
    super.key,
    this.originName = 'Sunrise Farm Hub',
    this.destinationName = 'Delivery Address',
    this.etaText = 'Morning Slot',
    this.distanceText = 'Dispatch Route',
  });

  @override
  State<MockDeliveryMap> createState() => _MockDeliveryMapState();
}

class _MockDeliveryMapState extends State<MockDeliveryMap>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F0),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFFE2EBE2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF166534).withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // 1. Custom Vector Map Canvas
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(double.infinity, 240),
                  painter: _MapCanvasPainter(
                    pulseProgress: _pulseAnimation.value,
                  ),
                );
              },
            ),

            // 2. Origin Farm Badge (Top-Left)
            Positioned(
              top: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: const Text('🌱', style: TextStyle(fontSize: 10)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.originName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF166534),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 3. Destination Home Badge (Bottom-Right)
            Positioned(
              bottom: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Color(0xFFFEE2E2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: Color(0xFFDC2626),
                        size: 12,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.destinationName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 4. Floating Live Distance & ETA Pill (Top-Right)
            Positioned(
              top: 14,
              right: 14,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF166534),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF166534).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF4ADE80),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.distanceText} • ETA ${widget.etaText}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 5. Map Re-center & Zoom Controls Simulation (Bottom-Left)
            Positioned(
              bottom: 14,
              left: 14,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Re-centered on rider location 📍'),
                            duration: Duration(milliseconds: 900),
                            backgroundColor: Color(0xFF166534),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(
                          Icons.my_location_rounded,
                          size: 16,
                          color: Color(0xFF166534),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 1,
                      height: 14,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const SizedBox(width: 4),
                    const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.layers_outlined,
                        size: 16,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Canvas painter rendering clean vector road networks, parks, and animated rider path
class _MapCanvasPainter extends CustomPainter {
  final double pulseProgress;

  _MapCanvasPainter({required this.pulseProgress});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Background Grid / Land Polygons
    final bgPaint = Paint()..color = const Color(0xFFF4F7F2);
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), bgPaint);

    // Park / Greenery patches
    final parkPaint = Paint()
      ..color = const Color(0xFFE8F5E9)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(10, 10, w * 0.35, h * 0.45),
        const Radius.circular(16),
      ),
      parkPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.55, h * 0.5, w * 0.4, h * 0.42),
        const Radius.circular(18),
      ),
      parkPaint,
    );

    // 2. Roads Network (Secondary Streets)
    final secondaryRoadPaint = Paint()
      ..color = const Color(0xFFFFFFFF)
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final roadBorderPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 16
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Secondary Cross Street 1
    final road1 = Path()
      ..moveTo(-10, h * 0.7)
      ..lineTo(w * 0.6, h * 0.25)
      ..lineTo(w + 10, h * 0.35);

    canvas.drawPath(road1, roadBorderPaint);
    canvas.drawPath(road1, secondaryRoadPaint);

    // Secondary Cross Street 2
    final road2 = Path()
      ..moveTo(w * 0.2, -10)
      ..lineTo(w * 0.4, h * 0.5)
      ..lineTo(w * 0.3, h + 10);

    canvas.drawPath(road2, roadBorderPaint);
    canvas.drawPath(road2, secondaryRoadPaint);

    // 3. Main Delivery Highway / Primary Route
    final highwayBorder = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 22
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final highwaySurface = Paint()
      ..color = Colors.white
      ..strokeWidth = 18
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final routePath = Path()
      ..moveTo(w * 0.15, h * 0.32) // Farm Point
      ..cubicTo(
        w * 0.35,
        h * 0.25,
        w * 0.32,
        h * 0.75,
        w * 0.58,
        h * 0.55, // Mid Junction
      )
      ..cubicTo(
        w * 0.72,
        h * 0.42,
        w * 0.75,
        h * 0.78,
        w * 0.85,
        h * 0.75, // Customer Destination
      );

    canvas.drawPath(routePath, highwayBorder);
    canvas.drawPath(routePath, highwaySurface);

    // 4. Green Delivery Route Polyline Highlight
    final activeRoutePaint = Paint()
      ..color = const Color(0xFF22C55E).withValues(alpha: 0.85)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(routePath, activeRoutePaint);

    // 5. Origin Node (Farm Seedling Icon Anchor)
    final originCenter = Offset(w * 0.15, h * 0.32);
    canvas.drawCircle(
      originCenter,
      9,
      Paint()..color = const Color(0xFF166534),
    );
    canvas.drawCircle(
      originCenter,
      5,
      Paint()..color = const Color(0xFFDCFCE7),
    );

    // 6. Destination Node (Customer Home Anchor)
    final destinationCenter = Offset(w * 0.85, h * 0.75);
    canvas.drawCircle(
      destinationCenter,
      10,
      Paint()..color = const Color(0xFFDC2626),
    );
    canvas.drawCircle(
      destinationCenter,
      6,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      destinationCenter,
      3,
      Paint()..color = const Color(0xFFDC2626),
    );

    // 7. Live Delivery Rider Location (Animated Midpoint along route)
    final riderOffset = Offset(w * 0.58, h * 0.55);

    // Pulsing Radar Radar Wave
    final pulseRadius = 14 + (pulseProgress * 16);
    final pulseOpacity = (1.0 - pulseProgress).clamp(0.0, 1.0) * 0.4;
    canvas.drawCircle(
      riderOffset,
      pulseRadius,
      Paint()
        ..color = const Color(0xFF22C55E).withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.fill,
    );

    // Rider Outer Glow
    canvas.drawCircle(
      riderOffset,
      16,
      Paint()..color = Colors.white,
    );
    canvas.drawCircle(
      riderOffset,
      14,
      Paint()
        ..color = const Color(0xFF166534)
        ..style = PaintingStyle.fill,
    );

    // Vehicle Badge Inner Icon Anchor
    canvas.drawCircle(
      riderOffset,
      7,
      Paint()..color = const Color(0xFF22C55E),
    );
  }

  @override
  bool shouldRepaint(covariant _MapCanvasPainter oldDelegate) {
    return oldDelegate.pulseProgress != pulseProgress;
  }
}
