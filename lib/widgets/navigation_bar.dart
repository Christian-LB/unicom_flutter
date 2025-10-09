import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../theme/colors.dart';

class CustomNavigationBar extends StatelessWidget {
  final bool centered;
  
  const CustomNavigationBar({Key? key, this.centered = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;
        
        return Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            border: Border(
              bottom: BorderSide(color: AppColors.border),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SizedBox(
            height: 64, // h-16 equivalent
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Left: Hamburger + small gap + Logo
                  Row(
                    children: [
                      _buildHamburgerMenu(context, user),
                      const SizedBox(width: 8),
                      _buildLogo(context, user),
                    ],
                  ),
                  // Right: Auth section (login/register or user/admin controls)
                  _buildAuthSection(context, user),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHamburgerMenu(BuildContext context, user) {
    final navItems = _getNavItems(user);
    return PopupMenuButton<String>(
      tooltip: 'Menu',
      icon: const Icon(Icons.menu),
      itemBuilder: (context) {
        return navItems.map((item) {
          final route = item['route']!;
          final label = item['label']!;
          final isActive = _isActiveRoute(context, route);
          return PopupMenuItem<String>(
            value: route,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? AppColors.primary : AppColors.foreground,
              ),
            ),
          );
        }).toList();
      },
      onSelected: (route) => context.go(route),
    );
  }

  Widget _buildLogo(BuildContext context, user) {
    return GestureDetector(
      onTap: () {
        if (user != null) {
          context.go(user.role == 'customer' ? '/customer/home' : '/dashboard');
        } else {
          context.go('/');
        }
      },
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'U',
                style: TextStyle(
                  color: AppColors.primaryForeground,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Unicom',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: AppColors.foreground,
                ),
              ),
              Text(
                'Technologies',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationLinks(BuildContext context, user) {
    final navItems = _getNavItems(user);
    
    return Row(
      children: navItems.map((item) {
        final isActive = _isActiveRoute(context, item['route']!);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: TextButton(
            onPressed: () => context.go(item['route']!),
            style: TextButton.styleFrom(
              foregroundColor: isActive ? AppColors.primary : AppColors.foreground,
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            child: Text(item['label']!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAuthSection(BuildContext context, user) {
    if (user == null) {
      final width = MediaQuery.of(context).size.width;
      final bool isSmall = width < 640; // mobile breakpoint (approx. tailwind sm)
      if (isSmall) {
        return PopupMenuButton<String>(
          tooltip: 'Account',
          icon: const Icon(Icons.person_outline),
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'login',
              child: Row(
                children: [
                  Icon(Icons.login, size: 16),
                  SizedBox(width: 8),
                  Text('Customer Login'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'register',
              child: Row(
                children: [
                  Icon(Icons.person_add_alt, size: 16),
                  SizedBox(width: 8),
                  Text('Sign Up'),
                ],
              ),
            ),
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'admin/login',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 16),
                  SizedBox(width: 8),
                  Text('Admin Login'),
                ],
              ),
            ),
          ],
          onSelected: (value) => context.go('/$value'),
        );
      }
      // Wide screens: show inline buttons consistent with theme
      return Row(
        children: [
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Customer Login'),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => context.go('/register'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.primaryForeground,
            ),
            child: const Text('Sign Up'),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            onPressed: () => context.go('/admin/login'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary),
            ),
            child: const Text('Admin'),
          ),
        ],
      );
    } else if (user.role == 'customer') {
      return Text(
        'Welcome, ${user.name}',
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.mutedForeground,
        ),
      );
    } else {
      return _buildAdminDropdown(context, user);
    }
  }

  Widget _buildAdminDropdown(BuildContext context, user) {
    return PopupMenuButton<String>(
      child: CircleAvatar(
        backgroundColor: AppColors.primary.withOpacity(0.1),
        child: Text(
          user.name[0].toUpperCase(),
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'dashboard',
          child: Row(
            children: [
              Icon(Icons.dashboard, size: 16),
              SizedBox(width: 8),
              Text('Dashboard'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'profile',
          child: Row(
            children: [
              Icon(Icons.settings, size: 16),
              SizedBox(width: 8),
              Text('Profile'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 16),
              SizedBox(width: 8),
              Text('Log out'),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        if (value == 'logout') {
          context.read<AuthProvider>().logout();
          context.go('/');
        } else {
          context.go('/$value');
        }
      },
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        context.read<AuthProvider>().logout();
        context.go('/');
      },
      icon: const Icon(Icons.logout, size: 16),
      label: const Text('Log out'),
      style: TextButton.styleFrom(
        foregroundColor: AppColors.mutedForeground,
      ),
    );
  }

  List<Map<String, String>> _getNavItems(user) {
    if (user == null) {
      return [
        {'route': '/', 'label': 'Home'},
        {'route': '/catalog', 'label': 'Catalog'},
        {'route': '/services', 'label': 'Services'},
        {'route': '/support', 'label': 'Support'},
        {'route': '/about', 'label': 'About'},
        {'route': '/dashboard', 'label': 'Dashboard'},
      ];
    } else if (user.role == 'customer') {
      return [
        {'route': '/customer/home', 'label': 'Home'},
        {'route': '/catalog', 'label': 'Catalog'},
        {'route': '/compare', 'label': 'Compare'},
        {'route': '/quote', 'label': 'Get Quote'},
        {'route': '/customer/quotes', 'label': 'My Quotes'},
        {'route': '/customer/tickets', 'label': 'My Tickets'},
        {'route': '/customer/support', 'label': 'Support'},
        {'route': '/dashboard', 'label': 'Dashboard'},
      ];
    } else {
      return [
        {'route': '/dashboard', 'label': 'Dashboard'},
        {'route': '/catalog', 'label': 'Catalog'},
        {'route': '/quotes', 'label': 'Quotes'},
        {'route': '/admin/tickets', 'label': 'Support Tickets'},
        {'route': '/analytics', 'label': 'Analytics'},
        {'route': '/inventory', 'label': 'Inventory'},
      ];
    }
  }

  bool _isActiveRoute(BuildContext context, String route) {
    // Fallback to GoRouterState for broader version compatibility
    final currentLocation = GoRouterState.of(context).matchedLocation;
    if (route == '/') {
      return currentLocation == '/';
    }
    return currentLocation.startsWith(route);
  }
}
