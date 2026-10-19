import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/debouncer.dart';
import '../../../../core/widgets/empty_view.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../../core/widgets/offline_banner.dart';
import '../../../../core/widgets/shimmer_loader.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/presentation/cubit/cart_state.dart';
import '../../../wishlist/presentation/cubit/wishlist_cubit.dart';
import '../../domain/entities/product_entity.dart';
import '../cubit/product_list_cubit.dart';
import '../cubit/product_list_state.dart';
import '../widgets/product_card.dart';
import '../widgets/promo_banner_carousel.dart';
import 'product_detail_page.dart';

class HomePage extends StatefulWidget {
  final void Function(int productId) onProductSelected;
  final VoidCallback onCartTap;

  const HomePage({
    super.key,
    required this.onProductSelected,
    required this.onCartTap,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  int? _masterDetailSelectedId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= (maxScroll - 280)) {
      context.read<ProductListCubit>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _showSortSheet(BuildContext context, ProductSortOption currentSort) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sort Products By',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...ProductSortOption.values.map(
                  (option) => RadioListTile<ProductSortOption>(
                    value: option,
                    groupValue: currentSort,
                    title: Text(option.label),
                    contentPadding: EdgeInsets.zero,
                    onChanged: (selected) {
                      if (selected != null) {
                        context
                            .read<ProductListCubit>()
                            .selectSortOption(selected);
                      }
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleProductTap(ProductEntity product, ScreenSize screenSize) {
    if (screenSize == ScreenSize.expanded) {
      setState(() {
        _masterDetailSelectedId = product.id;
      });
    } else {
      widget.onProductSelected(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Breakpoints.fromWidth(constraints.maxWidth);
        final listWidth = screenSize == ScreenSize.expanded
            ? constraints.maxWidth * 0.56
            : constraints.maxWidth;
        final gridColumns = Breakpoints.gridColumnsForWidth(listWidth);

        return Scaffold(
          appBar: AppBar(
            title: const Text('ShopSphere'),
            actions: [
              BlocBuilder<CartCubit, CartState>(
                builder: (context, state) {
                  final count = state.summary.totalItems;
                  return IconButton(
                    tooltip: 'Shopping Cart',
                    onPressed: widget.onCartTap,
                    icon: Badge(
                      isLabelVisible: count > 0,
                      label: Text('$count'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Row(
            children: [
              Expanded(
                flex: screenSize == ScreenSize.expanded ? 56 : 100,
                child: BlocBuilder<ProductListCubit, ProductListState>(
                  builder: (context, state) {
                    final wishlistedIds = context.watch<WishlistCubit>().state;

                    return RefreshIndicator(
                      onRefresh: () => context
                          .read<ProductListCubit>()
                          .loadProducts(refresh: true),
                      child: CustomScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          if (state.isOfflineCache)
                            SliverToBoxAdapter(
                              child: OfflineBanner(
                                onRetry: () => context
                                    .read<ProductListCubit>()
                                    .loadProducts(refresh: true),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      key: const Key('search_bar_input'),
                                      controller: _searchController,
                                      onChanged: (value) {
                                        _debouncer.run(() {
                                          if (mounted) {
                                            context
                                                .read<ProductListCubit>()
                                                .onSearchChanged(value);
                                          }
                                        });
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Search products...',
                                        prefixIcon:
                                            const Icon(Icons.search_rounded),
                                        suffixIcon: state.searchQuery.isNotEmpty
                                            ? IconButton(
                                                tooltip: 'Clear search',
                                                icon: const Icon(
                                                    Icons.clear_rounded),
                                                onPressed: () {
                                                  _searchController.clear();
                                                  context
                                                      .read<ProductListCubit>()
                                                      .onSearchChanged('');
                                                },
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    height: 48,
                                    width: 48,
                                    child: IconButton.filledTonal(
                                      tooltip: 'Sort products',
                                      onPressed: () => _showSortSheet(
                                          context, state.sortOption),
                                      icon: const Icon(Icons.tune_rounded),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SliverToBoxAdapter(
                            child: SizedBox(
                              height: 46,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: const Text('All'),
                                      selected:
                                          state.selectedCategorySlug == null,
                                      onSelected: (_) => context
                                          .read<ProductListCubit>()
                                          .selectCategory(null),
                                    ),
                                  ),
                                  ...state.categories.map(
                                    (cat) => Padding(
                                      padding: const EdgeInsets.only(right: 8),
                                      child: ChoiceChip(
                                        label: Text(cat.name),
                                        selected: state.selectedCategorySlug ==
                                            cat.slug,
                                        onSelected: (_) => context
                                            .read<ProductListCubit>()
                                            .selectCategory(cat.slug),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (state.searchQuery.isEmpty &&
                              state.selectedCategorySlug == null)
                            const SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.only(top: 10, bottom: 4),
                                child: PromoBannerCarousel(),
                              ),
                            ),
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
                              child: Text(
                                state.searchQuery.isEmpty
                                    ? 'Top Deals For You'
                                    : 'Results for "${state.searchQuery}"',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.headingDark,
                                ),
                              ),
                            ),
                          ),
                          if (state.status == ProductListStatus.loading)
                            SliverToBoxAdapter(
                              child: ShimmerProductGrid(
                                crossAxisCount: gridColumns,
                              ),
                            )
                          else if (state.status == ProductListStatus.failure &&
                              state.products.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: ErrorView(
                                message: state.errorMessage ??
                                    'Failed to load products.',
                                onRetry: () => context
                                    .read<ProductListCubit>()
                                    .loadProducts(refresh: true),
                              ),
                            )
                          else if (state.status == ProductListStatus.empty ||
                              state.products.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: EmptyView(
                                title: 'No products found',
                                subtitle: state.searchQuery.isNotEmpty
                                    ? 'No items matched "${state.searchQuery}".'
                                    : 'No products available in this category.',
                                actionLabel: 'Reset Filters',
                                onAction: () {
                                  _searchController.clear();
                                  context
                                      .read<ProductListCubit>()
                                      .selectCategory(null);
                                },
                              ),
                            )
                          else ...[
                            SliverPadding(
                              padding: const EdgeInsets.all(12),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: gridColumns,
                                  childAspectRatio: 0.66,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final product = state.products[index];
                                    return ProductCard(
                                      product: product,
                                      isWishlisted:
                                          wishlistedIds.contains(product.id),
                                      onTap: () => _handleProductTap(
                                          product, screenSize),
                                      onAddToCart: () {
                                        context
                                            .read<CartCubit>()
                                            .addItem(product, 1);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Added ${product.title} to cart',
                                            ),
                                            duration:
                                                const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                      onToggleWishlist: () {
                                        context
                                            .read<WishlistCubit>()
                                            .toggleWishlist(product.id);
                                      },
                                    );
                                  },
                                  childCount: state.products.length,
                                ),
                              ),
                            ),
                            SliverToBoxAdapter(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20),
                                child: Center(
                                  child: state.status ==
                                          ProductListStatus.loadingMore
                                      ? const CircularProgressIndicator()
                                      : state.hasReachedMax
                                          ? Text(
                                              'All ${state.products.length} products loaded',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall,
                                            )
                                          : const SizedBox.shrink(),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
              if (screenSize == ScreenSize.expanded) ...[
                const VerticalDivider(width: 1),
                Expanded(
                  flex: 44,
                  child: _masterDetailSelectedId == null
                      ? const EmptyView(
                          title: 'Select a product',
                          subtitle:
                              'Choose any item on the left to inspect its details, specifications, and customer reviews.',
                          icon: Icons.touch_app_outlined,
                        )
                      : ProductDetailPage(
                          key: ValueKey(_masterDetailSelectedId),
                          productId: _masterDetailSelectedId!,
                          isEmbeddedPane: true,
                        ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
