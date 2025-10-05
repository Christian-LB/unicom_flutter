import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          const Expanded(
            child: Center(
              child: Text('Analytics Screen - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
