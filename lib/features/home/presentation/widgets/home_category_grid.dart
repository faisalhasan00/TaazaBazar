import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 8-item category grid on HomeScreen
class HomeCategoryGrid extends StatelessWidget {
  final List<Map<String, dynamic>> categories;
  final Function(String categoryId, String title) onCategoryTap;

  const HomeCategoryGrid({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 14,
          childAspectRatio: 0.82,
        ),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isMore = cat['isMore'] == true;

          return GestureDetector(
            onTap: () => onCategoryTap(cat['id'] as String, cat['title'] as String),
            child: Column(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: cat['bg'] as Color? ?? const Color(0xFFEDF7EF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      cat['emoji'] as String,
                      style: TextStyle(
                        fontSize: isMore ? 20 : 26,
                        fontWeight: isMore ? FontWeight.w900 : FontWeight.normal,
                        color: isMore ? const Color(0xFF166534) : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  cat['title'] as String,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
