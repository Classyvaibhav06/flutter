import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class PromoBannerCarousel extends StatefulWidget {
  const PromoBannerCarousel({super.key});

  @override
  State<PromoBannerCarousel> createState() => _PromoBannerCarouselState();
}

class _PromoBannerCarouselState extends State<PromoBannerCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<_BannerItem> _banners = [
    _BannerItem(
      badge: 'FRESH & FAST',
      title: 'Active Summer\nWith Juice Milk 300ml',
      subtitle:
          'A new way to make everyday meals feel fun, relaxed and summer-fresh.',
      cta: 'Shop Now',
      size: 84,
      colors: [Color(0xFF97C28E), Color(0xFF6E9E68)],
      badgeBg: Color(0xFF37582F),
      graphicBg: Color(0xFFEFF3D8),
      accent: Color(0xFF37582F),
      label: 'Active Summer',
    ),
    _BannerItem(
      badge: '20% SALE OFF',
      title: 'Everything Fresh,\nDelivered Today',
      subtitle:
          'Snap up seasonal fruits, veggies and pantry picks at big discounts.',
      cta: 'Grab Deal',
      size: 96,
      colors: [Color(0xFFF5B829), Color(0xFFEF9E12)],
      badgeBg: Color(0xFF4A3803),
      graphicBg: Color(0xFFFFF0C2),
      accent: Color(0xFF5A4200),
      label: 'Mega Sale',
    ),
    _BannerItem(
      badge: 'FREE DELIVERY',
      title: 'Weekend Groceries\nOn the House',
      subtitle: 'Free express shipping on all orders placed this weekend only.',
      cta: 'Order Now',
      size: 90,
      colors: [Color(0xFFB7D6E8), Color(0xFF8FB6D3)],
      badgeBg: Color(0xFF24455A),
      graphicBg: Color(0xFFEAF3F9),
      accent: Color(0xFF24455A),
      label: 'Free Shipping',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (context, index) {
              final banner = _banners[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: LinearGradient(
                      colors: banner.colors,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left copy
                      Expanded(
                        flex: 60,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 16, 4, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: banner.badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  banner.badge,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                banner.title,
                                style: TextStyle(
                                  color: banner.accent,
                                  fontSize: 19,
                                  height: 1.25,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Flexible(
                                child: Text(
                                  banner.subtitle,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: banner.accent.withOpacity(0.75),
                                    fontSize: 11.5,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Material(
                                color: banner.accent,
                                borderRadius: BorderRadius.circular(10),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(10),
                                  onTap: () {},
                                  child: const Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 7,
                                    ),
                                    child: Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Right graphic
                      Expanded(
                        flex: 40,
                        child: Container(
                          margin: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: banner.graphicBg,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Center(
                            child: _BannerGraphic(
                                label: banner.label, size: banner.size),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (index) {
            final isSelected = index == _currentPage;
            return GestureDetector(
              onTap: () => _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                height: 6,
                width: isSelected ? 22 : 6,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accent
                      : AppColors.headingDark.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _BannerGraphic extends StatelessWidget {
  final String label;
  final double size;

  const _BannerGraphic({required this.label, required this.size});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.local_drink_rounded,
          size: size,
          color: AppColors.headingDark.withOpacity(0.35),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.6,
            color: AppColors.headingDark.withOpacity(0.45),
          ),
        ),
      ],
    );
  }
}

class _BannerItem {
  final String badge;
  final String title;
  final String subtitle;
  final String cta;
  final double size;
  final List<Color> colors;
  final Color badgeBg;
  final Color graphicBg;
  final Color accent;
  final String label;

  const _BannerItem({
    required this.badge,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.size,
    required this.colors,
    required this.badgeBg,
    required this.graphicBg,
    required this.accent,
    required this.label,
  });
}
