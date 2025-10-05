import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: const [
          CustomNavigationBar(centered: true),
          Expanded(
            child: Center(
              child: Text('Compare Screen - Coming Soon'),
            ),
          ),
        ],
      ),
    );
  }
}


