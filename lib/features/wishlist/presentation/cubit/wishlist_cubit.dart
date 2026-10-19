import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WishlistCubit extends Cubit<Set<int>> {
  static const String _keyWishlist = 'shopsphere_wishlist_ids_v1';
  final SharedPreferences sharedPreferences;

  WishlistCubit({required this.sharedPreferences}) : super(const {}) {
    _loadWishlist();
  }

  void _loadWishlist() {
    final stored = sharedPreferences.getStringList(_keyWishlist) ?? const [];
    final ids = stored.map(int.tryParse).whereType<int>().toSet();
    emit(ids);
  }

  Future<void> toggleWishlist(int productId) async {
    final updated = Set<int>.from(state);
    if (updated.contains(productId)) {
      updated.remove(productId);
    } else {
      updated.add(productId);
    }
    await sharedPreferences.setStringList(
      _keyWishlist,
      updated.map((e) => e.toString()).toList(),
    );
    emit(updated);
  }
}
