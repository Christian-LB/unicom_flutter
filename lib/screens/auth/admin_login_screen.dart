import 'package:flutter/material.dart';
import '../../widgets/navigation_bar.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          const Expanded(
            child: Center(
              child: Text('Admin Login Screen - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
