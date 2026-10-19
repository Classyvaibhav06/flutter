import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../cubit/wishlist_cubit.dart';

class WishlistPage extends StatelessWidget {
  final void Function(int productId) onProductSelected;
  final VoidCallback onExploreProducts;

  const WishlistPage({
    super.key,
    required this.onProductSelected,
    required this.onExploreProducts,
  });

  @override
  Widget build(BuildContext context) {
    final wishlistedIds = context.watch<WishlistCubit>().state;
    final productState = context.watch<ProductListCubit>().state;
    final wishlistedProducts = productState.products
        .where((p) => wishlistedIds.contains(p.id))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Wishlist (${wishlistedProducts.length})'),
      ),
      body: wishlistedProducts.isEmpty
          ? EmptyView(
              title: 'No saved favourites',
              subtitle:
                  'Tap the heart icon on any product card to save it here for quick access.',
              icon: Icons.favorite_border_rounded,
              actionLabel: 'Browse Catalogue',
              onAction: onExploreProducts,
            )
          : GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 240,
                childAspectRatio: 0.66,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: wishlistedProducts.length,
              itemBuilder: (context, index) {
                final product = wishlistedProducts[index];
                return ProductCard(
                  product: product,
                  isWishlisted: true,
                  onTap: () => onProductSelected(product.id),
                  onAddToCart: () {
                    context.read<CartCubit>().addItem(product, 1);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Added ${product.title} to cart'),
                      ),
                    );
                  },
                  onToggleWishlist: () {
                    context.read<WishlistCubit>().toggleWishlist(product.id);
                  },
                );
              },
            ),
    );
  }
}
