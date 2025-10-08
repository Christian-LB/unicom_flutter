import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import 'package:go_router/go_router.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Support',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Need help? Submit a support ticket and our team will assist you.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go('/support-ticket'),
                            child: const Text('Submit a Ticket'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () => context.go('/customer/tickets'),
                            child: const Text('View My Tickets'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Contact Information',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      const Text('Email: support@unicom.example', textAlign: TextAlign.center),
                      const Text('Hours: Mon–Fri, 9am–6pm', textAlign: TextAlign.center),
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
}
