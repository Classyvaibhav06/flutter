import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/either.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/domain/entities/category_entity.dart';
import 'package:shopsphere/features/products/domain/entities/product_entity.dart';
import 'package:shopsphere/features/products/domain/usecases/get_products_usecase.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_list_cubit.dart';
import 'package:shopsphere/features/products/presentation/cubit/product_list_state.dart';

class MockGetProductsUseCase extends Mock implements GetProductsUseCase {}

class MockSearchProductsUseCase extends Mock implements SearchProductsUseCase {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

void main() {
  late ProductListCubit cubit;
  late MockGetProductsUseCase mockGetProducts;
  late MockSearchProductsUseCase mockSearchProducts;
  late MockGetCategoriesUseCase mockGetCategories;

  const tProduct = ProductEntity(
    id: 1,
    title: 'iPhone 15',
    description: 'Apple smartphone',
    category: 'smartphones',
    price: 799.0,
    discountPercentage: 5.0,
    rating: 4.8,
    stock: 20,
    brand: 'Apple',
    images: [],
    thumbnail: 'https://dummyjson.com/1.png',
    reviews: [],
  );

  const tPage = PaginatedProductsEntity(
    products: [tProduct],
    total: 50,
    skip: 0,
    limit: 20,
  );

  const tEmptyPage = PaginatedProductsEntity(
    products: [],
    total: 0,
    skip: 0,
    limit: 20,
  );

  setUp(() {
    mockGetProducts = MockGetProductsUseCase();
    mockSearchProducts = MockSearchProductsUseCase();
    mockGetCategories = MockGetCategoriesUseCase();

    cubit = ProductListCubit(
      getProductsUseCase: mockGetProducts,
      searchProductsUseCase: mockSearchProducts,
      getCategoriesUseCase: mockGetCategories,
    );
  });

  tearDown(() => cubit.close());

  group('ProductListCubit BLoC Tests', () {
    blocTest<ProductListCubit, ProductListState>(
      '19. emits [loading, success] when loadProducts succeeds',
      build: () {
        when(
          () => mockGetProducts(
            limit: 20,
            skip: 0,
            sortBy: null,
            order: null,
            categorySlug: null,
            delayMs: null,
          ),
        ).thenAnswer((_) async => const Right(tPage));
        return cubit;
      },
      act: (c) => c.loadProducts(refresh: true),
      expect: () => const [
        ProductListState(status: ProductListStatus.loading),
        ProductListState(
          status: ProductListStatus.success,
          products: [tProduct],
          total: 50,
          hasReachedMax: false,
        ),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      '20. emits [loading, empty] when search returns zero results',
      build: () {
        when(
          () => mockSearchProducts(
            query: 'nonexistent_xyz',
            limit: 20,
            skip: 0,
          ),
        ).thenAnswer((_) async => const Right(tEmptyPage));
        return cubit;
      },
      act: (c) => c.onSearchChanged('nonexistent_xyz'),
      expect: () => const [
        ProductListState(searchQuery: 'nonexistent_xyz'),
        ProductListState(
          status: ProductListStatus.loading,
          searchQuery: 'nonexistent_xyz',
        ),
        ProductListState(
          status: ProductListStatus.empty,
          searchQuery: 'nonexistent_xyz',
          products: [],
          total: 0,
          hasReachedMax: true,
        ),
      ],
    );

    blocTest<ProductListCubit, ProductListState>(
      '21. emits [loading, failure] when getProducts returns NetworkFailure',
      build: () {
        when(
          () => mockGetProducts(
            limit: 20,
            skip: 0,
            sortBy: null,
            order: null,
            categorySlug: null,
            delayMs: null,
          ),
        ).thenAnswer(
          (_) async => const Left(NetworkFailure('No internet connection')),
        );
        return cubit;
      },
      act: (c) => c.loadProducts(refresh: true),
      expect: () => const [
        ProductListState(status: ProductListStatus.loading),
        ProductListState(
          status: ProductListStatus.failure,
          errorMessage: 'No internet connection',
        ),
      ],
    );
  });
}
