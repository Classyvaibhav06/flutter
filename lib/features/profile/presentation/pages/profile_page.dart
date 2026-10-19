import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../products/presentation/cubit/product_list_cubit.dart';
import '../cubit/theme_cubit.dart';

class ProfilePage extends StatelessWidget {
  final void Function(int productId) onTestNotFoundProduct;
  final VoidCallback onLoggedOut;

  const ProfilePage({
    super.key,
    required this.onTestNotFoundProduct,
    required this.onLoggedOut,
  });

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<ThemeCubit>().state;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            tooltip: 'Refresh profile',
            onPressed: () => context.read<AuthCubit>().checkSession(),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            onLoggedOut();
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is AuthFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () => context.read<AuthCubit>().checkSession(),
            );
          }

          final user = state is AuthAuthenticated ? state.user : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 44,
                              backgroundColor: colorScheme.primaryContainer,
                              child: user != null && user.image.isNotEmpty
                                  ? ClipOval(
                                      child: CachedNetworkImage(
                                        imageUrl: user.image,
                                        width: 88,
                                        height: 88,
                                        fit: BoxFit.cover,
                                        placeholder: (_, __) =>
                                            const ColoredBox(
                                          color: Color(0xFFEFEFEF),
                                        ),
                                        errorWidget: (_, __, ___) => const Icon(
                                          Icons.person_rounded,
                                          size: 44,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person_rounded,
                                      size: 44,
                                      color: colorScheme.primary,
                                    ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              user?.fullName.isNotEmpty == true
                                  ? user!.fullName
                                  : 'Emily Johnson',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '@${user?.username ?? 'emilys'}',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Divider(height: 28),
                            ListTile(
                              leading: const Icon(Icons.email_outlined),
                              title: const Text('Email'),
                              subtitle: Text(
                                user?.email ?? 'emily.johnson@x.dummyjson.com',
                              ),
                            ),
                            ListTile(
                              leading: const Icon(Icons.phone_outlined),
                              title: const Text('Phone'),
                              subtitle: Text(
                                user?.phone ?? '+81 965-431-3024',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Appearance',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SegmentedButton<ThemeMode>(
                              segments: const [
                                ButtonSegment(
                                  value: ThemeMode.system,
                                  icon: Icon(Icons.brightness_auto_rounded),
                                  label: Text('System'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.light,
                                  icon: Icon(Icons.light_mode_rounded),
                                  label: Text('Light'),
                                ),
                                ButtonSegment(
                                  value: ThemeMode.dark,
                                  icon: Icon(Icons.dark_mode_rounded),
                                  label: Text('Dark'),
                                ),
                              ],
                              selected: {themeMode},
                              onSelectionChanged: (selection) {
                                context
                                    .read<ThemeCubit>()
                                    .setThemeMode(selection.first);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Error Handling Verification Lab',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Simulate DummyJSON error & slow network scenarios:',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () => onTestNotFoundProduct(9999),
                                  icon: const Icon(Icons.search_off_rounded),
                                  label: const Text('404 (/products/9999)'),
                                ),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    context
                                        .read<ProductListCubit>()
                                        .loadProducts(delayMs: 3000);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Triggered GET /products?delay=3000',
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.timer_outlined),
                                  label: const Text('Slow Network (3s)'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      key: const Key('logout_button'),
                      onPressed: () {
                        context.read<AuthCubit>().logout();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.error,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text(
                        'Log Out',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
