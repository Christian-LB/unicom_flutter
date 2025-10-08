import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/navigation_bar.dart';
import '../theme/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _buildHeroSection(context),
                  _buildFeaturesSection(),
                  _buildCategoriesSection(context),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
      child: Column(
        children: [
          // Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'Trusted Local IT Solutions Provider',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Main heading
          const Text(
            'Your One-Stop Shop for\nElectronics & IT Solutions',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          
          // Subtitle
          const Text(
            'Quality computer parts, accessories, and expert technical support for individuals and businesses. Reliable products, personalized service, cost-efficient solutions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.mutedForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          
          // CTA Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () => context.go('/catalog'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Browse Catalog'),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Get Quote'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.muted.withOpacity(0.3),
      ),
      child: Column(
        children: [
          const Text(
            'Why Choose Unicom Technologies?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'We combine quality products with exceptional service to meet all your technology needs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 48),
          
          Row(
            children: [
              Expanded(child: _buildFeatureCard(
                icon: Icons.shopping_cart,
                title: 'Wide Product Range',
                description: 'Comprehensive selection of computer parts, accessories, and IT equipment from trusted brands',
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildFeatureCard(
                icon: Icons.build,
                title: 'Expert Support',
                description: 'Professional technical support and personalized service for all your IT needs',
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildFeatureCard(
                icon: Icons.people,
                title: 'Local Community',
                description: 'Serving individual consumers and small businesses with cost-efficient, reliable solutions',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 16),
      child: Column(
        children: [
          const Text(
            'Popular Categories',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Explore our most requested product categories',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 48),
          
          Row(
            children: [
              Expanded(child: _buildCategoryCard(
                context,
                icon: Icons.memory,
                title: 'Computer Components',
                description: 'CPUs, GPUs, motherboards, RAM, and more',
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildCategoryCard(
                context,
                icon: Icons.storage,
                title: 'Storage Solutions',
                description: 'SSDs, HDDs, external drives, and backup solutions',
              )),
              const SizedBox(width: 24),
              Expanded(child: _buildCategoryCard(
                context,
                icon: Icons.monitor,
                title: 'Peripherals',
                description: 'Monitors, keyboards, mice, and accessories',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => context.go('/catalog'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withOpacity(0.2),
                      AppColors.primary.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: AppColors.mutedForeground,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.primary,
      ),
      child: Column(
        children: [
          const Text(
            'Ready to Get Started?',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryForeground,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Browse our catalog or contact us for personalized recommendations and quotes',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: AppColors.primaryForeground,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 32),
          OutlinedButton(
            onPressed: () => context.go('/support'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primaryForeground),
              foregroundColor: AppColors.primaryForeground,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              textStyle: const TextStyle(fontSize: 18),
            ),
            child: const Text('Contact Us'),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildFooterColumn(
                title: 'Unicom Technologies',
                children: [
                  const Text(
                    'Your trusted local provider for electronics and IT solutions.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              )),
              const SizedBox(width: 32),
              Expanded(child: _buildFooterColumn(
                title: 'Products',
                children: [
                  _buildFooterLink('Computer Parts'),
                  _buildFooterLink('Accessories'),
                  _buildFooterLink('Storage'),
                  _buildFooterLink('Peripherals'),
                ],
              )),
              const SizedBox(width: 32),
              Expanded(child: _buildFooterColumn(
                title: 'Services',
                children: [
                  _buildFooterLink('Technical Support'),
                  _buildFooterLink('Installation'),
                  _buildFooterLink('Consultation'),
                  _buildFooterLink('Maintenance'),
                ],
              )),
              const SizedBox(width: 32),
              Expanded(child: _buildFooterColumn(
                title: 'Company',
                children: [
                  _buildFooterLink('About Us'),
                  _buildFooterLink('Contact'),
                  _buildFooterLink('Support'),
                  _buildFooterLink('Privacy'),
                ],
              )),
            ],
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            '© 2025 Unicom Technologies. All rights reserved.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterColumn({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildFooterLink(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }
}
