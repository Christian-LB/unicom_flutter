import 'package:flutter/material.dart';
import '../widgets/navigation_bar.dart';
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({Key? key}) : super(key: key);
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
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Our Services',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '• IT Hardware Procurement\n• Custom PC Builds & Enterprise Workstations\n• Network Design & Installation\n• Server Solutions & Storage\n• Maintenance & Support Contracts',
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16, height: 1.6),
                      ),
                      SizedBox(height: 24),
                      Text(
                        'Why Choose Us',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'We combine high-quality components, expert engineering, and responsive support to deliver reliable solutions at competitive prices.',
                        textAlign: TextAlign.center,
                      ),
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
