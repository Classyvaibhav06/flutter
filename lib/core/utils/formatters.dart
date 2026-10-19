import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static String currency(double amount) => _currency.format(amount);

  static double originalPriceFromDiscount(
      double price, double discountPercentage) {
    if (discountPercentage <= 0 || discountPercentage >= 100) {
      return price;
    }
    return price / (1 - (discountPercentage / 100.0));
  }
}
