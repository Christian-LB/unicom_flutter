import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(centered: true),
          const Expanded(
            child: Center(
              child: Text('Profile Screen - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}
