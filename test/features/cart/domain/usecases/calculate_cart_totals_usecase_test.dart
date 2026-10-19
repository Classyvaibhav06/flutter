import 'package:flutter_test/flutter_test.dart';
import 'package:shopsphere/features/cart/domain/entities/cart_item_entity.dart';
import 'package:shopsphere/features/cart/domain/usecases/calculate_cart_totals_usecase.dart';

void main() {
  const useCase = CalculateCartTotalsUseCase();

  group('CalculateCartTotalsUseCase Tests', () {
    test('13. returns zero summary for empty cart', () {
      final summary = useCase(const []);

      expect(summary.subtotal, 0.0);
      expect(summary.totalDiscount, 0.0);
      expect(summary.grandTotal, 0.0);
      expect(summary.totalItems, 0);
    });

    test('14. calculates accurate subtotal and grandTotal without discount',
        () {
      const items = [
        CartItemEntity(
          productId: 1,
          title: 'Organic Honey',
          price: 15.0,
          discountPercentage: 0.0,
          thumbnail: '',
          quantity: 3,
          stock: 20,
        ),
      ];

      final summary = useCase(items);

      expect(summary.subtotal, 45.0);
      expect(summary.totalDiscount, 0.0);
      expect(summary.grandTotal, 45.0);
      expect(summary.totalItems, 3);
    });

    test('15. calculates accurate discount savings when discountPercentage > 0',
        () {
      // Price is $10 after a 50% discount -> original price was $20
      const items = [
        CartItemEntity(
          productId: 2,
          title: 'Mango Juice',
          price: 10.0,
          discountPercentage: 50.0,
          thumbnail: '',
          quantity: 2,
          stock: 10,
        ),
      ];

      final summary = useCase(items);

      expect(summary.subtotal, 40.0);
      expect(summary.totalDiscount, 20.0);
      expect(summary.grandTotal, 20.0);
      expect(summary.totalItems, 2);
    });
  });
}
