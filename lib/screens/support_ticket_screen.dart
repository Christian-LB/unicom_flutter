import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/navigation_bar.dart';
import '../providers/auth_provider.dart';
import '../providers/ticket_provider.dart';
class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({Key? key}) : super(key: key);
  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}
class _SupportTicketScreenState extends State<SupportTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  String issueType = 'general';
  String priority = 'medium';
  String subject = '';
  String description = '';
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.user?.email ?? '';
    final name = auth.user?.name ?? '';
    final provider = context.watch<TicketProvider>();
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Submit Support Ticket', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: name,
                      decoration: const InputDecoration(labelText: 'Name'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      initialValue: email,
                      decoration: const InputDecoration(labelText: 'Email'),
                      readOnly: true,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Subject'),
                      onChanged: (v) => subject = v,
                      validator: (v) => (v == null || v.isEmpty) ? 'Subject is required' : null,
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: issueType,
                      items: const [
                        DropdownMenuItem(value: 'technical', child: Text('Technical')),
                        DropdownMenuItem(value: 'billing', child: Text('Billing')),
                        DropdownMenuItem(value: 'general', child: Text('General')),
                        DropdownMenuItem(value: 'product', child: Text('Product')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => issueType = v ?? issueType),
                      decoration: const InputDecoration(labelText: 'Issue Type'),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: priority,
                      items: const [
                        DropdownMenuItem(value: 'low', child: Text('Low')),
                        DropdownMenuItem(value: 'medium', child: Text('Medium')),
                        DropdownMenuItem(value: 'high', child: Text('High')),
                        DropdownMenuItem(value: 'urgent', child: Text('Urgent')),
                      ],
                      onChanged: (v) => setState(() => priority = v ?? priority),
                      decoration: const InputDecoration(labelText: 'Priority'),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      maxLines: 5,
                      decoration: const InputDecoration(labelText: 'Description (min 5 chars)'),
                      onChanged: (v) => description = v,
                      validator: (v) => (v == null || v.trim().length < 5) ? 'Description must be at least 5 characters' : null,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : () async {
                          if (!_formKey.currentState!.validate()) return;
                          final payload = {
                            'customerName': name,
                            'customerEmail': email,
                            'subject': subject,
                            'issueType': issueType,
                            'priority': priority,
                            'description': description,
                          };
                          final created = await context.read<TicketProvider>().createTicket(payload);
                          if (created != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Ticket submitted')),
                            );
                            Navigator.pop(context);
                          }
                        },
                        child: Text(provider.isLoading ? 'Submitting...' : 'Submit Ticket'),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
