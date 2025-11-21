import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
import '../theme/colors.dart';
class CustomerTicketsScreen extends StatefulWidget {
  const CustomerTicketsScreen({Key? key}) : super(key: key);
  @override
  State<CustomerTicketsScreen> createState() => _CustomerTicketsScreenState();
}
class _CustomerTicketsScreenState extends State<CustomerTicketsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.user != null) {
        context.read<TicketProvider>().fetchTickets(
          customerEmail: auth.user!.email,
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          Expanded(
            child: Consumer<TicketProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (provider.error != null) {
                  return Center(child: Text(provider.error!));
                }
                if (provider.tickets.isEmpty) {
                  return const Center(child: Text('No tickets found'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final t = provider.tickets[index];
                    return ListTile(
                      title: Text(t.subject),
                      subtitle: Text(t.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: _buildStatusChip(t.status),
                    );
                  },
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemCount: provider.tickets.length,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildStatusChip(String status) {
    Color bg = AppColors.muted;
    Color fg = AppColors.mutedForeground;
    switch (status) {
      case 'open':
        bg = Colors.blue.shade50; fg = Colors.blue; break;
      case 'in_progress':
        bg = Colors.orange.shade50; fg = Colors.orange; break;
      case 'resolved':
        bg = Colors.green.shade50; fg = Colors.green; break;
      case 'closed':
        bg = Colors.grey.shade200; fg = Colors.grey; break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(status, style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
