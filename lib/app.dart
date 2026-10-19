import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/network/session_manager.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/breakpoints.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/products/presentation/cubit/product_list_cubit.dart';
import 'features/products/presentation/pages/home_page.dart';
import 'features/products/presentation/pages/product_detail_page.dart';
import 'features/profile/presentation/cubit/theme_cubit.dart';
import 'features/profile/presentation/pages/profile_page.dart';
import 'features/wishlist/presentation/cubit/wishlist_cubit.dart';
import 'features/wishlist/presentation/pages/wishlist_page.dart';

class ShopSphereApp extends StatelessWidget {
  const ShopSphereApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (_) => sl<ThemeCubit>()),
        BlocProvider<AuthCubit>(create: (_) => sl<AuthCubit>()),
        BlocProvider<ProductListCubit>(
          create: (_) => sl<ProductListCubit>()..initialize(),
        ),
        BlocProvider<CartCubit>(
          create: (_) => sl<CartCubit>()..loadCart(),
        ),
        BlocProvider<WishlistCubit>(create: (_) => sl<WishlistCubit>()),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'ShopSphere',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: const _AppRouterShell(),
          );
        },
      ),
    );
  }
}

enum _AppRoute { splash, login, main }

class _AppRouterShell extends StatefulWidget {
  const _AppRouterShell();

  @override
  State<_AppRouterShell> createState() => _AppRouterShellState();
}

class _AppRouterShellState extends State<_AppRouterShell> {
  _AppRoute _route = _AppRoute.splash;
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    sl<SessionManager>().expiryMessage.addListener(_onSessionExpired);
  }

  @override
  void dispose() {
    sl<SessionManager>().expiryMessage.removeListener(_onSessionExpired);
    super.dispose();
  }

  void _onSessionExpired() {
    final message = sl<SessionManager>().expiryMessage.value;
    if (message == null || !mounted) return;
    sl<SessionManager>().consume();
    context.read<AuthCubit>().logout();
    setState(() {
      _selectedTabIndex = 0;
      _route = _AppRoute.login;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _openProductDetail(int productId) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailPage(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_route == _AppRoute.splash) {
      return SplashPage(
        onAuthenticated: () => setState(() => _route = _AppRoute.main),
        onUnauthenticated: () => setState(() => _route = _AppRoute.login),
      );
    }

    if (_route == _AppRoute.login) {
      return LoginPage(
        onLoginSuccess: () => setState(() => _route = _AppRoute.main),
      );
    }

    final pages = [
      HomePage(
        onProductSelected: _openProductDetail,
        onCartTap: () => setState(() => _selectedTabIndex = 2),
      ),
      WishlistPage(
        onProductSelected: _openProductDetail,
        onExploreProducts: () => setState(() => _selectedTabIndex = 0),
      ),
      CartPage(
        onExploreProducts: () => setState(() => _selectedTabIndex = 0),
      ),
      ProfilePage(
        onTestNotFoundProduct: _openProductDetail,
        onLoggedOut: () => setState(() {
          _selectedTabIndex = 0;
          _route = _AppRoute.login;
        }),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenSize = Breakpoints.fromWidth(constraints.maxWidth);
        final cartCount = context.watch<CartCubit>().state.summary.totalItems;

        if (screenSize == ScreenSize.compact) {
          return Scaffold(
            body: IndexedStack(
              index: _selectedTabIndex,
              children: pages,
            ),
            bottomNavigationBar: NavigationBar(
              selectedIndex: _selectedTabIndex,
              onDestinationSelected: (idx) =>
                  setState(() => _selectedTabIndex = idx),
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront_rounded),
                  label: 'Home',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.favorite_border_rounded),
                  selectedIcon: Icon(Icons.favorite_rounded),
                  label: 'Saved',
                ),
                NavigationDestination(
                  icon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart_outlined),
                  ),
                  selectedIcon: Badge(
                    isLabelVisible: cartCount > 0,
                    label: Text('$cartCount'),
                    child: const Icon(Icons.shopping_cart_rounded),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline_rounded),
                  selectedIcon: Icon(Icons.person_rounded),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }

        // Medium (600-1024 dp) & Expanded (>1024 dp): NavigationRail
        return Scaffold(
          body: Row(
            children: [
              NavigationRail(
                selectedIndex: _selectedTabIndex,
                onDestinationSelected: (idx) =>
                    setState(() => _selectedTabIndex = idx),
                labelType: NavigationRailLabelType.all,
                destinations: [
                  const NavigationRailDestination(
                    icon: Icon(Icons.storefront_outlined),
                    selectedIcon: Icon(Icons.storefront_rounded),
                    label: Text('Home'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.favorite_border_rounded),
                    selectedIcon: Icon(Icons.favorite_rounded),
                    label: Text('Saved'),
                  ),
                  NavigationRailDestination(
                    icon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_cart_outlined),
                    ),
                    selectedIcon: Badge(
                      isLabelVisible: cartCount > 0,
                      label: Text('$cartCount'),
                      child: const Icon(Icons.shopping_cart_rounded),
                    ),
                    label: const Text('Cart'),
                  ),
                  const NavigationRailDestination(
                    icon: Icon(Icons.person_outline_rounded),
                    selectedIcon: Icon(Icons.person_rounded),
                    label: Text('Profile'),
                  ),
                ],
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: IndexedStack(
                  index: _selectedTabIndex,
                  children: pages,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
