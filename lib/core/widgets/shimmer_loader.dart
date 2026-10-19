import 'package:flutter/material.dart';

class ShimmerProductGrid extends StatefulWidget {
  final int crossAxisCount;
  final int itemCount;

  const ShimmerProductGrid({
    super.key,
    this.crossAxisCount = 2,
    this.itemCount = 6,
  });

  @override
  State<ShimmerProductGrid> createState() => _ShimmerProductGridState();
}

class _ShimmerProductGridState extends State<ShimmerProductGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final opacity = 0.3 + (_controller.value * 0.45);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: widget.crossAxisCount,
            childAspectRatio: 0.66,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: widget.itemCount,
          itemBuilder: (context, index) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: baseColor.withOpacity(opacity),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 80,
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 14,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: baseColor.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 18,
                          width: 60,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(opacity),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Container(
                          height: 34,
                          width: 34,
                          decoration: BoxDecoration(
                            color: baseColor.withOpacity(opacity),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
