import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../cubit/cart_cubit.dart';
import '../cubit/cart_state.dart';

class CartPage extends StatelessWidget {
  final VoidCallback onExploreProducts;

  const CartPage({
    super.key,
    required this.onExploreProducts,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CartCubit, CartState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }

        if (state.completedOrder != null) {
          final order = state.completedOrder!;
          showDialog<void>(
            context: context,
            barrierDismissible: false,
            builder: (dialogContext) => AlertDialog(
              icon: const CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primaryContainer,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('Order Placed Successfully!'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Order #${order.orderId} has been confirmed via DummyJSON.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Total Paid: ${Formatters.currency(order.discountedTotal)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    context.read<CartCubit>().clearCompletedOrder();
                    Navigator.of(dialogContext).pop();
                    onExploreProducts();
                  },
                  child: const Text('Continue Shopping'),
                ),
              ],
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Shopping Cart (${state.summary.totalItems})'),
            actions: [
              if (state.items.isNotEmpty)
                IconButton(
                  tooltip: 'Clear cart',
                  onPressed: () => context.read<CartCubit>().clearCart(),
                  icon: const Icon(Icons.delete_sweep_outlined),
                ),
            ],
          ),
          body: state.items.isEmpty
              ? EmptyView(
                  title: 'Your cart is empty',
                  subtitle:
                      'Browse our catalogue and add items to your cart to get started.',
                  icon: Icons.shopping_cart_outlined,
                  actionLabel: 'Explore Products',
                  onAction: onExploreProducts,
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = state.items[index];
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: SizedBox(
                                      width: 68,
                                      height: 68,
                                      child: CachedNetworkImage(
                                        imageUrl: item.thumbnail,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const ColoredBox(
                                          color: Color(0xFFEFEFEF),
                                          child: Center(
                                            child: SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          ),
                                        ),
                                        errorWidget: (_, __, ___) => const Icon(
                                          Icons.image_not_supported_outlined,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Formatters.currency(item.price),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        tooltip: 'Decrease quantity',
                                        onPressed: () => context
                                            .read<CartCubit>()
                                            .updateQuantity(
                                              item.productId,
                                              item.quantity - 1,
                                            ),
                                        icon: Icon(
                                          item.quantity == 1
                                              ? Icons.delete_outline_rounded
                                              : Icons.remove_circle_outline,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        tooltip: 'Increase quantity',
                                        onPressed: () => context
                                            .read<CartCubit>()
                                            .updateQuantity(
                                              item.productId,
                                              item.quantity + 1,
                                            ),
                                        icon: const Icon(
                                          Icons.add_circle_outline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Subtotal'),
                                Text(Formatters.currency(
                                    state.summary.subtotal)),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Discount Savings',
                                  style:
                                      TextStyle(color: AppColors.discountRed),
                                ),
                                Text(
                                  '-${Formatters.currency(state.summary.totalDiscount)}',
                                  style: const TextStyle(
                                    color: AppColors.discountRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Grand Total',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  Formatters.currency(state.summary.grandTotal),
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              key: const Key('place_order_button'),
                              onPressed: state.isPlacingOrder
                                  ? null
                                  : () {
                                      final authState =
                                          context.read<AuthCubit>().state;
                                      final userId =
                                          authState is AuthAuthenticated
                                              ? (authState.user?.id ?? 1)
                                              : 1;
                                      context
                                          .read<CartCubit>()
                                          .checkout(userId: userId);
                                    },
                              child: state.isPlacingOrder
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'Place Order',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        );
      },
    );
  }
}
