import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class CustomerQuotesScreen extends StatelessWidget {
  const CustomerQuotesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          const Expanded(
            child: Center(
              child: Text('Customer Quotes Screen - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
