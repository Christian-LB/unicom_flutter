import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
import '../theme/colors.dart';

class QuoteScreen extends StatelessWidget {
  const QuoteScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          const Expanded(
            child: Center(
              child: Text(
                'Quote Screen - Coming Soon',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
