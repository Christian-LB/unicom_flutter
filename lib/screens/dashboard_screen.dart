import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import '../theme/colors.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          const Expanded(
            child: Center(
              child: Text(
                'Dashboard Screen - Coming Soon',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
