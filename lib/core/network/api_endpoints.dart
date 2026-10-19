class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'https://dummyjson.com';

  // Auth
  static const String login = '/auth/login';
  static const String me = '/auth/me';
  static const String refresh = '/auth/refresh';

  // Products
  static const String products = '/products';
  static const String searchProducts = '/products/search';
  static const String categories = '/products/categories';
  static String productsByCategory(String slug) => '/products/category/$slug';
  static String productById(int id) => '/products/$id';

  // Carts
  static const String addCart = '/carts/add';
  static String userCarts(int userId) => '/carts/user/$userId';

  // Error simulation
  static String simulateStatus(int code) => '/http/$code';
}
