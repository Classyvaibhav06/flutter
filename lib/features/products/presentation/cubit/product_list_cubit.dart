import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_products_usecase.dart';
import 'product_list_state.dart';

class ProductListCubit extends Cubit<ProductListState> {
  static const int pageSize = 20;

  final GetProductsUseCase getProductsUseCase;
  final SearchProductsUseCase searchProductsUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;

  ProductListCubit({
    required this.getProductsUseCase,
    required this.searchProductsUseCase,
    required this.getCategoriesUseCase,
  }) : super(const ProductListState());

  Future<void> initialize() async {
    loadCategories();
    await loadProducts(refresh: true);
  }

  Future<void> loadCategories() async {
    final result = await getCategoriesUseCase();
    result.fold(
      (_) {},
      (categories) => emit(state.copyWith(categories: categories)),
    );
  }

  Future<void> loadProducts({
    bool refresh = false,
    int? delayMs,
  }) async {
    emit(
      state.copyWith(
        status: ProductListStatus.loading,
        errorMessage: null,
      ),
    );

    final query = state.searchQuery.trim();
    final result = query.isNotEmpty
        ? await searchProductsUseCase(
            query: query,
            limit: pageSize,
            skip: 0,
          )
        : await getProductsUseCase(
            limit: pageSize,
            skip: 0,
            sortBy: state.sortOption.sortBy,
            order: state.sortOption.order,
            categorySlug: state.selectedCategorySlug,
            delayMs: delayMs,
          );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductListStatus.failure,
          errorMessage: failure.message,
        ),
      ),
      (page) {
        if (page.products.isEmpty) {
          emit(
            state.copyWith(
              status: ProductListStatus.empty,
              products: const [],
              total: 0,
              hasReachedMax: true,
              isOfflineCache: false,
            ),
          );
        } else {
          emit(
            state.copyWith(
              status: ProductListStatus.success,
              products: page.products,
              total: page.total,
              hasReachedMax: page.hasReachedMax,
              isOfflineCache: page.isFromCache,
            ),
          );
        }
      },
    );
  }

  Future<void> loadMore() async {
    if (state.status == ProductListStatus.loadingMore ||
        state.status == ProductListStatus.loading ||
        state.hasReachedMax ||
        state.isOfflineCache) {
      return;
    }

    emit(state.copyWith(status: ProductListStatus.loadingMore));

    final currentCount = state.products.length;
    final query = state.searchQuery.trim();

    final result = query.isNotEmpty
        ? await searchProductsUseCase(
            query: query,
            limit: pageSize,
            skip: currentCount,
          )
        : await getProductsUseCase(
            limit: pageSize,
            skip: currentCount,
            sortBy: state.sortOption.sortBy,
            order: state.sortOption.order,
            categorySlug: state.selectedCategorySlug,
          );

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProductListStatus.success,
          errorMessage: failure.message,
        ),
      ),
      (page) {
        final combined = [...state.products, ...page.products];
        emit(
          state.copyWith(
            status: ProductListStatus.success,
            products: combined,
            total: page.total,
            hasReachedMax:
                combined.length >= page.total || page.products.isEmpty,
          ),
        );
      },
    );
  }

  Future<void> onSearchChanged(String query) async {
    emit(
      state.copyWith(
        searchQuery: query,
        clearCategory: query.isNotEmpty,
      ),
    );
    await loadProducts(refresh: true);
  }

  Future<void> selectCategory(String? slug) async {
    if (state.selectedCategorySlug == slug) return;
    emit(
      state.copyWith(
        selectedCategorySlug: slug,
        clearCategory: slug == null,
        searchQuery: '',
      ),
    );
    await loadProducts(refresh: true);
  }

  Future<void> selectSortOption(ProductSortOption option) async {
    if (state.sortOption == option) return;
    emit(state.copyWith(sortOption: option));
    await loadProducts(refresh: true);
  }
}
