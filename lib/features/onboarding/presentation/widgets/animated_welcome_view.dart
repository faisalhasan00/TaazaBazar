import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../splash/presentation/widgets/freshly_logo.dart';

/// Screen 1: Welcome View with Complete 4-Corner Vegetable Entrance Animation
/// - Static Center Branding (Freshly emblem, wordmark, and "Pure Food / Better Life")
/// - 4 Corner Produce Slides:
///   1. Top-Left Corner: Fresh Basil glides in from top-left.
///   2. Top-Right Corner: Crisp Coriander glides in from top-right.
///   3. Mid-Left: Juicy Tomato Slice slides in from left.
///   4. Bottom-Left Corner: Crisp Romaine Lettuce & Spinach glide in from bottom-left.
///   5. Bottom-Right Corner: Ripe Vine Tomatoes & Parsley glide in from bottom-right.
/// - Full edge-to-edge coverage of all four corners without any artifacts or blinking.
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

  // Staggered Slide & Fade Animations for each corner
  late final Animation<Offset> _basilSlide;
  late final Animation<double> _basilFade;
  late final Animation<Offset> _corianderSlide;
  late final Animation<double> _corianderFade;
  late final Animation<Offset> _tomatoSliceSlide;
  late final Animation<double> _tomatoSliceFade;
  late final Animation<Offset> _bottomLeftSlide;
  late final Animation<double> _bottomLeftFade;
  late final Animation<Offset> _bottomRightSlide;
  late final Animation<double> _bottomRightFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    // 1. Top-Left Basil Entrance (0.05 -> 0.60)
    _basilSlide = Tween<Offset>(
      begin: const Offset(-0.80, -0.80),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.05, 0.60, curve: Curves.easeOutCubic),
      ),
    );
    _basilFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.05, 0.40, curve: Curves.easeIn),
    );

    // 2. Top-Right Coriander Entrance (0.15 -> 0.70)
    _corianderSlide = Tween<Offset>(
      begin: const Offset(0.80, -0.80),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.15, 0.70, curve: Curves.easeOutCubic),
      ),
    );
    _corianderFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.15, 0.48, curve: Curves.easeIn),
    );

    // 3. Mid-Left Tomato Slice Entrance (0.28 -> 0.80)
    _tomatoSliceSlide = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.28, 0.80, curve: Curves.easeOutBack),
      ),
    );
    _tomatoSliceFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.28, 0.52, curve: Curves.easeIn),
    );

    // 4. Bottom-Left Corner (Lettuce & Spinach) (0.38 -> 0.90)
    _bottomLeftSlide = Tween<Offset>(
      begin: const Offset(-0.70, 0.70),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.38, 0.90, curve: Curves.easeOutCubic),
      ),
    );
    _bottomLeftFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.38, 0.65, curve: Curves.easeIn),
    );

    // 5. Bottom-Right Corner (Vine Tomatoes & Parsley) (0.45 -> 0.95)
    _bottomRightSlide = Tween<Offset>(
      begin: const Offset(0.70, 0.70),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _bottomRightFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 0.72, curve: Curves.easeIn),
    );

    // Start animation with a post-frame delay so it plays right after page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        if (mounted) {
          _controller.forward(from: 0.0);
        }
      });
    });
  }

  void _replay() {
    _controller.forward(from: 0.0);
  }

  @override
  void dispose() {
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
            // Layer 1: Clean Wood Tabletop Background
            Positioned.fill(
              child: Image.asset(
                'assets/images/wood_table_bg.jpg',
                fit: BoxFit.cover,
              ),
            ),

            // Layer 2: 4-Corner Animated Transparent Produce (Full-Bleed Corner Anchors)
            LayoutBuilder(
              builder: (context, constraints) {
                final screenW = constraints.maxWidth;
                final screenH = constraints.maxHeight;

                return Stack(
                  fit: StackFit.expand,
                  children: [
                    // Corner 1: Top-Left Basil (Anchored to top-left corner)
                    Positioned(
                      top: 0,
                      left: 0,
                      width: screenW * 0.54,
                      height: screenH * 0.30,
                      child: FadeTransition(
                        opacity: _basilFade,
                        child: SlideTransition(
                          position: _basilSlide,
                          child: Image.asset(
                            'assets/images/sprite_basil.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.topLeft,
                          ),
                        ),
                      ),
                    ),

                    // Corner 2: Top-Right Coriander (Anchored to top-right corner)
                    Positioned(
                      top: 0,
                      right: 0,
                      width: screenW * 0.52,
                      height: screenH * 0.34,
                      child: FadeTransition(
                        opacity: _corianderFade,
                        child: SlideTransition(
                          position: _corianderSlide,
                          child: Image.asset(
                            'assets/images/sprite_coriander.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.topRight,
                          ),
                        ),
                      ),
                    ),

                    // Mid-Left: Tomato Slice (Anchored to left edge)
                    Positioned(
                      top: screenH * 0.34,
                      left: 0,
                      width: screenW * 0.28,
                      height: screenH * 0.23,
                      child: FadeTransition(
                        opacity: _tomatoSliceFade,
                        child: SlideTransition(
                          position: _tomatoSliceSlide,
                          child: Image.asset(
                            'assets/images/sprite_tomato_slice.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.centerLeft,
                          ),
                        ),
                      ),
                    ),

                    // Corner 3: Bottom-Left Crisp Lettuce & Spinach (Anchored to bottom-left corner)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      width: screenW * 0.56,
                      height: screenH * 0.36,
                      child: FadeTransition(
                        opacity: _bottomLeftFade,
                        child: SlideTransition(
                          position: _bottomLeftSlide,
                          child: Image.asset(
                            'assets/images/sprite_bottom_left.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomLeft,
                          ),
                        ),
                      ),
                    ),

                    // Corner 4: Bottom-Right Whole Tomatoes & Parsley (Anchored to bottom-right corner)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      width: screenW * 0.56,
                      height: screenH * 0.36,
                      child: FadeTransition(
                        opacity: _bottomRightFade,
                        child: SlideTransition(
                          position: _bottomRightSlide,
                          child: Image.asset(
                            'assets/images/sprite_bottom_right.png',
                            fit: BoxFit.contain,
                            alignment: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            // Layer 3: Static Center Branding (Freshly emblem, logo & text)
            SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Column(
                    children: [
                      // Top Bar: Replay Button + Skip Button
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Replay icon button to easily watch vegetable animation again
                            IconButton(
                              tooltip: 'Replay Vegetable Animation',
                              icon: const Icon(
                                Icons.replay_rounded,
                                color: Color(0xFF166534),
                                size: 22,
                              ),
                              onPressed: _replay,
                            ),

                            // Skip button
                            TextButton(
                              onPressed: widget.onSkip,
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF166534),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 8,
                                ),
                                backgroundColor: Colors.white.withValues(alpha: 0.70),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
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

                      // Static Center Brand Elements
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Dual Leaf Emblem
                          const FreshlyEmblem(size: 104),
                          const SizedBox(height: 14),

                          // Freshly Brand Wordmark
                          Text(
                            'Freshly',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 50,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF0A5832),
                              letterSpacing: -1.2,
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

                      const Spacer(flex: 9),

                      // Bottom 2 Pagination Dots
                      Padding(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Active dot (Screen 1)
                            Container(
                              width: 8.5,
                              height: 8.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFF0A5832),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            // Inactive dot (Screen 2)
                            Container(
                              width: 7.5,
                              height: 7.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFC4D5C8),
                                shape: BoxShape.circle,
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
