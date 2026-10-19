# ShopSphere — Flutter E-Commerce Catalogue App
**Prosessed · Flutter Developer Intern Technical Assignment**

[![Flutter](https://img.shields.io/badge/Flutter-3.24.3_Stable-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3_Stable-0175C2?logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/State_Management-flutter__bloc_(Cubit)-blue)]()
[![Architecture](https://img.shields.io/badge/Architecture-Clean_Architecture-success)]()
[![Tests](https://img.shields.io/badge/Tests-21_Passing-brightgreen)]()

---

## 1. Title & Overview
**ShopSphere** is a production-quality Flutter e-commerce catalogue application powered by the **DummyJSON REST API** (`https://dummyjson.com`). It enables users to sign in with JWT token management and automatic token refresh, browse a paginated product catalogue with infinite scroll and pull-to-refresh, search products with a 400 ms debounce, filter by category, sort by price/rating/title, inspect rich product details with image carousels and customer reviews, manage a locally persisted shopping cart, place simulated orders, and customize appearance across phone, tablet, portrait, and landscape layouts.

- **Release APK**: `[Attach Google Drive / GitHub Release v1.0.0 APK link here]`
- **Demo Video (2–4 min walkthrough)**: `[Attach Google Drive screen recording link here]`

---

## 2. Screenshots

| Splash & Login | Home Catalogue (Phone) | Product Details & Reviews | Cart & Order Confirmation |
| :---: | :---: | :---: | :---: |
| `screenshots/01_login.png` | `screenshots/02_home_phone.png` | `screenshots/03_product_detail.png` | `screenshots/04_cart_checkout.png` |

| Tablet NavigationRail (Medium) | Tablet Master–Detail Split View (Expanded) |
| :---: | :---: |
| `screenshots/05_tablet_medium.png` | `screenshots/06_tablet_master_detail.png` |

---

## 3. Features Checklist

### Mandatory (`[Must]`) Features
- [x] **Splash & Session Routing**: Checks stored session in `FlutterSecureStorage` and routes to Home or Login.
- [x] **Login & Validation**: Username & password fields, inline form validation (empty checks, minimum length), password visibility toggle, submit button loading state, and 1-tap Demo Auto-Fill (`emilys` / `emilyspass`).
- [x] **Secure Token Storage**: Calls `POST /auth/login` and stores `accessToken` & `refreshToken` in `flutter_secure_storage`.
- [x] **Invalid Credentials Handling**: Displays clear inline error banner on HTTP 400 (`Invalid credentials`).
- [x] **Paginated Product Grid**: Responsive grid showing thumbnail, title, price, discount percentage badge, and star rating.
- [x] **Infinite Scroll (`limit=20`, `skip=N`)**: Bottom loading indicator and automatic stop when all items are loaded.
- [x] **Pull-to-Refresh**: Refresh indicator on the product catalogue.
- [x] **Category Filtering**: Horizontal category chips dynamically loaded from `GET /products/categories`.
- [x] **Debounced Search (400 ms)**: Searches `GET /products/search?q=...` using a custom `Debouncer`.
- [x] **Multi-Option Sorting**: Sort by Price Low-to-High, Price High-to-Low, Rating, and Title (A–Z).
- [x] **Skeleton Shimmer & Empty State**: Shimmer placeholders during first load and dedicated `EmptyView` when no results match.
- [x] **Product Details & Reviews**: Image carousel with page indicator, null-safe `brand` handling, discount pricing, stock badge, description, and customer reviews list.
- [x] **Quantity Selector & Stock Guard**: Increment/decrement quantity bounded by stock; disabled when out of stock.
- [x] **Graceful 404 Handling**: Friendly "Product Not Found (404)" state for `/products/9999`.
- [x] **Persistent Shopping Cart**: Add, remove, and update item quantities; computes subtotal, discount savings, and grand total; persisted locally across app restarts.
- [x] **Real-Time Cart Badge**: Live item count badge on the `NavigationBar`, `NavigationRail`, and `AppBar`.
- [x] **Order Placement (`POST /carts/add`)**: Submits order to DummyJSON, displays Order Confirmation dialog, and clears local cart.
- [x] **User Profile (`GET /auth/me`)**: Displays user avatar, full name, username, email, and phone; supports clean logout and forced logout on 401/403.

### Bonus (`[Bonus]`) Features Implemented
- [x] **Automatic Token Refresh Interceptor**: `AuthInterceptor` intercepts 401 responses, calls `POST /auth/refresh`, saves the new token, and transparently retries the original request.
- [x] **Hero Animation**: Smooth `Hero` transition from product card thumbnail to the product details carousel.
- [x] **Persisted Light / Dark / System Theme Toggle**: Managed via `ThemeCubit` and stored in `shared_preferences`.
- [x] **Local Wishlist / Favourites**: Persisted locally with instant heart toggle on product cards and details.
- [x] **Offline Mode & Product Caching**: Caches the first product page locally; displays an `OfflineBanner` ("You are offline. Showing cached catalogue.") when disconnected.
- [x] **GitHub Actions CI Workflow**: Automated `.github/workflows/ci.yml` running `dart format`, `flutter analyze`, and `flutter test --coverage`.

---

## 4. Tech Stack

- **Flutter SDK**: `3.24.3` (stable) · **Dart SDK**: `3.5.3` (null-safe)
- **`flutter_bloc` (`^8.1.6`) & `equatable` (`^2.0.5`)**: Predictable, testable Cubit state management with value equality.
- **`get_it` (`^8.0.0`)**: Lightweight service locator for Clean Architecture dependency injection.
- **`dio` (`^5.7.0`)**: Configured HTTP client with connect/receive timeouts, debug logging, and token refresh interceptor.
- **`flutter_secure_storage` (`^9.2.2`)**: Encrypted storage for `accessToken` and `refreshToken`.
- **`shared_preferences` (`^2.3.2`)**: Local persistence for shopping cart items, wishlist IDs, offline product cache, and theme mode.
- **`cached_network_image` (`^3.4.1`)**: Disk and memory cached product thumbnails and carousel images with placeholders.
- **`bloc_test` (`^9.1.7`) & `mocktail` (`^1.0.4`)**: Unit testing for Cubits, UseCases, and Repositories with null-safe mocks.

---

## 5. Architecture

The codebase follows **Clean Architecture** organised **feature-first**, with each feature split into `domain`, `data`, and `presentation` layers. The `domain` layer is 100% pure Dart with zero Flutter or HTTP imports.

```
lib/
├── core/
│   ├── di/                # GetIt service locator (injection_container.dart)
│   ├── error/             # Either<L,R>, Exceptions, and Equatable Failures
│   ├── network/           # DioClient, AuthInterceptor, ApiEndpoints
│   ├── theme/             # Material 3 AppTheme & AppColors
│   ├── utils/             # Debouncer (400ms), Formatters, Breakpoints
│   └── widgets/           # ErrorView, EmptyView, ShimmerProductGrid, OfflineBanner
├── features/
│   ├── auth/
│   │   ├── data/          # UserModel, AuthRemoteDataSource, AuthLocalDataSource, AuthRepositoryImpl
│   │   ├── domain/        # UserEntity, AuthRepository, Login/CheckAuth/GetCurrentUser/Logout UseCases
│   │   └── presentation/  # AuthCubit, AuthState, SplashPage, LoginPage
│   ├── products/
│   │   ├── data/          # ProductModel, CategoryModel, Remote & Local DataSources, ProductRepositoryImpl
│   │   ├── domain/        # ProductEntity, CategoryEntity, ProductRepository, UseCases
│   │   └── presentation/  # ProductListCubit, ProductDetailCubit, HomePage, ProductDetailPage, Widgets
│   ├── cart/
│   │   ├── data/          # CartItemModel, OrderResponseModel, Local & Remote DataSources, CartRepositoryImpl
│   │   ├── domain/        # CartItemEntity, CartSummaryEntity, CalculateCartTotals & PlaceOrder UseCases
│   │   └── presentation/  # CartCubit, CartState, CartPage
│   ├── profile/
│   │   └── presentation/  # ThemeCubit, ProfilePage (with Error Verification Lab)
│   └── wishlist/
│       └── presentation/  # WishlistCubit, WishlistPage
├── app.dart               # Root MaterialApp + Responsive NavigationBar / NavigationRail shell
└── main.dart              # Entry point
```

### Data Flow (UI → Cubit → UseCase → Repository → Dio → UI)
```
[HomePage Widget]
       │  calls loadProducts() / onSearchChanged()
       ▼
[ProductListCubit]
       │  invokes pure Dart UseCase
       ▼
[GetProductsUseCase]
       │  calls abstract contract
       ▼
[ProductRepositoryImpl]
       ├──► (Online)  ProductRemoteDataSource (Dio) ──► caches Page 1 in ProductLocalDataSource
       └──► (Offline) falls back to ProductLocalDataSource cached items
       │  returns Either<Failure, PaginatedProductsEntity>
       ▼
[ProductListCubit] emits ProductListState (loading / success / empty / failure)
       │
       ▼
[BlocBuilder in HomePage] rebuilds UI declaratively
```

---

## 6. State Management
We chose **`flutter_bloc` (Cubit)** across the entire app because it enforces a strict unidirectional data flow, cleanly separates UI from business logic, and pairs naturally with `Equatable` state classes (`initial`, `loading`, `success`, `empty`, `loadingMore`, `failure`). Compared to raw `Provider`, `Cubit` provides deterministic state transitions that can be verified sequence-by-sequence with `bloc_test`, while avoiding the verbose event boilerplate of full BLoCs for straightforward CRUD and pagination flows.

---

## 7. Error Handling
Low-level `DioException` and `SocketException` errors are caught in `DioClient.mapDioException` and converted into typed data-layer exceptions (`NetworkException`, `ServerException`, `UnauthorizedException`, `NotFoundException`). Repositories catch these exceptions and return a functional `Either<Failure, T>` (`Left(NetworkFailure)`, `Left(ServerFailure)`, `Left(NotFoundFailure)`, `Left(UnauthorizedFailure)`). Every screen maps `Failure` states to reusable `ErrorView` or `EmptyView` widgets with a **Retry** button—never exposing raw stack traces.

---

## 8. Getting Started

### Prerequisites
- Flutter SDK `>=3.24.0` (`flutter --version`)
- Android Studio / Android SDK (API 26+)

### Commands
```bash
# 1. Clone the repository
git clone https://github.com/<username>/prosessed-flutter-assignment.git
cd prosessed-flutter-assignment

# 2. Fetch dependencies
flutter pub get

# 3. Verify static analysis & formatting
flutter analyze
dart format --output=none --set-exit-if-changed lib test

# 4. Run the app in debug mode
flutter run

# 5. Build the release Android APK
flutter build apk --release
```

---

## 9. Testing
Run the full unit and Cubit test suite:
```bash
flutter test --coverage
```

- **Total Unit & Cubit Tests**: **21 passing tests** across 6 test files:
  - `product_model_test.dart` (4 tests): JSON fixture parsing, null `brand` handling, pagination metadata, user token model.
  - `product_repository_impl_test.dart` (5 tests): Success + caching, HTTP 500 `ServerFailure`, offline `NetworkException` cache fallback, empty cache `NetworkFailure`, and 404 `NotFoundFailure`.
  - `login_usecase_test.dart` (3 tests): Empty username validation, short password validation, and valid repository delegation.
  - `calculate_cart_totals_usecase_test.dart` (3 tests): Empty cart summary, multi-quantity subtotal, and percentage discount calculation.
  - `auth_cubit_test.dart` (3 `bloc_test` cases): Login success state sequence, HTTP 400 failure state sequence, and logout flow.
  - `product_list_cubit_test.dart` (3 `bloc_test` cases): Paginated load success, zero-result search `empty` state, and network failure state.

---

## 10. Test Credentials
- **Username**: `emilys`
- **Password**: `emilyspass`
*(Tip: Tap the **"Auto Fill"** button on the Login screen to populate these credentials immediately.)*

---

## 11. Assumptions & Trade-offs
- **Simulated Backend Writes**: DummyJSON simulates `POST /carts/add` and returns a realistic `201` order payload without persisting it server-side; therefore, cart persistence is managed locally via `SharedPreferences`.
- **Category Sorting**: DummyJSON's `/products/category/{slug}` endpoint supports `limit`, `skip`, `sortBy`, and `order`, which we pass directly from `ProductListCubit`.
- **Built-in Error Verification Lab**: To make grading and screen-recording error scenarios effortless, we included an **Error Handling Verification Lab** card on the Profile page that triggers `/products/9999` (404) and `/products?delay=3000` (slow network) with one tap.
- **AI Tools**: An AI coding assistant (ZCode) was used for scaffolding boilerplate, generating unit-test scaffolds, and polishing UI code. All architecture decisions, code review, feature wiring, and final verification (`flutter analyze`, `flutter test`) were done personally, and every line has been reviewed for understanding.

---

## 12. Author
- **Name**: Vaibhav Ghoshi
- **Email**: ghoshivaibhav12@gmail.com
- **GitHub**: `https://github.com/vaibhavghoshi`
