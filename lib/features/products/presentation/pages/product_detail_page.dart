import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../cubit/product_detail_cubit.dart';
import '../cubit/product_detail_state.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;
  final bool isEmbeddedPane;

  const ProductDetailPage({
    super.key,
    required this.productId,
    this.isEmbeddedPane = false,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late final ProductDetailCubit _cubit;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _cubit = sl<ProductDetailCubit>()..loadProduct(widget.productId);
  }

  @override
  void dispose() {
    _cubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final wishlistedIds = context.watch<WishlistCubit>().state;
    final isWishlisted = wishlistedIds.contains(widget.productId);

    return BlocProvider.value(
      value: _cubit,
      child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: !widget.isEmbeddedPane,
              title: Text(
                state is ProductDetailLoaded
                    ? state.product.title
                    : 'Product Details',
              ),
              actions: [
                IconButton(
                  tooltip: 'Toggle wishlist',
                  onPressed: () {
                    context
                        .read<WishlistCubit>()
                        .toggleWishlist(widget.productId);
                  },
                  icon: Icon(
                    isWishlisted
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isWishlisted ? AppColors.discountRed : null,
                  ),
                ),
              ],
            ),
            bottomNavigationBar: state is ProductDetailLoaded
                ? SafeArea(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                IconButton(
                                  tooltip: 'Decrease quantity',
                                  onPressed: state.product.isOutOfStock ||
                                          state.selectedQuantity <= 1
                                      ? null
                                      : () => _cubit.decrementQuantity(),
                                  icon: const Icon(Icons.remove_rounded),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                  ),
                                  child: Text(
                                    '${state.selectedQuantity}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Increase quantity',
                                  onPressed: state.product.isOutOfStock ||
                                          state.selectedQuantity >=
                                              state.product.stock
                                      ? null
                                      : () => _cubit.incrementQuantity(),
                                  icon: const Icon(Icons.add_rounded),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: ElevatedButton.icon(
                              key: const Key('add_to_cart_detail_button'),
                              onPressed: state.product.isOutOfStock
                                  ? null
                                  : () {
                                      context.read<CartCubit>().addItem(
                                            state.product,
                                            state.selectedQuantity,
                                          );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Added ${state.selectedQuantity} × ${state.product.title} to cart',
                                          ),
                                        ),
                                      );
                                    },
                              icon: const Icon(Icons.shopping_bag_outlined),
                              label: Text(
                                state.product.isOutOfStock
                                    ? 'Out of Stock'
                                    : 'Add to Cart • ${Formatters.currency(state.product.price * state.selectedQuantity)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
            body: _buildBody(context, state),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, ProductDetailState state) {
    if (state is ProductDetailLoading || state is ProductDetailInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is ProductDetailNotFound) {
      return EmptyView(
        title: 'Product Not Found (404)',
        subtitle: state.message,
        icon: Icons.sentiment_dissatisfied_rounded,
        actionLabel: widget.isEmbeddedPane ? null : 'Back to Catalogue',
        onAction: widget.isEmbeddedPane
            ? null
            : () => Navigator.of(context).maybePop(),
      );
    }

    if (state is ProductDetailError) {
      return ErrorView(
        message: state.message,
        onRetry: () => _cubit.loadProduct(widget.productId),
      );
    }

    if (state is ProductDetailLoaded) {
      final product = state.product;
      final images =
          product.images.isNotEmpty ? product.images : [product.thumbnail];
      final originalPrice = Formatters.originalPriceFromDiscount(
        product.price,
        product.discountPercentage,
      );

      return SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 290,
              child: Stack(
                children: [
                  PageView.builder(
                    itemCount: images.length,
                    onPageChanged: (idx) =>
                        setState(() => _currentImageIndex = idx),
                    itemBuilder: (context, index) {
                      final imgWidget = CachedNetworkImage(
                        imageUrl: images[index],
                        fit: BoxFit.contain,
                        placeholder: (_, __) => const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.broken_image_outlined,
                          size: 56,
                        ),
                      );
                      if (index == 0) {
                        return Hero(
                          tag: 'product_image_${product.id}',
                          child: imgWidget,
                        );
                      }
                      return imgWidget;
                    },
                  ),
                  if (images.length > 1)
                    Positioned(
                      bottom: 12,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (idx) {
                          final active = idx == _currentImageIndex;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            height: 7,
                            width: active ? 18 : 7,
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.primary
                                  : Colors.grey.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        (product.brand ?? 'Unbranded').toUpperCase(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                      Chip(
                        label: Text(product.category),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: AppColors.amberAccent,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${product.rating.toStringAsFixed(1)} (${product.reviews.length} reviews)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: (product.isOutOfStock
                                  ? AppColors.outOfStockRed
                                  : product.stock < 10
                                      ? AppColors.lowStockOrange
                                      : AppColors.inStockGreen)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.isOutOfStock
                              ? 'Out of Stock'
                              : product.stock < 10
                                  ? 'Low Stock (${product.stock} left)'
                                  : 'In Stock (${product.stock})',
                          style: TextStyle(
                            color: product.isOutOfStock
                                ? AppColors.outOfStockRed
                                : product.stock < 10
                                    ? AppColors.lowStockOrange
                                    : AppColors.inStockGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.currency(product.price),
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                      if (product.discountPercentage > 0) ...[
                        const SizedBox(width: 10),
                        Text(
                          Formatters.currency(originalPrice),
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.discountRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '-${product.discountPercentage.toInt()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Divider(height: 28),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                        ),
                  ),
                  const Divider(height: 28),
                  Text(
                    'Customer Reviews (${product.reviews.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 10),
                  if (product.reviews.isEmpty)
                    const Text('No customer reviews yet.')
                  else
                    ...product.reviews.map(
                      (review) => Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    review.reviewerName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Row(
                                    children: List.generate(
                                      review.rating.clamp(1, 5),
                                      (_) => const Icon(
                                        Icons.star_rounded,
                                        size: 15,
                                        color: AppColors.amberAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(review.comment),
                              if (review.date.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  review.date.split('T').first,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
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
      );
    }

    return const SizedBox.shrink();
  }
}
