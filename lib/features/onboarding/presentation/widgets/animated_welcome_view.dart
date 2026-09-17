import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../splash/presentation/widgets/freshly_logo.dart';

/// Screen 1: Welcome View with flat-lay organic produce background and animated brand entrance
class AnimatedWelcomeView extends StatefulWidget {
  final VoidCallback? onNext;
  final VoidCallback? onSkip;

  const AnimatedWelcomeView({
    super.key,
    this.onNext,
    this.onSkip,
  });

  @override
  State<AnimatedWelcomeView> createState() => _AnimatedWelcomeViewState();
}

class _AnimatedWelcomeViewState extends State<AnimatedWelcomeView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  Timer? _entranceTimer;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Smooth entrance on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entranceTimer = Timer(const Duration(milliseconds: 200), () {
        if (mounted) {
          _controller.forward(from: 0.0);
        }
      });
    });
  }

  @override
  void dispose() {
    _entranceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onNext,
      child: Container(
        color: const Color(0xFFF7F5EE),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Pristine Full-Bleed Organic Produce Flat-Lay Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/splash_bg.jpg',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),

            // Layer 2: Center Branding + Top/Bottom Navigation Controls
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // Top Bar: Skip Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Skip button
                            TextButton(
                              onPressed: widget.onSkip,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF166534),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                backgroundColor: Colors.white.withValues(alpha: 0.85),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: const Color(0xFF166534).withValues(alpha: 0.15),
                                  ),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Spacer(flex: 8),

                      // Center Brand Elements (Animated Entrance)
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Dual Leaf Emblem
                              const TaazaBazarEmblem(size: 104),
                              const SizedBox(height: 14),

                              // TaazaBazar Brand Wordmark
                              Text(
                                'TaazaBazar',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 42,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF0A5832),
                                  letterSpacing: -1.0,
                                ),
                              ),
                              const SizedBox(height: 10),

                              // Taglines: "Pure Food" / "Better Life"
                              Text(
                                'Pure Food',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF38864E),
                                  letterSpacing: -0.3,
                                  height: 1.15,
                                ),
                              ),
                              Text(
                                'Better Life',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 29,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF38864E),
                                  letterSpacing: -0.3,
                                  height: 1.15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(flex: 8),

                      // Bottom Controls: Pagination Indicators + Prominent Next Button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // 2 Pagination Dots (Dot 1 Active)
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0A5832),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFC4D5C8),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ],
                            ),

                            // Next Action Button with Arrow Symbol
                            Material(
                              color: const Color(0xFF0A5832),
                              borderRadius: BorderRadius.circular(28),
                              elevation: 2,
                              shadowColor: const Color(0xFF0A5832).withValues(alpha: 0.35),
                              child: InkWell(
                                key: const ValueKey('welcome_next_btn'),
                                borderRadius: BorderRadius.circular(28),
                                onTap: widget.onNext,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 22,
                                    vertical: 11,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Next',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
