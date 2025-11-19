import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../theme/colors.dart';
import '../models/quote.dart';

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

    if (_initialized) return;

    final auth = Provider.of<AuthProvider>(context); // listen for auth/user changes
    final quotes = context.read<QuoteProvider>();

    if (auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quotes.loadAdminQuotes();
      });
      _initialized = true;
    } else if (auth.isCustomer && auth.user != null) {
      // Load quotes filtered by the logged-in user's email/name
      final email = auth.user!.email;
      final userId = auth.user!.id;
      print('DEBUG: Dashboard loading quotes for userId: $userId, email: $email');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quotes.loadCustomerQuotes(
          customerEmail: null, // Rely on userId to avoid potential email mismatch
          userId: userId,
        );
      });
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
            child: Align(
              alignment: Alignment.topCenter, // Move content upward
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                     final double contentWidth =
                         (constraints.maxWidth * 0.95).clamp(0, 973); // 90% width, max 1024

                    return Container(
                      width: contentWidth,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Welcome container
                          Container(
                            width: double.infinity,
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Welcome back, ${user?.name ?? 'User'}!',
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
                          ),

                          const SizedBox(height: 12),

                          if (user != null) ...[
                            _UserRoleBar(role: user.role),
                            const SizedBox(height: 12),
                          ],

                          // Recent Quotes container
                          Container(
                            width: double.infinity,
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
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Recent Quotes',
                                  style:
                                      Theme.of(context).textTheme.headlineLarge,
                                ),
                                const SizedBox(height: 12),
                                const _QuotesSection(),
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
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserRoleBar extends StatelessWidget {
  final String role;
  const _UserRoleBar({required this.role});

  Color _backgroundForRole() {
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
              const Icon(Icons.verified_user,
                  color: AppColors.primaryForeground),
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
            style: TextStyle(color: AppColors.primaryForeground),
          ),
        ],
      ),
    );
  }
}

class _QuotesSection extends StatelessWidget {
  const _QuotesSection();

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

        final items = quotes.quotes.take(5).toList();
        return Column(
          children: items.map((q) => _QuoteListTile(quote: q)).toList(),
        );
      },
    );
  }
}

class _QuoteListTile extends StatelessWidget {
  final Quote quote;

  const _QuoteListTile({required this.quote});

  @override
  Widget build(BuildContext context) {
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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quote #${quote.id}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                quote.status,
                style: const TextStyle(color: AppColors.mutedForeground),
              ),
            ],
          ),
          Text(
            '₱${quote.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
