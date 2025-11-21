import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_bar.dart';
import '../providers/quote_provider.dart';
import '../theme/colors.dart';
import '../models/quote.dart';
import '../utils/export_pdf.dart';
class AdminQuotesScreen extends StatefulWidget {
  const AdminQuotesScreen({Key? key}) : super(key: key);
  @override
  State<AdminQuotesScreen> createState() => _AdminQuotesScreenState();
}
class _AdminQuotesScreenState extends State<AdminQuotesScreen> {
  String? _selectedStatus;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuoteProvider>().loadAdminQuotes();
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1400),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quote Management',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: AppColors.foreground,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Consumer<QuoteProvider>(
                        builder: (context, provider, child) {
                          return DropdownButtonFormField<String?>(
                            value: _selectedStatus,
                            decoration: InputDecoration(
                              labelText: 'Filter by Status',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              filled: true,
                              fillColor: AppColors.card,
                            ),
                            items: [
                              const DropdownMenuItem(
                                value: null,
                                child: Text('All Statuses'),
                              ),
                              ...provider.statuses.map((status) => DropdownMenuItem(
                                    value: status,
                                    child: Text(status.toUpperCase()),
                                  )),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedStatus = value;
                              });
                              provider.filterByStatus(value);
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      Consumer<QuoteProvider>(
                        builder: (context, provider, child) {
                          if (provider.isLoading) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32),
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                          if (provider.error != null) {
                            return Card(
                              color: Colors.red.shade50,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    const Icon(Icons.error, color: Colors.red),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        provider.error!,
                                        style: const TextStyle(color: Colors.red),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => provider.loadAdminQuotes(),
                                      child: const Text('Retry'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                          final quotes = provider.quotes;
                          if (quotes.isEmpty) {
                            return const Card(
                              child: Padding(
                                padding: EdgeInsets.all(48),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.description_outlined,
                                          size: 64, color: Colors.grey),
                                      SizedBox(height: 16),
                                      Text(
                                        'No quotes found',
                                        style: TextStyle(
                                          fontSize: 18,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          return Card(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  AppColors.muted.withOpacity(0.3),
                                ),
                                columns: const [
                                  DataColumn(label: Text('Quote #')),
                                  DataColumn(label: Text('Customer')),
                                  DataColumn(label: Text('Company')),
                                  DataColumn(label: Text('Total')),
                                  DataColumn(label: Text('Status')),
                                  DataColumn(label: Text('Date')),
                                  DataColumn(label: Text('Actions')),
                                ],
                                rows: quotes.map((quote) {
                                  return DataRow(
                                    cells: [
                                      DataCell(Text(quote.id.substring(0, 8))),
                                      DataCell(
                                        SizedBox(
                                          width: 150,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                quote.customerName,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.w500),
                                              ),
                                              Text(
                                                quote.customerEmail,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: AppColors.mutedForeground,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      DataCell(Text(quote.company ?? '-')),
                                      DataCell(Text('\₱${quote.totalAmount.toStringAsFixed(2)}')),
                                      DataCell(
                                        _buildStatusBadge(quote.status),
                                      ),
                                      DataCell(
                                        Text(
                                          '${quote.createdAt.month}/${quote.createdAt.day}/${quote.createdAt.year}',
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (quote.status == 'pending') ...[
                                              IconButton(
                                                icon: const Icon(Icons.check, size: 20, color: Colors.green),
                                                onPressed: () => _approveQuote(context, quote),
                                                tooltip: 'Approve',
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, size: 20, color: Colors.red),
                                                onPressed: () => _rejectQuote(context, quote),
                                                tooltip: 'Reject',
                                              ),
                                            ],
                                            IconButton(
                                              icon: const Icon(Icons.picture_as_pdf, size: 20),
                                              onPressed: () => exportQuotePdfById(quote.id),
                                              tooltip: 'Export PDF',
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                              onPressed: () => _confirmDelete(context, quote),
                                              tooltip: 'Delete',
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    switch (status) {
      case 'approved':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade900;
        break;
      case 'rejected':
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade900;
        break;
      case 'expired':
        bgColor = Colors.grey.shade100;
        textColor = Colors.grey.shade900;
        break;
      default: 
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade900;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
  Future<void> _approveQuote(BuildContext context, Quote quote) async {
    final provider = context.read<QuoteProvider>();
    final success = await provider.approveQuote(quote.id);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote approved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to approve quote'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _rejectQuote(BuildContext context, Quote quote) async {
    final provider = context.read<QuoteProvider>();
    final success = await provider.rejectQuote(quote.id);
    if (context.mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.error ?? 'Failed to reject quote'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  Future<void> _confirmDelete(BuildContext context, Quote quote) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Quote'),
        content: Text('Are you sure you want to delete quote for "${quote.customerName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final provider = context.read<QuoteProvider>();
      final success = await provider.deleteQuote(quote.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Quote deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (context.mounted) {
        final errorMsg = provider.error ?? 'Failed to delete quote';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
