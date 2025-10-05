import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class AdminQuotesScreen extends StatelessWidget {
  const AdminQuotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          const Expanded(
            child: Center(
              child: Text('Admin Quotes Screen - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
