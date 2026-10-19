import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<void> cacheProducts(List<ProductModel> products);
  Future<List<ProductModel>> getCachedProducts();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  static const String _keyCachedProducts = 'shopsphere_cached_products_v1';

  final SharedPreferences sharedPreferences;

  const ProductLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    final encoded = jsonEncode(products.map((p) => p.toJson()).toList());
    await sharedPreferences.setString(_keyCachedProducts, encoded);
  }

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    final raw = sharedPreferences.getString(_keyCachedProducts);
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(ProductModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
