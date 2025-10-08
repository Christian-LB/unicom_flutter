import 'package:flutter/material.dart';
import '../../widgets/navigation_bar.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String email = '';
    String password = '';

    return Scaffold(
      body: Column(
        children: [
          const CustomNavigationBar(),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Card(
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text('Admin Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Email'),
                              onChanged: (v) => email = v,
                              validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              decoration: const InputDecoration(labelText: 'Password'),
                              obscureText: true,
                              onChanged: (v) => password = v,
                              validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  if (!formKey.currentState!.validate()) return;
                                  final ok = await context.read<AuthProvider>().login(email, password);
                                  if (ok && context.mounted) {
                                    final user = context.read<AuthProvider>().user;
                                    if (user?.role == 'admin') {
                                      context.go('/dashboard');
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Not an admin account')),
                                      );
                                    }
                                  }
                                },
                                child: Consumer<AuthProvider>(
                                  builder: (context, auth, child) => Text(auth.isLoading ? 'Signing in...' : 'Sign In'),
                                ),
                              ),
                            ),
                            Consumer<AuthProvider>(
                              builder: (context, auth, child) => auth.error == null
                                  ? const SizedBox.shrink()
                                  : Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(auth.error!, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
