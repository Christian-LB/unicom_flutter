import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../theme/colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final auth = context.read<AuthProvider>();
      final quotes = context.read<QuoteProvider>();
      if (auth.isAdmin) {
        quotes.loadAdminQuotes();
      } else if (auth.isCustomer && auth.user != null) {
        quotes.loadCustomerQuotes(auth.user!.email);
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                    // Top container (80% width) with welcome and subtitle
                    Align(
                      alignment: Alignment.center,
                      child: Builder(
                        builder: (context) {
                          final width = MediaQuery.of(context).size.width * 0.8;
                          final displayName = user?.name ?? 'User';
                          return Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, $displayName!',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    color: AppColors.foreground,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Track your orders and manage your account',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.mutedForeground,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (user != null) ...[
                      _UserRoleBar(role: user.role),
                      const SizedBox(height: 24),
                    ],

                    // Centered container with 80% width containing quotes and button
                    Align(
                      alignment: Alignment.center,
                      child: Builder(
                        builder: (context) {
                          final width = MediaQuery.of(context).size.width * 0.8;
                          return Container(
                            width: width,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.shadow,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Quotes',
                                  style: Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 12),
                                _QuotesSection(),
                                const SizedBox(height: 16),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton.icon(
                                    onPressed: () => context.go('/quote'),
                                    icon: const Icon(Icons.request_quote),
                                    label: const Text('Request a Quote'),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRoleBar extends StatelessWidget {
  final String role; // 'admin' or 'customer'
  const _UserRoleBar({required this.role});

  Color _backgroundForRole() {
    // Use app theme colors, vary shade by role
    return role == 'admin' ? AppColors.primaryDark : AppColors.primaryLight;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundForRole(),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_user, color: AppColors.primaryForeground),
              const SizedBox(width: 8),
              Text(
                role == 'admin' ? 'Admin' : 'Customer',
                style: const TextStyle(
                  color: AppColors.primaryForeground,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Text(
            'Logged in',
            style: TextStyle(
              color: AppColors.primaryForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuotesSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<QuoteProvider>(
      builder: (context, quotes, _) {
        if (quotes.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (quotes.quotes.isEmpty) {
          return Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.card,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(16),
            child: const Text(
              'No quote requests yet.',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          );
        }

        // Show up to 5 recent quotes
        final items = quotes.quotes.take(5).toList();
        return Column(
          children: items.map((q) => _QuoteListTile()).toList(),
        );
      },
    );
  }
}

class _QuoteListTile extends StatelessWidget {
  const _QuoteListTile();

  @override
  Widget build(BuildContext context) {
    // This lightweight tile reads the quote via an InheritedWidget-less approach by passing data in list builder
    // For simplicity and theme consistency we'll not add navigation here
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Quote',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Text(
            'View',
            style: TextStyle(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
