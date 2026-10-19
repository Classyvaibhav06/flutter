import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';

abstract class CartLocalDataSource {
  Future<List<CartItemModel>> getCartItems();
  Future<void> saveCartItems(List<CartItemModel> items);
  Future<void> clearCart();
}

class CartLocalDataSourceImpl implements CartLocalDataSource {
  static const String _keyCartItems = 'shopsphere_cart_items_v1';

  final SharedPreferences sharedPreferences;

  const CartLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<CartItemModel>> getCartItems() async {
    final jsonString = sharedPreferences.getString(_keyCartItems);
    if (jsonString == null || jsonString.isEmpty) return const [];
    try {
      final decoded = jsonDecode(jsonString) as List<dynamic>;
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(CartItemModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveCartItems(List<CartItemModel> items) async {
    final encoded = jsonEncode(items.map((e) => e.toJson()).toList());
    await sharedPreferences.setString(_keyCartItems, encoded);
  }

  @override
  Future<void> clearCart() async {
    await sharedPreferences.remove(_keyCartItems);
  }
}
