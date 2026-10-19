import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shopsphere/core/error/exceptions.dart';
import 'package:shopsphere/core/error/failures.dart';
import 'package:shopsphere/features/products/data/datasources/product_local_data_source.dart';
import 'package:shopsphere/features/products/data/datasources/product_remote_data_source.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/data/repositories/product_repository_impl.dart';

class MockProductRemoteDataSource extends Mock
    implements ProductRemoteDataSource {}

class MockProductLocalDataSource extends Mock
    implements ProductLocalDataSource {}

void main() {
  late ProductRepositoryImpl repository;
  late MockProductRemoteDataSource mockRemote;
  late MockProductLocalDataSource mockLocal;

  const tProductModel = ProductModel(
    id: 1,
    title: 'Test Phone',
    description: 'Flagship smartphone',
    category: 'smartphones',
    price: 599.99,
    discountPercentage: 10.0,
    rating: 4.7,
    stock: 15,
    brand: 'TechBrand',
    images: ['https://dummyjson.com/1.png'],
    thumbnail: 'https://dummyjson.com/thumb.png',
    reviews: [],
  );

  const tPaginatedModel = PaginatedProductsModel(
    products: [tProductModel],
    total: 100,
    skip: 0,
    limit: 20,
  );

  setUp(() {
    mockRemote = MockProductRemoteDataSource();
    mockLocal = MockProductLocalDataSource();
    repository = ProductRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  group('ProductRepositoryImpl Tests', () {
    test(
        '5. getProducts returns Right(PaginatedProductsEntity) and caches first page on success',
        () async {
      when(
        () => mockRemote.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
          categorySlug: null,
          delayMs: null,
        ),
      ).thenAnswer((_) async => tPaginatedModel);
      when(() => mockLocal.cacheProducts(any())).thenAnswer((_) async {});

      final result = await repository.getProducts();

      expect(result.isRight, isTrue);
      verify(() => mockLocal.cacheProducts([tProductModel])).called(1);
    });

    test(
        '6. getProducts returns Left(ServerFailure) when remote throws ServerException',
        () async {
      when(
        () => mockRemote.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
          categorySlug: null,
          delayMs: null,
        ),
      ).thenThrow(const ServerException(
          message: 'Internal Server Error', statusCode: 500));

      final result = await repository.getProducts();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<ServerFailure>()),
        (_) => fail('Expected Left(ServerFailure)'),
      );
    });

    test(
        '7. getProducts returns cached products when NetworkException occurs on first page',
        () async {
      when(
        () => mockRemote.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
          categorySlug: null,
          delayMs: null,
        ),
      ).thenThrow(const NetworkException());
      when(() => mockLocal.getCachedProducts())
          .thenAnswer((_) async => [tProductModel]);

      final result = await repository.getProducts();

      expect(result.isRight, isTrue);
      result.fold(
        (_) => fail('Expected cached Right'),
        (data) {
          expect(data.isFromCache, isTrue);
          expect(data.products.first.title, 'Test Phone');
        },
      );
    });

    test(
        '8. getProducts returns Left(NetworkFailure) when offline and cache is empty',
        () async {
      when(
        () => mockRemote.getProducts(
          limit: 20,
          skip: 0,
          sortBy: null,
          order: null,
          categorySlug: null,
          delayMs: null,
        ),
      ).thenThrow(const NetworkException());
      when(() => mockLocal.getCachedProducts())
          .thenAnswer((_) async => const []);

      final result = await repository.getProducts();

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected NetworkFailure'),
      );
    });

    test(
        '9. getProductById returns Left(NotFoundFailure) on 404 NotFoundException',
        () async {
      when(() => mockRemote.getProductById(9999))
          .thenThrow(const NotFoundException());

      final result = await repository.getProductById(9999);

      expect(result.isLeft, isTrue);
      result.fold(
        (failure) => expect(failure, isA<NotFoundFailure>()),
        (_) => fail('Expected NotFoundFailure'),
      );
    });
  });
}
