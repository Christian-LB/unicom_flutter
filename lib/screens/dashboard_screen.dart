import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/quote_provider.dart';
import '../theme/colors.dart';
import '../models/quote.dart';
import '../utils/export_pdf.dart';
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
    final auth = Provider.of<AuthProvider>(context); 
    final quotes = context.read<QuoteProvider>();
    
    if (auth.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quotes.loadAdminQuotes();
      });
      _initialized = true;
    } else if (auth.isCustomer && auth.user != null) {
      final email = auth.user!.email;
      final userId = auth.user!.id;
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        quotes.loadCustomerQuotes(
          customerEmail: null, 
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
              alignment: Alignment.topCenter, 
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                     final double contentWidth =
                         (constraints.maxWidth * 0.95).clamp(0, 973); 
                    return Container(
                      width: contentWidth,
                      alignment: Alignment.topCenter,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                          if (auth.isAdmin) ...[
                            const Text(
                              'Admin Controls',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.foreground,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _AdminCard(
                                    icon: Icons.inventory_2,
                                    title: 'Products',
                                    subtitle: 'Manage inventory',
                                    color: Colors.blue,
                                    onTap: () => context.go('/admin/products'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AdminCard(
                                    icon: Icons.description,
                                    title: 'Quotes',
                                    subtitle: 'Review requests',
                                    color: Colors.green,
                                    onTap: () => context.go('/admin/quotes'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _AdminCard(
                                    icon: Icons.support_agent,
                                    title: 'Tickets',
                                    subtitle: 'Support requests',
                                    color: Colors.orange,
                                    onTap: () => context.go('/admin/tickets'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                          ],
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
                                if (!auth.isAdmin)
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quote #${quote.id.substring(0, 8)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  quote.status.toUpperCase(),
                  style: TextStyle(
                    color: _getStatusColor(quote.status),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '₱${quote.totalAmount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            color: AppColors.primary,
            tooltip: 'Export PDF',
            onPressed: () {
              exportQuotePdfById(quote.id);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Exporting PDF...'),
                  duration: Duration(seconds: 2),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return AppColors.mutedForeground;
    }
  }
}
class _AdminCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  const _AdminCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.mutedForeground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
