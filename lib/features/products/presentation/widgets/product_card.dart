import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/product_entity.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final bool isWishlisted;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;
  final VoidCallback onToggleWishlist;

  const ProductCard({
    super.key,
    required this.product,
    required this.isWishlisted,
    required this.onTap,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  @override
  Widget build(BuildContext context) {
    final originalPrice = Formatters.originalPriceFromDiscount(
      product.price,
      product.discountPercentage,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.lightSurfaceVariant,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Hero(
                          tag: 'product_image_${product.id}',
                          child: CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(
                              child: SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Icon(
                              Icons.image_not_supported_outlined,
                              size: 32,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (product.discountPercentage > 4)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.discountRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: Tooltip(
                        message: isWishlisted
                            ? 'Remove from wishlist'
                            : 'Add to wishlist',
                        child: Semantics(
                          button: true,
                          label: isWishlisted
                              ? 'Remove ${product.title} from wishlist'
                              : 'Add ${product.title} to wishlist',
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              customBorder: const CircleBorder(),
                              onTap: onToggleWishlist,
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.15),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      isWishlisted
                                          ? Icons.favorite_rounded
                                          : Icons.favorite_border_rounded,
                                      size: 17,
                                      color: isWishlisted
                                          ? AppColors.discountRed
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                product.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  height: 1.25,
                  color: AppColors.headingDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                product.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.star_rounded,
                    size: 15,
                    color: AppColors.starYellow,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.headingDark,
                    ),
                  ),
                  Text(
                    ' (${product.rating.toStringAsFixed(1)}k reviews)',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.amberAccent,
                            height: 1.0,
                          ),
                        ),
                        if (product.discountPercentage > 0)
                          Text(
                            Formatters.currency(originalPrice),
                            style: TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey.shade500,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Semantics(
                    button: true,
                    label: 'Add ${product.title} to cart',
                    child: Material(
                      color: product.isOutOfStock
                          ? AppColors.lightSurfaceVariant
                          : AppColors.accent,
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: product.isOutOfStock ? null : onAddToCart,
                        child: SizedBox(
                          width: 38,
                          height: 38,
                          child: Icon(
                            product.isOutOfStock
                                ? Icons.remove_shopping_cart_outlined
                                : Icons.add_rounded,
                            color: product.isOutOfStock
                                ? Colors.grey.shade500
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
