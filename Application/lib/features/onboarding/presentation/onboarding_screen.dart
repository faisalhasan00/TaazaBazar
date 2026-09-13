import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../auth/presentation/login_screen.dart';
import '../domain/models/onboarding_item.dart';
import 'widgets/animated_welcome_view.dart';

/// Interactive 2-step Onboarding Flow for Freshly
/// Screen 1: Full-bleed flat-lay produce welcome screen with animated 4-corner vegetables
/// Screen 2: Farm Fresh to Your Home (Wicker basket, fresh produce & leafy accents)
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<OnboardingItem> _items = OnboardingItem.items;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToNextPage() {
    if (_currentPage < _items.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _navigateToLogin();
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOutCubic;
          final tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8F4),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Screen 1: Animated Produce Welcome Screen
            return AnimatedWelcomeView(
              onNext: _goToNextPage,
              onSkip: _navigateToLogin,
            );
          } else {
            // Screen 2: Farm Fresh to Your Home (Matching Reference Design)
            return _buildFarmFreshScreen();
          }
        },
      ),
    );
  }

  /// Screen 2: Farm Fresh to Your Home matching the exact reference design
  Widget _buildFarmFreshScreen() {
    return Container(
      color: const Color(0xFFF4F8F4),
      child: Stack(
        children: [
          // Top-Left Leafy Branch Accent
          Positioned(
            top: 0,
            left: 0,
            child: SizedBox(
              width: 140,
              height: 180,
              child: CustomPaint(
                painter: _TopLeftLeafBranchPainter(),
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),

                      // Title: "Farm Fresh to Your Home"
                      Text(
                        'Farm Fresh\nto Your Home',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF0C5A35),
                          letterSpacing: -0.6,
                          height: 1.18,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        'Get fresh vegetables, dairy and\norganic products delivered to\nyour doorstep.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2E5E3D),
                          letterSpacing: -0.2,
                          height: 1.4,
                        ),
                      ),

                      // Center Farm Fresh Basket Visual
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final maxDim = constraints.maxHeight < constraints.maxWidth
                                    ? constraints.maxHeight
                                    : constraints.maxWidth;
                                final size = (maxDim * 0.92).clamp(180.0, 290.0);

                                return Container(
                                  width: size,
                                  height: size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF0C5A35).withValues(alpha: 0.08),
                                        blurRadius: 28,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/farm_fresh_basket.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),

                      // 2 Pagination Dots (Dot 2 is active)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Inactive dot 1
                          Container(
                            width: 7.5,
                            height: 7.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFC4D5C8),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 7),
                          // Active dot (Screen 2)
                          Container(
                            width: 8.5,
                            height: 8.5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF0C5A35),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Large "Get Started" Primary Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          key: const ValueKey('farm_fresh_get_started_btn'),
                          onPressed: _navigateToLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B6E38),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            'Get Started',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 16.5,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // "Skip" Link Button below
                      TextButton(
                        key: const ValueKey('farm_fresh_skip_btn'),
                        onPressed: _navigateToLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF2E5E3D),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                        ),
                        child: Text(
                          'Skip',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF2E5E3D),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for the delicate top-left organic leaves branch
class _TopLeftLeafBranchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stemPaint = Paint()
      ..color = const Color(0xFF6FAF58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final leafPaint = Paint()
      ..color = const Color(0xFF81C366)
      ..style = PaintingStyle.fill;

    final leafVeinPaint = Paint()
      ..color = const Color(0xFF6FAF58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Stem curve coming from top-left
    final stemPath = Path();
    stemPath.moveTo(-10, -10);
    stemPath.cubicTo(20, 40, 45, 90, 85, 140);
    canvas.drawPath(stemPath, stemPaint);

    // Helper to draw realistic leaf
    void drawLeaf(double x, double y, double width, double height, double angle) {
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(angle);

      final leafPath = Path();
      leafPath.moveTo(0, 0);
      leafPath.cubicTo(width * 0.5, -height * 0.4, width, -height * 0.2, width * 1.1, 0);
      leafPath.cubicTo(width, height * 0.2, width * 0.5, height * 0.4, 0, 0);
      leafPath.close();

      canvas.drawPath(leafPath, leafPaint);

      // Vein
      final veinPath = Path();
      veinPath.moveTo(0, 0);
      veinPath.lineTo(width * 0.95, 0);
      canvas.drawPath(veinPath, leafVeinPaint);

      canvas.restore();
    }

    // Leaf pairs along the stem
    drawLeaf(15, 25, 34, 18, 0.4);
    drawLeaf(22, 12, 38, 20, -0.3);
    drawLeaf(42, 65, 38, 20, 0.6);
    drawLeaf(48, 50, 42, 22, -0.15);
    drawLeaf(72, 110, 36, 18, 0.85);
    drawLeaf(78, 95, 40, 20, 0.1);
    drawLeaf(85, 140, 38, 19, 0.95);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
