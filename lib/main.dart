import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/product_provider.dart';
import 'providers/quote_provider.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/catalog_screen.dart';
import 'screens/quote_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/customer_quotes_screen.dart';
import 'screens/admin_quotes_screen.dart';
import 'screens/inventory_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/admin_login_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/services_screen.dart';
import 'screens/support_screen.dart';
import 'screens/about_screen.dart';
import 'providers/ticket_provider.dart';
import 'screens/customer_tickets_screen.dart';
import 'screens/admin_tickets_screen.dart';
import 'screens/support_ticket_screen.dart';
import 'screens/compare_screen.dart';
import 'screens/catalog_detail_screen.dart';

void main() {
  runApp(const UnicomApp());
}

class UnicomApp extends StatelessWidget {
  const UnicomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => QuoteProvider()),
        ChangeNotifierProvider(create: (_) => TicketProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return MaterialApp.router(
            title: 'Unicom Technologies',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            routerConfig: _createRouter(authProvider),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }

  GoRouter _createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/',
      redirect: (context, state) {
        final isLoggedIn = authProvider.user != null;
        final isLoggingIn = state.matchedLocation == '/login' || 
                           state.matchedLocation == '/register' ||
                           state.matchedLocation == '/admin/login';
        
        // Redirect to login if not authenticated and trying to access protected routes
        if (!isLoggedIn && !isLoggingIn && _isProtectedRoute(state.matchedLocation)) {
          return '/login';
        }
        
        // Redirect to dashboard if logged in and trying to access auth pages
        if (isLoggedIn && isLoggingIn) {
          return authProvider.user!.role == 'admin' ? '/dashboard' : '/customer/home';
        }
        
        return null;
      },
      routes: [
        // Public routes
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/catalog',
          builder: (context, state) => const CatalogScreen(),
        ),
        GoRoute(
          path: '/catalog/:id',
          builder: (context, state) => CatalogDetailScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/compare',
          builder: (context, state) => const CompareScreen(),
        ),
        GoRoute(
          path: '/services',
          builder: (context, state) => const ServicesScreen(),
        ),
        GoRoute(
          path: '/support',
          builder: (context, state) => const SupportScreen(),
        ),
        GoRoute(
          path: '/about',
          builder: (context, state) => const AboutScreen(),
        ),
        
        // Auth routes
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/admin/login',
          builder: (context, state) => const AdminLoginScreen(),
        ),
        
        // Customer routes
        GoRoute(
          path: '/customer/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/customer/quotes',
          builder: (context, state) => const CustomerQuotesScreen(),
        ),
        GoRoute(
          path: '/customer/tickets',
          builder: (context, state) => const CustomerTicketsScreen(),
        ),
        GoRoute(
          path: '/customer/support',
          builder: (context, state) => const SupportScreen(),
        ),
        GoRoute(
          path: '/support-ticket',
          builder: (context, state) => const SupportTicketScreen(),
        ),
        
        // Protected routes
        GoRoute(
          path: '/quote',
          builder: (context, state) => const QuoteScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        
        // Admin routes
        GoRoute(
          path: '/quotes',
          builder: (context, state) => const AdminQuotesScreen(),
        ),
        GoRoute(
          path: '/admin/tickets',
          builder: (context, state) => const AdminTicketsScreen(),
        ),
        GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryScreen(),
        ),
        GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsScreen(),
        ),
      ],
    );
  }

  bool _isProtectedRoute(String location) {
    const protectedRoutes = [
      '/quote',
      '/dashboard',
      '/profile',
      '/customer/quotes',
      '/customer/support',
      '/quotes',
      '/inventory',
      '/analytics',
    ];
    return protectedRoutes.any((route) => location.startsWith(route));
  }
}
