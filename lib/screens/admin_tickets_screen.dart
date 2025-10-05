import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/ticket_provider.dart';
import '../theme/colors.dart';

class AdminTicketsScreen extends StatefulWidget {
  const AdminTicketsScreen({Key? key}) : super(key: key);

  @override
  State<AdminTicketsScreen> createState() => _AdminTicketsScreenState();
}

class _AdminTicketsScreenState extends State<AdminTicketsScreen> {
  String _statusFilter = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TicketProvider>().fetchTickets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Filter:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _statusFilter.isEmpty ? null : _statusFilter,
                  hint: const Text('All statuses'),
                  items: const [
                    DropdownMenuItem(value: 'open', child: Text('Open')),
                    DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                    DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                    DropdownMenuItem(value: 'closed', child: Text('Closed')),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value ?? '');
                    context.read<TicketProvider>().fetchTickets(status: value);
                  },
                ),
              ],
            ),
          ),
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
                      title: Text('${t.subject} — ${t.customerEmail}'),
                      subtitle: Text(t.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildStatusChip(t.status),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            onPressed: () => _openUpdateDialog(context, t.id),
                          ),
                        ],
                      ),
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

  Future<void> _openUpdateDialog(BuildContext context, String id) async {
    String status = 'in_progress';
    String adminNotes = '';
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: status,
                items: const [
                  DropdownMenuItem(value: 'open', child: Text('Open')),
                  DropdownMenuItem(value: 'in_progress', child: Text('In Progress')),
                  DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
                  DropdownMenuItem(value: 'closed', child: Text('Closed')),
                ],
                onChanged: (v) => status = v ?? status,
                decoration: const InputDecoration(labelText: 'Status'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Admin Notes'),
                onChanged: (v) => adminNotes = v,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                await context.read<TicketProvider>().updateTicket(id, {
                  'status': status,
                  if (adminNotes.isNotEmpty) 'adminNotes': adminNotes,
                });
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}


