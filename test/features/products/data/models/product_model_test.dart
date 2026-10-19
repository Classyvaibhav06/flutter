import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/auth/data/models/user_model.dart';
import 'package:shopsphere/features/products/data/models/product_model.dart';
import 'package:shopsphere/features/products/domain/entities/product_entity.dart';
import '../../../../fixtures/fixture_reader.dart';

void main() {
  group('ProductModel & UserModel JSON Parsing Tests', () {
    test('1. ProductModel is a subclass of ProductEntity', () {
      final jsonMap =
          jsonDecode(fixture('product.json')) as Map<String, dynamic>;
      final model = ProductModel.fromJson(jsonMap);
      expect(model, isA<ProductEntity>());
      expect(model.id, 1);
      expect(model.title, 'Essence Mascara Lash Princess');
      expect(model.brand, 'Essence');
      expect(model.reviews.length, 1);
    });

    test('2. ProductModel handles null or absent brand field gracefully', () {
      final jsonMap = <String, dynamic>{
        'id': 42,
        'title': 'Fresh Strawberries',
        'description': 'Organic berries',
        'category': 'groceries',
        'price': 3.99,
        'discountPercentage': 10.0,
        'rating': 4.8,
        'stock': 25,
        'brand': null,
        'images': <String>[],
        'thumbnail': 'https://dummyjson.com/img.png',
      };

      final model = ProductModel.fromJson(jsonMap);
      expect(model.brand, isNull);
      expect(model.title, 'Fresh Strawberries');
      expect(model.isOutOfStock, isFalse);
    });

    test('3. PaginatedProductsModel parses products_page.json fixture', () {
      final jsonMap =
          jsonDecode(fixture('products_page.json')) as Map<String, dynamic>;
      final paginated = PaginatedProductsModel.fromJson(jsonMap);

      expect(paginated.total, 194);
      expect(paginated.limit, 20);
      expect(paginated.skip, 0);
      expect(paginated.products.length, 1);
      expect(paginated.hasReachedMax, isFalse);
    });

    test('4. UserModel parses user.json fixture including tokens', () {
      final jsonMap = jsonDecode(fixture('user.json')) as Map<String, dynamic>;
      final user = UserModel.fromJson(jsonMap);

      expect(user.id, 1);
      expect(user.username, 'emilys');
      expect(user.fullName, 'Emily Johnson');
      expect(user.accessToken, 'mock_access_token_123');
      expect(user.refreshToken, 'mock_refresh_token_456');
    });
  });
}
